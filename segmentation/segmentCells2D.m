function cells = segmentCells2D( data, resolution )
%SEGMENTDATA Summary of this function goes here
%   Detailed explanation goes here

% normalize data
data = normalizeData(data);

%% OLD IDEA

% get histogram
%[h, bins] = imhist(data(:));

% get integral over histogram
%p = cumsum(h);

% normalize integral
%p = p / p(end);

% get only brightest signals
%threshold = 0.96; % WARNING: THIS IS HEURISTIC!

% get relevant indices
%indices = find(data > threshold);

% take first index
%index = indices(1);

% get corresponding bin as global threshold
%dataP.t = bins(index);
%fprintf('Optimal threshold for embryo data in mCherry channel computed as t1=%i.\n', dataP.t);

%% NEW APPROACH

% compute optimal threshold
dataP.t = kittler_thresholding(data);

% set data in struct
dataP.f = data;

% initialize image parameters
[dataP.nx, dataP.ny, dataP.nz] = size(dataP.f);
dataP.dim = ndims(dataP.f);
dataP.hx = 1; dataP.hy = 1; dataP.hz = 1;

% initialize algorithm parameters
algP.maxIts = 200;%5000;
algP.alpha = 2000;
algP.regAccur = 1e-7;
algP.mu_grad_u = 1;
algP.TV = 'iso';

% decide if plotting is enabled
algP.showSegmentation = false;
algP.showInterval = 1000;
algP.plotError = false;


% segment mCherry cells using modified Arrow-Hurrowitz algorithm
[u, rel_change] = wL2_TV_AHMOD(dataP, algP, dataP.f, ones(size(dataP.f)), false);
    
% determine segmentation contour by thresholding
u = dataP.f;
Xi = zeros(size(dataP.f));
Xi(u >= dataP.t) = 1;

% look for connected components
cc = bwconncomp(Xi,4);

cells = zeros(size(data));

% remove too small items
j = 1;
for i = 1:cc.NumObjects
  
  pixelList = cc.PixelIdxList{i};
  if length(pixelList) > 20
    cellObjects{j} = pixelList;
    j = j+1;
  end
end

for j=1:length(cellObjects)
  currentCell = zeros(size(data)); 
  currentCell(cellObjects{j}) = 1;
  currentCell = currentCell .* data;
  cells(currentCell > 0) = 1;
end


end

