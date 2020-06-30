function [ data, p ] = preprocessData( data, p )
% PREPROCESSDATA: This function preprocesses the data struct. 
% It will remove the background, rescale the slices and normalize it.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Main Code

% Perform background removal using morphological filters
data = removeBackground(data,p.rmbg);

% Resize data
if (p.scale ~= 1)
    if (isfield(p, 'scaleAllDim') && p.scaleAllDim > 0) 
        data = rescaleSlicesFull3d(data, p.scale);
    else
        data = rescaleSlices(data, p.scale);
    end
end

% Normalize data
data = normalizeData(data);

% Save size of resized data for later
p.scaledDataSize = [size(data.GFP,1),size(data.GFP,2),size(data.GFP,3)];

end

