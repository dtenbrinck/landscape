function Xi = segmentEmbryo( data )

% set image to segment
dataP.f = data;

% initialize image parameters
[dataP.nx, dataP.ny, dataP.nz] = size(dataP.f);
dataP.dim = ndims(dataP.f);
dataP.hx = 1; dataP.hy = 1; dataP.hz = 1;

% initialize algorithm parameters
algP.maxIts = 200;%5000;
algP.alpha = 0.01;
algP.regAccur = 1e-7;
algP.mu_grad_u = 1;
algP.TV = 'iso';

% decide if plotting is enabled
algP.showSegmentation = false;
algP.showInterval = 500;
algP.plotError = false;

% obtain global threshold
dataP.t = otsu_thresholding(dataP.f);
fprintf('Optimal threshold for data computed as t=%i.', dataP.t);

dataP.t = otsu_thresholding(dataP.f(dataP.f < dataP.t));
fprintf('Optimal threshold for data computed as t2=%i.', dataP.t);

% perform image segmentation using modified Arrow-Hurrowitz algorithm
[u, rel_change] = wL2_TV_AHMOD(dataP, algP, dataP.f, ones(size(dataP.f)), false);
    
% determine segmentation contour by thresholding
Xi = zeros(size(dataP.f));
Xi(u >= dataP.t) = 1;
end

