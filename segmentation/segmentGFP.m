function landmark = segmentGFP( data, resolution )

% specify segmentation algorithm
% TODO: Set via GUI!
method = 'k-means';

if strcmp(method, 'CP') % Chambolle-Pock and thresholding
    
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
    
    % obtain global threshold
    dataP.t = otsu_thresholding(dataP.f);
    fprintf('Optimal threshold for GFP embryo data computed as t1=%i.\n', dataP.t);
    
    %%% segment GFP landmark
    
    % segment landmark region using modified Arrow-Hurrowitz algorithm
    % TODO: Use Chambolle-Pock GPU implementation by Hendrik Dirks
    [u, rel_change] = wL2_TV_AHMOD(dataP, algP, dataP.f, ones(size(dataP.f)), false);
    
    % determine segmentation contour by thresholding
    Xi = zeros(size(dataP.f));
    Xi(u >= dataP.t) = 1;
    
    
    
elseif strcmp(method, 'k-means')  % k-means clustering
    
    % segment GFP using k-means clustering
    Xi = k_means_clustering(data, 3, 'real');
    Xi = floor(Xi / 3);
    
end

% set output variable
landmark = Xi;

end

