function Xi = segmentData( data, threshold )
%SEGMENTDATA Summary of this function goes here
%   Detailed explanation goes here

% set data in struct
dataP.f = data;

% initialize image parameters
[dataP.nx, dataP.ny, dataP.nz] = size(dataP.f);
dataP.dim = ndims(dataP.f);
dataP.hx = 1; dataP.hy = 1; dataP.hz = 1;

% initialize algorithm parameters
algP.maxIts = 1000;%5000;
algP.alpha = 10;
algP.regAccur = 1e-7;
algP.mu_grad_u = 1;
algP.TV = 'aniso';

% decide if plotting is enabled
algP.showSegmentation = true;
algP.showInterval = 50;
algP.plotError = true;

% obtain global threshold
%dataP.t = otsu_thresholding(dataP.f);
dataP.t = threshold;
fprintf('Optimal threshold for data computed as t=%i.', dataP.t);

% perform image segmentation using modified Arrow-Hurrowitz algorithm
[u, rel_change] = wL2_TV_AHMOD(dataP, algP, dataP.f, ones(size(dataP.f)), false);
    
% determine segmentation contour by thresholding
Xi = zeros(size(dataP.f));
Xi(u >= dataP.t+1) = 1;

% visualize segmentation result
if ndims(dataP.f) == 2
  drawSegmentation(dataP.f, Xi);
elseif ndims(dataP.f) == 3
  renderSurface(Xi);
end

end

