% INITIALIZATION
clear; clc; close all;

% add path for parameter setup
addpath('./parameter_setup/');

% load necessary variables
p = initializeScript('process');

% Select the file
dname = uigetfile(p.dataPath,'Please select the data!'); % Select all files to see the data

% Import the Data
info = imfinfo([p.dataPath '\' dname]);
OriginalData = [];
data = [];
numberOfImages = length(info);
for k = 1:numberOfImages
    currentImage = imread([p.dataPath '\' dname], k, 'Info', info);
    OriginalData(:,:,k) = imresize(im2double(currentImage),0.3);   % 30 percent scale
end 

for i = 1 : size(OriginalData,3)
    data(:,:,i) = imgaussfilt(OriginalData(:,:,i),0.5);
end

% Preallocation
thresholdValue = zeros(1,size(data,3));
binaryImage = zeros(size(data));
X = zeros(size(data));

% Compute the threshold value
thresholdValue = graythresh(data(:));
% thresholdValue = 0.038; % Set a specific threshold value

% Threshold the image to get a binary image (only 0's and 1's) of class "logical."
for i = 1 : size(data,3)
    binaryImage(:,:,i) = data(:,:,i) > thresholdValue;
end

% % Do a "hole fill" to get rid of any background pixels or "holes" inside the blobs.
SE = strel('sphere',10);
closedBinaryImage = imclose(binaryImage,SE);

% Identify individual blobs by seeing which pixels are connected to each other.
% Do connected components labeling with either bwlabel() or bwconncomp().
labeledImage = zeros(size(closedBinaryImage));
for i = 1 : size(data,3)
    labeledImage(:,:,i) = bwlabel(closedBinaryImage(:,:,i), 8);
end

for j = 1 : size(data,3)    % Loop over all layers.
    % Select certain blobs based using the ismember() function.
    blobMeasurements = regionprops(labeledImage(:,:,j), data(:,:,j), 'all');
    allBlobIntensities = [blobMeasurements.MeanIntensity];
    allBlobAreas = [blobMeasurements.Area];
    % Get a list of the blobs that meet our criteria and we need to keep.
    allowableAreaIndexes = allBlobAreas > 120; % Take the small objects.
    keeperIndexes = find(allowableAreaIndexes);
    % Extract only those blobs that meet our criteria, and
    % eliminate those blobs that don't meet our criteria.
    keeperBlobsImage = ismember(labeledImage(:,:,j), keeperIndexes);
    % Now use the keeper blobs as a mask on the original image.
    maskedImageDime = data(:,:,j); % Simply a copy at first.
    maskedImageDime(~keeperBlobsImage) = 0;  % Set all non-keeper pixels to zero.
    
    X(:,:,j) = maskedImageDime;
    
end

binaryX = X > 0;

% Create and save a gif
for t=1:80
 
    imshow(OriginalData(:,:,t));
    axis image;
    hold on;
    boundaries = bwboundaries(binaryX(:,:,t));
    numberOfBoundaries = size(boundaries, 1);
    for k = 1 : numberOfBoundaries
        thisBoundary = boundaries{k};
        plot(thisBoundary(:,2), thisBoundary(:,1), 'g', 'LineWidth', 2);
    end
    hold off;
 
    frame = getframe(1);
    im = frame2im(frame);
    [imind,cm] = rgb2ind(im,256);
    outfile = [p.resultsPath '\' dname '_atlas_segmentation.gif'];
 
    % On the first loop, create the file. In subsequent loops, append.
    if t==1
        imwrite(imind,cm,outfile,'gif','DelayTime',0.5,'loopcount',inf);
    else
        imwrite(imind,cm,outfile,'gif','DelayTime',0.5,'writemode','append');
    end
 
end

% Save the segmentation
filename_original_data = [p.resultsPath '\' dname(1:end-4) '_original_data'];
save(filename_original_data,'OriginalData');
filename_segmentation = [p.resultsPath '\' dname(1:end-4) '_atlas_segmentation'];
save(filename_segmentation,'binaryX');