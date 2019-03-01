function [nuclei, centCoords] = segmentDAPI( data, p, resolution )
%SEGMENTDATA Summary of this function goes here
%   Detailed explanation goes here

if strcmp(p.method, 'CP') % Chambolle-Pock with thresholding
  % get histogram
  [h, bins] = imhist(data(:));
  
  % get integral over histogram
  p = cumsum(h);
  
  % normalize integral
  p = p / p(end);
  
  % get only brightest signals
  threshold = 0.995; % WARNING: THIS IS HEURISTIC!
  
  % get relevant indices
  indices = find(p > threshold);
  
  % take first index
  index = indices(1);
  
  % get corresponding bin as global threshold
  dataP.t = bins(index);
  fprintf('Optimal threshold for embryo data in DAPI channel computed as t1=%i.\n', dataP.t);
  
  % set data in struct
  dataP.f = data;
  
  % initialize image parameters
  [dataP.nx, dataP.ny, dataP.nz] = size(dataP.f);
  dataP.dim = ndims(dataP.f);
  dataP.hx = resolution(1); dataP.hy = resolution(2); dataP.hz = resolution(3);
  
  % initialize algorithm parameters
  algP.maxIts = 600;%5000;
  algP.alpha = 5000;
  algP.regAccur = 1e-7;
  algP.mu_grad_u = 1;
  algP.TV = 'iso';
  
  % decide if plotting is enabled
  algP.showSegmentation = true;
  algP.showInterval = 200;
  algP.plotError = false;
  
  % segment DAPI cells using modified Arrow-Hurrowitz algorithm
  [u, rel_change] = wL2_TV_AHMOD(dataP, algP, dataP.f, ones(size(dataP.f)), false);
  
  % determine segmentation contour by thresholding
  Xi = zeros(size(dataP.f));
  Xi(u >= dataP.t) = 1;
  
elseif strcmp(p.method,'k-means') % k-means clustering
  k = p.k;
  Xi = k_means_clustering(data, k, 'real');
  Xi = floor(Xi / k);
elseif strcmp(p.method, 'Laplacian')
    
    % generate a three-dimensional Laplacian filter
    kernelLaplace = generate3dLaplacian(resolution);
    % determine sharp areas in DAPI channel by Laplacian filtering
    sharp_areas = normalizeData(imfilter(data, kernelLaplace, 'same', 'replicate'));
    
    % determine global threshold to detect sharp areas
    threshold = kittler_thresholding(sharp_areas);
    
    % determine sharp points
    Xi = sharp_areas > threshold;
end

%% GET CENTERS OF SEGMENTED REGIONS
% -- WE ASSUME BRIGHTEST PIXEL TO BE THE CENTER

% look for brightest pixel in gauß smoothest original data
%former sigma value: [1,1,0.1]. If problems occur, try resetting it to this
smoothed = imgaussfilt3(data, 0.1);

locMax = imregionalmax(smoothed, 26);
% TODO reduce plateau areas to only one pixel?!

% remove too small objects
% neighbourhoodConnectivity = zeros(3,3,3);
% neighbourhoodConnectivity(:,:,2) = ones(3,3);
% brightRegions = bwareaopen(Xi, p.minNucleusSize, neighbourhoodConnectivity);
brightRegions = bwareaopen(Xi, p.minNucleusSize, 26);

brightPixel3d = brightRegions & locMax;

indices = find(brightPixel3d > 0);
[tmpy, tmpx, tmpz] = ind2sub(size(brightPixel3d), indices);

% initialize container for center coordinates
centCoords = zeros(3,numel(indices));
% set return variables
centCoords(1,:) = tmpx;
centCoords(2,:) = tmpy;
centCoords(3,:) = tmpz;
nuclei = Xi;

%%%%%%% test visualizations around slice 20 %%%%%%%%%%%%
% 
% % the same cell should not be found in consecutive slices
% % so the plotted pixel are not close together for slice 19 and 20
% 
% figure;
% overlay2=imoverlay(brightPixel3d(:,:,19), brightPixel3d(:,:,20), 'r');
% imagesc(overlay2)
% 
% % found center coordinates of slice 21
% layer=centCoords(:,centCoords(3,:)==21);
% figure;
% subplot(1,2,1);
% imagesc(data(:,:,20))
% hold on
% plot(layer(1,:),layer(2,:),'r*')
% subplot(1,2,2);
% imagesc(Xi(:,:,20))
% hold on
% plot(layer(1,:),layer(2,:),'r*')
% 
% % found center coordinates of slice 20
% layer=centCoords(:,centCoords(3,:)==20);
% figure;
% subplot(1,2,1);
% imagesc(data(:,:,20))
% hold on
% plot(layer(1,:),layer(2,:),'r*')
% subplot(1,2,2);
% imagesc(Xi(:,:,20))
% hold on
% plot(layer(1,:),layer(2,:),'r*')
% 
% % found center coordinates of slice 19
% layer=centCoords(:,centCoords(3,:)== 19);
% figure;
% subplot(1,2,1);
% imagesc(data(:,:,20))
% hold on
% plot(layer(1,:),layer(2,:),'r*')
% subplot(1,2,2);
% imagesc(Xi(:,:,20))
% hold on
% plot(layer(1,:),layer(2,:),'r*')

% % possible tuning options to improve the segmentation results:
% % - connectivity parameter in bwareaopen and imregionalmax
% % - imgaussfilt3: sigma vector
% % - or imgaussfilt for 2D slice-wise images?
% % - min. nucleus size in ParameterProcessing: p.DAPIseg.minNucleusSize 

end
