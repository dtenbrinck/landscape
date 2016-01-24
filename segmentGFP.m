function landmark = segmentGFP( data, mask )
%SEGMENTDATA Summary of this function goes here
%   Detailed explanation goes here

% set data in struct
dataP.f = data;

% initialize image parameters
[dataP.nx, dataP.ny, dataP.nz] = size(dataP.f);
dataP.dim = ndims(dataP.f);
dataP.hx = 1; dataP.hy = 1; dataP.hz = 1;

% initialize algorithm parameters
algP.maxIts = 2000;%5000;
algP.alpha = 200;
algP.regAccur = 1e-7;
algP.mu_grad_u = 1;
algP.TV = 'iso';

% decide if plotting is enabled
algP.showSegmentation = false;
algP.showInterval = 200;
algP.plotError = false;

% obtain global threshold
dataP.t = otsu_thresholding(dataP.f);
fprintf('Optimal threshold for GFP embryo data computed as t1=%i.\n', dataP.t);

%%% segment embryo

% segment embryo region using modified Arrow-Hurrowitz algorithm
%[u, rel_change] = wL2_TV_AHMOD(dataP, algP, dataP.f, ones(size(dataP.f)), false);
u = dataP.f; 

% determine segmentation contour by thresholding
Xi = zeros(size(dataP.f));
Xi(u >= dataP.t+1) = 1;

% set output variable
embryo = Xi;

%%% segment landmark

% compute new threshold only for volume of embryo
dataP.t = kittler_thresholding(dataP.f, embryo);
fprintf('Optimal threshold for GFP landmark computed as t2=%i.\n', dataP.t);

% segment landmark region using modified Arrow-Hurrowitz algorithm
[u, rel_change] = wL2_TV_AHMOD(dataP, algP, dataP.f .* mask, ones(size(dataP.f)), false);
    
% determine segmentation contour by thresholding
Xi = zeros(size(dataP.f));
Xi(u >= dataP.t+1) = 1;

% set output variable
landmark = Xi;


end

