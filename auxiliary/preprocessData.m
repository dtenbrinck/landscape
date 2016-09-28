function [ data ] = preprocessData( data, scale )
% PREPROCESSDATA: This function preprocesses the data struct. 
% It will remove the background, rescale the slices and normalize it.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Main Code

% Perform background removal using morphological filters
fprintf('- Removing the background of the data...');
data = removeBackground(data);
fprintf('Done!\n');
% Resize data
fprintf('- Rescale the slices...');
data = rescaleSlices(data, scale);
fprintf('Done!\n');
% Normalize data
fprintf('- Normalizing the data...');
data = normalizeData(data);
fprintf('Done!\n');

end

