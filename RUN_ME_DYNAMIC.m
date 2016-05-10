% Script for segmentation of 3D cells in living zebra fish embryos for
% motion estimation
%
%   Copyright: Daniel Tenbrinck
%   Department of Mathematics and Computer Science
%   University of Muenster, Germany
%   email: daniel.tenbrinck@wwu.de
%   $Date: 2016/05/10 $

% tidy up memory and windows before starting
clear; close all; clc;

% get all subdirectories
addpath(genpath(pwd));

% load the data
data = loadDynamicData('data/dynamic/horst2.tif');

% set rescaling factor for dapi channel
scale = 0.5;

% set resolution for data in micrometers
resolution = [1.29/scale, 1.29/scale, 20];

% initialize container to hold segmented cells
segmentedCells = zeros(round(size(data,1) * scale), round(size(data,2) * scale));

for t=1:size(data,4)

    % rescale image size using trilinear interpolation for higher speed
    for i=1:size(data,3)
        mCherry_resized(:,:,i) = imresize(data(:,:,i,t), scale);
    end
    
    % compute maximum intensity projection
    MIP = computeMIP(mCherry_resized);
    
    % segment cells -> TODO: Blur due to PSF
    segmentedCells(:,:,t) = segmentCells2D(MIP, resolution);
    
     % visualize result for debugging
    slideShow(MIP,segmentedCells(:,:,t));
    
end

% visualize segmentations over time
figure;
for t=1:size(data,4)
   imagesc(segmentedCells(:,:,t)); pause(0.15); 
end

% save result
save('dynamicCells_segmented.mat','segmentedCells');