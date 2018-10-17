function landmark = segmentGFP( data, GFPseg_parameter, resolution )

% specify segmentation algorithm
% TODO: Set via GUI!
% GFPseg_parameter.method = 'k-means';
type = 'morph';

if strcmp(GFPseg_parameter.method, 'CP') % Chambolle-Pock and thresholding
    
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
    algP.showSegmentation = false;
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
    
    
    
elseif strcmp(GFPseg_parameter.method, 'k-means')  % k-means clustering
    
    % segment GFP using k-means clustering
    k = GFPseg_parameter.k;
    morphSize = GFPseg_parameter.morphSize;
    Xi = k_means_clustering(data, k, 'real');
    
    if strcmp(type,'k-channel')
        Xi = floor(Xi / k);
    elseif strcmp(type,'morph')
        Xi_temp = Xi-2>0;
        % check if signal was too strong so that too many  (more than 5% 
        % in Xi)elements are found with k-means when only cutting off 
        % lowest two k-channels
        if ( nnz(Xi_temp) > 0.05 * numel(Xi) )
            Xi_temp = Xi-(k-1) > 0;
        end
        Xi = imopen(Xi_temp,strel('disk',morphSize));        
    end
    
    % restrict segmentation to highest intensity voxels
    if ( GFPseg_parameter.threshold > 0 )
        fprintf('Cutting off blurry effects in GFP segmentation based on max. intensity values...\n');
        MIP = computeMIP(data);
        Xi2 = (Xi & data > GFPseg_parameter.threshold*repmat(MIP,1,1,size(data,3)));
        Xi = Xi2;
    end
end

% set output variable
landmark = double(Xi);

end

