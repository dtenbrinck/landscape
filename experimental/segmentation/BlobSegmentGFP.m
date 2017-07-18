function landmark = BlobSegmentGFP( data )

clear all
clc
close all


processedData = importdata('processedData15Blob.mat');
data = processedData.GFP;
p = importdata('p.mat');
captionFontSize = 14;

% Preallocation
thresholdValue = zeros(1,20);
% binaryImage = zeros(384,510,20);
landmark = zeros(size(data,1),size(data,2),size(data,3));

% Laplacian of Gaussian filter
hsize = [50,50];
sigma = 9;
alpha = 0.2;
gauss = fspecial('gaussian', hsize, sigma);
blurredImage = imfilter(data, gauss, 'replicate');
laplace = fspecial('laplacian', alpha);
blurredImage = imfilter(blurredImage, laplace, 'replicate');
% lap_gauss = fspecial('log', hsize, sigma);
% blurredImage = imfilter(data,lap_gauss,'replicate');
% blurredImage = mat2gray(blurredImage);
% blurredImage = double(uint8(255*mat2gray(blurredImage)));


% Threshold the image to get a binary image (only 0's and 1's) of class "logical."
for i = 1 : size(data,3)
    thresholdValue(i) = kittler_thresholding(blurredImage(:,:,i), ones(size(blurredImage)));
    binaryImage(:,:,i) = blurredImage(:,:,i) > thresholdValue(i);
end

% Do a "hole fill" to get rid of any background pixels or "holes" inside the blobs.
binaryImage = imfill(binaryImage, 'holes');

% Identify individual blobs by seeing which pixels are connected to each other.
% Do connected components labeling with either bwlabel() or bwconncomp().
labeledImage = zeros(size(binaryImage));
for i = 1 : size(data,3)
    labeledImage(:,:,i) = bwlabel(binaryImage(:,:,i), 8);
end

for j = 1 : size(data,3)    % Loop over all layers.
    % Select certain blobs based using the ismember() function.
    blobMeasurements = regionprops(labeledImage(:,:,j), data(:,:,j), 'all');
    allBlobIntensities = [blobMeasurements.MeanIntensity];
    allBlobAreas = [blobMeasurements.Area];
    % Get a list of the blobs that meet our criteria and we need to keep.
    allowableIntensityIndexes = allBlobIntensities > 0;%(0.7 * mean(allBlobIntensities)); % Take objects with low intensity.
    allowableAreaIndexes = allBlobAreas > 1; % Take the small objects.
    keeperIndexes = find(allowableIntensityIndexes & allowableAreaIndexes);
    % Extract only those blobs that meet our criteria, and
    % eliminate those blobs that don't meet our criteria.
    keeperBlobsImage = ismember(labeledImage(:,:,j), keeperIndexes);
    
    % Now use the keeper blobs as a mask on the original image.
    maskedImageDime = data(:,:,j); % Simply a copy at first.
    maskedImageDime(~keeperBlobsImage) = 0;  % Set all non-keeper pixels to zero.
    
    landmark(:,:,j) = maskedImageDime;
    
end




% % % % Display old segmentation
% % % landmark2 = segmentGFP( data, p.GFPseg, p.resolution );
% % % subplot(1, 2, 1);
% % % image(computeMIP(data));
% % % title('Old segmentation', 'FontSize', captionFontSize); 
% % % axis image;
% % % hold on;
% % % boundaries = bwboundaries(computeMIP(landmark2));
% % % numberOfBoundaries = size(boundaries,1);
% % % for k = 1 : numberOfBoundaries
% % %     thisBoundary = boundaries{k};
% % %     plot(thisBoundary(:,2), thisBoundary(:,1), 'g', 'LineWidth', 2);
% % % end
% % % hold off;

% Display new segmentation
% subplot(1, 2, 2);
% image(computeMIP(data));
image(data(:,:,1))
title('New segmentation', 'FontSize', captionFontSize); 
axis image;
hold on;
% boundaries = bwboundaries(computeMIP(landmark));
boundaries = bwboundaries(binaryImage(:,:,1));
numberOfBoundaries = size(boundaries,1);
% for k = 1 : numberOfBoundaries
%     thisBoundary = boundaries{k};
%     plot(thisBoundary(:,2), thisBoundary(:,1), 'g', 'LineWidth', 2);
% end
thisBoundary = boundaries{1};
plot(thisBoundary(:,2), thisBoundary(:,1), 'g', 'LineWidth', 2);
hold off;

end
