function [cells, centCoords] = segmentCells( data, resolution )
%SEGMENTDATA Summary of this function goes here
%   Detailed explanation goes here

% normalize data
data = normalizeData(data);

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
%dataP.hx = 1; dataP.hy = 1; dataP.hz = 1;

% initialize algorithm parameters
algP.maxIts = 200;%5000;
algP.alpha = 10;
algP.regAccur = 1e-7;
algP.mu_grad_u = 1;
algP.TV = 'iso';

% decide if plotting is enabled
algP.showSegmentation = true;
algP.showInterval = 400;
algP.plotError = false;


% segment mCherry cells using modified Arrow-Hurrowitz algorithm
% [u, rel_change] = wL2_TV_AHMOD(dataP, algP, dataP.f, ones(size(dataP.f)), false);
    
% determine segmentation contour by thresholding
u = dataP.f;
Xi = zeros(size(dataP.f));
Xi(u >= dataP.t) = 1;

% look for connected components
cc = bwconncomp(Xi);

cells = zeros(size(data));

% remove too small items
j = 1;
% Centroid for all cells

for i = 1:cc.NumObjects
  pixelList = cc.PixelIdxList{i};
  if length(pixelList) > 50
    cellObjects{j} = pixelList;
    j = j+1;
  end
end

for j=1:length(cellObjects)
  currentCell = zeros(size(data)); 
  currentCell(cellObjects{j}) = 1;
  currentCell = currentCell .* data;
  
  maxSlice = 2;
  maxValue = -1;
  for slice = 2:size(data,3)-1
    if max(max(currentCell(:,:,slice))) > maxValue
      maxSlice = slice;
      maxValue = max(max(currentCell(:,:,slice)));
    end
  end
  
  sliceMask = zeros(size(data));
  sliceMask(:,:,maxSlice) = 1;
  
  currentCell = currentCell .* sliceMask;
  cells(currentCell > 0) = 1;
end


% Centroids of the cells

cc = bwconncomp(cells);
S = regionprops(cc,'centroid');
centCoords = round(reshape([S.Centroid],[3,numel([S.Centroid])/3]));

% set output variable
%cells = Xi;


end

