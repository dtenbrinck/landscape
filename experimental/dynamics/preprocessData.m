function [ data ] = preprocessData( data, p, channel )
% PREPROCESSDATA: This function preprocesses the data struct. 
% It will remove the background, rescale the slices and normalize it.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Main Code

% Perform background removal using morphological filters
data = removeBackground(data,p.rmbg, channel);

% Resize data
data = rescaleSlices(data, p.scale);

% Normalize data
data = normalizeData(data);


end

