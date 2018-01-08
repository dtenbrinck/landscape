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

indices = find(Xi > 0);
[tmpy, tmpx, tmpz] = ind2sub(size(Xi), indices);

% initialize container for center coordinates
centCoords = zeros(3,numel(indices));
% set return variables
centCoords(1,:) = tmpy;
centCoords(2,:) = tmpx;
centCoords(3,:) = tmpz;
nuclei = Xi;

end
