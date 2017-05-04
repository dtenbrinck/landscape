function data = removeBackground( data, rmbg_parameter, channel )
%REMOVEBACKGROUND Summary of this function goes here
%   Detailed explanation goes here

% TODO: Test best size of structuring element experimentally!

% Generate structural elements for preprocessing
struct_element_dapi = strel('disk',rmbg_parameter.dapiDiskSize);
struct_element_gfp = strel('disk',rmbg_parameter.GFPDiskSize);
struct_element_mCherry = strel('disk',rmbg_parameter.mCherryDiskSize);


% if the input data is a struct we normalize each channel data set
if isstruct(data)
    
    % determine number of timepoints (in case of dynamic data)
    numberOfTimepoints = size(data.Dapi,4);
    
    % normalize each timepoint separately
    for t = 1:numberOfTimepoints
        
        % preprocess Dapi data
        data.Dapi(:,:,:,t) = imtophat(data.Dapi(:,:,:,t), struct_element_dapi);
        
        % preprocess GFP data
        data.GFP(:,:,:,t) = imtophat(data.GFP(:,:,:,t), struct_element_gfp);
        
        % preprocess mCherry data
        data.mCherry(:,:,:,t) = imtophat(data.mCherry(:,:,:,t), struct_element_mCherry);
        
    end
    
else
    
    if nargin > 2
        
        % determine number of timepoints (in case of dynamic data)
        numberOfTimepoints = size(data,4);
        
        switch channel
            case 1
                struct_element = struct_element_dapi;
            case 2
                struct_element = struct_element_gfp;
            case 3
                struct_element = struct_element_mCherry;
            otherwise
                error('Channel has to be 1,2, or 3!');
        end
        
        % normalize each timepoint separately
        for t = 1:numberOfTimepoints
            data(:,:,:,t) = imtophat(data(:,:,:,t), struct_element);
        end
        
    end
    
end

end

