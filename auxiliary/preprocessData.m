function [ data ] = preprocessData( data, scale )
% PREPROCESSDATA: This function preprocesses the data struct. 
% It will remove the background, rescale the slices and normalize it.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Main Code

% Perform background removal using morphological filters
data = removeBackground(data);

% Resize data
data = rescaleSlices(data, scale);

% Normalize data
data = normalizeData(data);


end

