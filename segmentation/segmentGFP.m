function [landmark, centCoords] = segmentGFP( data, GFPseg_parameter, resolution )

% specify segmentation algorithm
% TODO: Set via GUI!
% GFPseg_parameter.method = 'k-means';
debug = 0; %TODO: make dependent on a general debug variable, e.g., p.debug

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
    
    % extract processing parameters
    downsampling_factor = GFPseg_parameter.downsampling_factor;
    size_opening = GFPseg_parameter.size_opening;
    size_closing = GFPseg_parameter.size_closing;
    intensity_threshold = GFPseg_parameter.threshold;
    minNumberVoxels = GFPseg_parameter.minNumberVoxels;
    
    % determine dimensions of downsampled data
    [dim_y_red, dim_x_red] = size(imresize(data(:,:,1),downsampling_factor));
    
    % initialize container for downsampled data
    data_downsampled = zeros(dim_y_red, dim_x_red, size(data,3));
    
    % downsample slice-wise (we keep z-dimension fixed)
    for i = 1:size(data,3)
        data_downsampled(:,:,i) = imresize(data(:,:,i),downsampling_factor);
    end
    
    % segment GFP using k-means clustering
    k = GFPseg_parameter.k;
    
    % initialize Xi and Xi_temp
    Xi = ones(size(data)); Xi_temp = Xi;
    
    % some datasets need a higher k parameter to resolve the different
    % intensity values near the landmark, so we perform k-means again
    while (nnz(Xi_temp) >= 0.01 * numel(Xi) && k < 8)
        
        % perform k-means clustering on downsampled data
        Xi_red = k_means_clustering(data_downsampled, k, 'real');
                
        % upsample clustering result to full data size
        Xi = zeros(size(data));
        for i = 1:size(data,3)
            Xi(:,:,i) = imresize(Xi_red(:,:,i),1/downsampling_factor, 'nearest');
        end
        
        % only use two highest labels of k-means clustering
        %Xi_temp = Xi-2>0;
        
        % check if signal was too strong so that too many  (more than 1%
        % in Xi)elements are found with k-means when only cutting off
        % lowest two k-channels
        %if ( nnz(Xi_temp) > 0.01 * numel(Xi) )
        %    Xi_temp = Xi-(k-1) > 0;
        %end
        % upsample clustering result to full data size
        Xi = zeros(size(data));
        for i = 1:size(data,3)
            Xi(:,:,i) = imresize(Xi_red(:,:,i),1/downsampling_factor, 'nearest');
        end
        
        Xi_temp = Xi-k+2>0;
        
        k = k+1;
    end
    
    % perform morphlogical operations, i.e., opening and closing
    Xi = imopen(Xi_temp,strel('disk',size_opening));
    Xi = imclose(Xi,strel('disk',size_closing));
    
       
    % DEBUG
    %figure; imagesc(computeMIP(data)); hold on; contour(computeMIP(Xi), [0.5 0.5], 'r'); hold off
    
    % get rid of outliers via connected components
    CC = bwconncomp(Xi);
    %  check for component with most voxels (assuming this is the landmark)
    for i = 1:CC.NumObjects
        currentNumberVoxels = numel(CC.PixelIdxList{i});
        % if connected component has not enough voxels we consider it as
        % outlier and remove it from the segmentation
        if currentNumberVoxels < minNumberVoxels
            Xi(CC.PixelIdxList{i}) = 0;
        end
    end
    
    % restrict segmentation to highest intensity voxels
    % depending on the setting of the threshold this will thin the landmark significantly
    if ( GFPseg_parameter.threshold > 0 )
        fprintf('Cutting off blurry effects in GFP segmentation based on max. intensity values...\n');
        MIP = computeMIP(data);
        Xi_thinned = (Xi & (data > intensity_threshold*repmat(MIP,1,1,size(data,3))));
    end
end

% DEBUGGING
if debug >= 1
    figure;
    subplot(1,2,1); isosurface(Xi, 0.5); view(0,0);
    subplot(1,2,2); isosurface(Xi_thinned, 0.5); view(0,0);
    figure; imagesc(computeMIP(data)); hold on; contour(computeMIP(Xi_thinned),[0.5, 0.5], 'r'); hold off
end

% set output variable
landmark = single(Xi_thinned);

%% GET CENTERS OF SEGMENTED REGIONS
% -- WE ASSUME BRIGHTEST PIXEL TO BE THE CENTER

indices = find(landmark > 0);
[tmpy, tmpx, tmpz] = ind2sub(size(landmark), indices);

% initialize container for center coordinates
centCoords = zeros(3,numel(indices));
% set return variables
centCoords(1,:) = tmpx;
centCoords(2,:) = tmpy;
centCoords(3,:) = tmpz;

end

