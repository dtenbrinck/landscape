function resized_data = rescaleSlices( data, scale, method )

% check if interpolation method is specified
if nargin == 2
    method = 'bilinear';
end

% check if we have a struct
if isstruct(data)
    
    % determine number of timepoints (in case of dynamic data)
    numberOfTimepoints = size(data.Dapi,4);
    
    % initialize struct for rescaled data
    resized_data = data;
    resized_data.Dapi = zeros(ceil(scale * size(data.Dapi,1)),...
                              ceil(scale * size(data.Dapi,2)),...
                                           size(data.Dapi,3),...
                                           size(data.Dapi,4));
    resized_data.GFP      = resized_data.Dapi;
    resized_data.mCherry  = resized_data.Dapi;
    
    % adapt x-/y-resolution with respect to new scale
    resized_data.x_resolution = resized_data.x_resolution / scale;
    resized_data.y_resolution = resized_data.y_resolution / scale;
    
    % rescale each timepoint separately
    for t = 1:numberOfTimepoints
        
        % Rescale data for higher processing speed using trilinear interpolation
        for i=1:size(data.Dapi,3)
            resized_data.Dapi(:,:,i,t)    = imresize(data.Dapi(:,:,i,t), scale, method);
            resized_data.GFP(:,:,i,t)     = imresize(data.GFP(:,:,i,t), scale, method);
            resized_data.mCherry(:,:,i,t) = imresize(data.mCherry(:,:,i,t), scale, method);
        end
        
    end
    
else % otherwise rescale data directly
    
    % determine number of timepoints (in case of dynamic data)
    numberOfTimepoints = size(data,4);
    
    resized_data = zeros(ceil(scale * size(data,1)),...
                         ceil(scale * size(data,2)),...
                                      size(data,3),...
                                      size(data,4));
    
    % rescale each timepoint separately
    for t = 1:numberOfTimepoints                              
                                  
    % Rescale data for higher processing speed using trilinear interpolation
    for i=1:size(data,3)
        resized_data(:,:,i,t) = imresize(data(:,:,i,t), scale, method);
    end
    
    end
    
end
end

