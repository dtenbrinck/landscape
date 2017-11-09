function [nuclei, centCoords] = segmentDAPI( data, p, resolution )
%SEGMENTDATA Summary of this function goes here
%   Detailed explanation goes here

% method = 'k-means';

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
  fprintf('Optimal threshold for embryo data in mCherry channel computed as t1=%i.\n', dataP.t);
  
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
  
  % segment mCherry cells using modified Arrow-Hurrowitz algorithm
  [u, rel_change] = wL2_TV_AHMOD(dataP, algP, dataP.f, ones(size(dataP.f)), false);
  
  % determine segmentation contour by thresholding
  Xi = zeros(size(dataP.f));
  Xi(u >= dataP.t) = 1;
  
elseif strcmp(p.method,'k-means') % k-means clustering
  k = p.k;
  Xi = k_means_clustering(data, k, 'real');
  Xi = floor(Xi / k);
  
elseif strcmp(p.method, 'k-means_local') % k-means in every slice
  k = p.k;
  Xi = zeros(size(data));
  for slice=1:size(data,3)
    tmp = k_means_clustering(data(:,:,slice), k, 'real');
    
    test = sum(tmp(:) == 2);
    if test > 1/10 * numel(tmp)
      Xi(:,:,slice) = floor(tmp / k);
    else
      tmp2 = zeros(size(tmp));
      tmp2(tmp >= 2) = 1;
      Xi(:,:,slice) = tmp2;
    end
  end
elseif strcmp(p.method, 'Laplacian')
  blurred = data;
  
  % generate a three-dimensional Laplacian filter
  kernelLaplace = generate3dLaplacian(resolution);
  
  % determine sharp areas in DAPI channel by Laplacian filtering
  sharp_areas = normalizeData(imfilter(blurred, kernelLaplace, 'same', 'replicate'));
  
  % determine global threshold to detect sharp areas
  threshold = kittler_thresholding(sharp_areas);
  
  % determine sharp points
  Xi = sharp_areas > threshold;
end

%% GET CENTERS OF SEGMENTED REGIONS
% -- WE ASSUME BRIGHTEST PIXEL TO BE THE CENTER

% look for connected components
cc = bwconncomp(Xi);

% initialize a mask for (valid) segmented nuclei
nuclei = zeros(size(data));

% initialize container for center coordinates
centCoords = zeros(cc.NumObjects,3);

% initialize counter variable for valid cells
j = 0;

% iterate over all connected components
for i = 1:cc.NumObjects
  
  % check if connected region is smaller than user-specified size
  if length(cc.PixelIdxList{i}) > p.maxNucleusSize || length(cc.PixelIdxList{i}) < p.minNucleusSize
    continue; % skip too large objects
  end
  
  % increase counter variable
  j = j+1;
  
  % get coordinates of current object
  [Y,X,Z] = ind2sub(cc.ImageSize, cc.PixelIdxList{i});
  
  % extract current object locally
  local_object = data(min(Y(:)):max(Y(:)),min(X(:)):max(X(:)),min(Z(:)):max(Z(:)));
  
  % search for maximum value in local region
  index_max = median(find(local_object == max(local_object(:))));
  
  % compute local coordinates
  [y_loc,x_loc,z_loc] = ind2sub(size(local_object), index_max);
  
  % add offset of bounding box to get global coordinates
  y = y_loc + min(Y(:)) - 1;
  x = x_loc + min(X(:)) - 1;
  z = z_loc + min(Z(:)) - 1;
  
  % mark nuclei center coordinate in mask
  nuclei(y,x,z) = 1;
  
  % save center coordinates
  centCoords(j,1) = y;
  centCoords(j,2) = x;
  centCoords(j,3) = z;
   
end

% delete unfilled rows in matrix
centCoords( centCoords(:,1) == 0, : ) = [];

end

