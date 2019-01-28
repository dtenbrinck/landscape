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
  Xi2 = k_means_clustering(data, k, 'real');
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

% look for connected components
neighbourhoodConnectivity = zeros(3,3,3);
neighbourhoodConnectivity(:,:,2) = ones(3,3);
cc = bwconncomp(Xi,neighbourhoodConnectivity);

% initialize a mask for (valid) segmented nuclei
nuclei = zeros(size(data));

% initialize container for center coordinates
centCoords = zeros(3,cc.NumObjects);

% initialize counter variable for valid cells
j = 0;

%p.maxNucleusSize = 40;
p.minNucleusSize = 10;
cc.NumObjects
% iterate over all connected components
for i = 1:cc.NumObjects
  
  % check if connected region is in user-specified range
  if length(cc.PixelIdxList{i}) < p.minNucleusSize
    continue; % skip too large and too small objects
  end
  
  % increase counter variable
  j = j+1;
  
  % get coordinates of current object
  [Y,X,Z] = ind2sub(cc.ImageSize, cc.PixelIdxList{i});
  
  % extract current object locally
  local_object = data(min(Y(:)):max(Y(:)),min(X(:)):max(X(:)),min(Z(:)):max(Z(:)));
    
  % search for maximum value in local region
  indices_max = find(local_object == max(local_object(:)));
  
  % compute local coordinates
  [y_loc,x_loc,z_loc] = ind2sub(size(local_object), indices_max);
  
  if numel(indices_max) > 1
      % get center index of bounding box
      index_center = round(numel(local_object) / 2);
  
      % compute center coordinates
      [y_c,x_c,z_c] = ind2sub(size(local_object), index_center);  
  
      % compute distances to center
      distances = sum((repmat([y_c,x_c,z_c],numel(indices_max),1) - [y_loc,x_loc,z_loc]).^2, 2);
      
      % extract nearest entry
      index_nearest = find(distances == min(distances));
      
      % get local coordinates
      y_loc = y_loc(index_nearest);
      x_loc = x_loc(index_nearest);
      z_loc = z_loc(index_nearest);
  
  end
  
  % add offset of bounding box to get global coordinates
  y = y_loc + min(Y(:)) - 1;
  x = x_loc + min(X(:)) - 1;
  z = z_loc + min(Z(:)) - 1;
    
  try
  % mark nuclei center coordinate in mask
  nuclei(y,x,z) = 1;
  catch ERROR_MSG
      stop = 1;
  end
  
  % save center coordinates
  centCoords(1,j) = x;
  centCoords(2,j) = y;
  centCoords(3,j) = z;
   
end

j
% delete unfilled rows in matrix
centCoords( :, centCoords(1,:) == 0 ) = [];




%%%%%%%%%%%%%%%%%%%%%%%
indices = find(Xi > 0);
[tmpy, tmpx, tmpz] = ind2sub(size(Xi), indices);

% initialize container for center coordinates
centCoords2 = zeros(3,numel(indices));
% set return variables
centCoords2(1,:) = tmpx;
centCoords2(2,:) = tmpy;
centCoords2(3,:) = tmpz;
nuclei2 = Xi;

figure;
layer=centCoords(:,centCoords(3,:)==20);
layer2=centCoords2(:,centCoords2(3,:)==20);
plot(layer2(1,:),layer2(2,:),'.')
hold on;
plot(layer(1,:),layer(2,:),'r*')
figure;
imagesc(data(:,:,20))
hold on
plot(layer(1,:),layer(2,:),'r*')


end
