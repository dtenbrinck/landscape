function [cells, centCoords] = blobSegmentCells( data, p )

% Segmentation of the cells with blob segmentation


% Preallocation
thresholdValue = zeros(1,size(data,3));
binaryImage = zeros(size(data));
X = zeros(size(data));

% Check that user has the Image Processing Toolbox installed.
hasIPT = license('test', 'image_toolbox');
if ~hasIPT
    % User does not have the toolbox installed.
    message = sprintf('Sorry, but you do not seem to have the Image Processing Toolbox.\nDo you want to try to continue anyway?');
    reply = questdlg(message, 'Toolbox missing', 'Yes', 'No', 'Yes');
    if strcmpi(reply, 'No')
        % User said No, so exit.
        return;
    end
end

% Threshold the image to get a binary image (only 0's and 1's) of class "logical."
for i = 1 : size(data,3)
    thresholdValue(i) = kittler_thresholding(data(:,:,i), ones(size(data)));
    binaryImage(:,:,i) = data(:,:,i) > thresholdValue(i);
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
    allowableIntensityIndexes = allBlobIntensities > (0.5 * mean(allBlobIntensities)); % Take objects with low intensity.
    allowableAreaIndexes = allBlobAreas > 20; % Take the small objects.
    keeperIndexes = find(allowableIntensityIndexes & allowableAreaIndexes);
    % Extract only those blobs that meet our criteria, and
    % eliminate those blobs that don't meet our criteria.
    keeperBlobsImage = ismember(labeledImage(:,:,j), keeperIndexes);
    
    % Now use the keeper blobs as a mask on the original image.
    maskedImageDime = data(:,:,j); % Simply a copy at first.
    maskedImageDime(~keeperBlobsImage) = 0;  % Set all non-keeper pixels to zero.
    
    X(:,:,j) = maskedImageDime;
    
end

% Identify the layers of the cells
cc = bwconncomp(X);
cells = zeros(size(data));
j = 1;
for i = 1 : cc.NumObjects
    pixelList = cc.PixelIdxList{i};
    if length(pixelList) > p.cellSize
        cellObjects{j} = pixelList;
        j = j + 1;
    end
end

for j=1:length(cellObjects)
    currentCell = zeros(size(data));
    currentCell(cellObjects{j}) = 1;
    currentCell = currentCell .* data;
    
    maxSlice = 2;
    maxValue = -1;
    for slice = 2:size(data,3)-1
        if max(max(currentCell(:,:,slice))) > maxValue
            maxSlice = slice;
            maxValue = max(max(currentCell(:,:,slice)));
        end
    end
    
    sliceMask = zeros(size(data));
    sliceMask(:,:,maxSlice) = 1;
    
    currentCell = currentCell .* sliceMask;
    cells(currentCell > 0) = 1;
end

cc = bwconncomp(cells);
S = regionprops(cc,'centroid');
centCoords = round(reshape([S.Centroid],[3,numel([S.Centroid])/3]));

end