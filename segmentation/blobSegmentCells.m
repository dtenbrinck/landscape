function [cells, centCoords] = blobSegmentCells( data, p, embryoShape )

% Segmentation of the cells with blob segmentation

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

if isfield(p, 'binarization') && strcmp('k-means', p.binarization)
    % use k-means removing background and some noise
    % to get a binary image (only 0's and 1's) of class "logical."
    Xi = k_means_clustering(computeMIP(data), p.k, 'real');
    if ( sum(Xi(:) >= p.k-1) / sum(embryoShape(:)) ) > 0.1
        if (sum(Xi(:) >= p.k) / sum(embryoShape(:)) ) > 0.1
            Xi = k_means_clustering(computeMIP(data), p.k+1, 'real');
            label = p.k+1;
        else
            label = p.k;
        end
    else
        label = p.k-1;
    end
    binaryImage = extend2dTo3dSegmentation(Xi >= label, data);
    %segmentation_count = sum(Xi(:) >= ceil(p.k/2));
    %if segmentation_count/numel(Xi) > 0.015
    %    binaryImage = Xi >= ceil(p.k/2);
    %else
    %    binaryImage = Xi >= floor(p.k/2);
    %end
    %Xi = round(Xi / p.k);
    %binaryImage = Xi == 1;
else
    % use Kittler thresholding (default) to get a binary image (only 0's and 1's) of class "logical."
    binaryImage = zeros(size(data));
    for i = 1 : size(data,3)
        thresholdValue = kittler_thresholding(data(:,:,i), ones(size(data)));
        binaryImage(:,:,i) = data(:,:,i) > thresholdValue;
    end
end

% filter segmentation using mask for embryo
binaryImage = binaryImage & repmat(embryoShape,1,1,size(binaryImage,3));

% DEBUG
%figure; imagesc(computeMIP(data)); hold on; contour(computeMIP(binaryImage),[0.5, 0.5], 'r'); hold off

start_points = binaryImage;
CC = bwconncomp(start_points);
S = regionprops(CC,'centroid');
centCoords = round(cat(1,S(:).Centroid));

% DEBUG
%figure(4); imagesc(computeMIP(data)); hold on; plot(centCoords(:,1), centCoords(:,2), 'r*'); hold off;

% Filter centCoords via kd-tree (resolution dependent)

options.show_segmentation_result = false;
options.numberAngles = 180;
options.method = 'Chan-Vese-L1'; % Chan-Vese-L1 % Chan-Vese-L2 % Sobel % Chan-Vese-L1+Sobel % Malon % Chan-Vese-L1-inc % Chan-Vese-L2-inc
options.lambda = 2;

%%% extract roi
bbLimit = 20;
segmented_roi = cell(CC.NumObjects,1);
roi = cell(CC.NumObjects,1);
segmentation_2D = zeros(size(data,1), size(data,2));

for i=1:CC.NumObjects
    roi{i} = computeMIP(data(...
        max(1,centCoords(i,2)-bbLimit):min(size(data,1),centCoords(i,2)+bbLimit),...
        max(1,centCoords(i,1)-bbLimit):min(size(data,2),centCoords(i,1)+bbLimit),...
        :));
    options.numberRadii = max(size(roi{i}));
    segmented_roi{i} = segmentCell(roi{i},options);
    segmentation_2D(...
        max(1,centCoords(i,2)-bbLimit):min(size(data,1),centCoords(i,2)+bbLimit),...
        max(1,centCoords(i,1)-bbLimit):min(size(data,2),centCoords(i,1)+bbLimit)) = ...
        segmentation_2D(...
        max(1,centCoords(i,2)-bbLimit):min(size(data,1),centCoords(i,2)+bbLimit),...
        max(1,centCoords(i,1)-bbLimit):min(size(data,2),centCoords(i,1)+bbLimit))...
        | segmented_roi{i};
    % DEBUG
    %figure(1); imagesc(roi{i}); hold on; contour(segmented_roi{i}, [0.5, 0.5], 'r'); hold off;
    %figure(2); imagesc(computeMIP(data)); hold on; plot(centCoords(:,1), centCoords(:,2), 'r*'); plot(centCoords(i,1), centCoords(i,2), 'g*'); hold off;
    %pause(1);
end


cells = extend2dTo3dSegmentation(segmentation_2D, data);
%binaryImage = segmentation3D;
% DEBUG
% figure;
% for i=1:CC.NumObjects
%     imagesc(roi{i});
%     hold on;
%     contour(segmented_roi{i}, [0.5, 0.5], 'r');
%     hold off;
%     pause(2);
% end

% Do a "hole fill" to get rid of any background pixels or "holes" inside the blobs.
%binaryImage = imfill(binaryImage, 'holes');

% Identify individual blobs by seeing which pixels are connected to each other.
% Do connected components labeling with either bwlabel() or bwconncomp().
% labeledImage = zeros(size(binaryImage));
% for i = 1 : size(data,3)
%     labeledImage(:,:,i) = bwlabel(binaryImage(:,:,i), 8);
% end
%
% meanIntensityFactor = 0.5;
% minimalAreaSize = 20;
% for j = 1 : size(data,3)    % Loop over all layers.
%     % Select certain blobs based using the ismember() function.
%     blobMeasurements = regionprops(labeledImage(:,:,j), data(:,:,j), 'MeanIntensity', 'Area' );
%     allBlobIntensities = [blobMeasurements.MeanIntensity];
%     allBlobAreas = [blobMeasurements.Area];
%     % Get a list of the blobs that meet our criteria and we need to keep.
%     allowableIntensityIndexes = allBlobIntensities > (meanIntensityFactor * mean(allBlobIntensities)); % remove objects with low intensity.
%     allowableAreaIndexes = allBlobAreas > minimalAreaSize; % remove small objects.
%     keeperIndexes = find(allowableIntensityIndexes & allowableAreaIndexes);
%     % Extract only those blobs that meet our criteria, and
%     % eliminate those blobs that don't meet our criteria.
%     keeperBlobsImage = ismember(labeledImage(:,:,j), keeperIndexes);
%
%     % Now use the keeper blobs as a mask on the original image.
%     maskedImageDime = data(:,:,j); % Simply a copy at first.
%     maskedImageDime(~keeperBlobsImage) = 0;  % Set all non-keeper pixels to zero.
%
%     X(:,:,j) = maskedImageDime;
% end
%
% % Identify the layers of the cells
% cc = bwconncomp(X);
% cells = zeros(size(data));
% j = 1;
% for i = 1 : cc.NumObjects
%     pixelList = cc.PixelIdxList{i};
%      if length(pixelList) > p.cellSize
%         cellObjects{j} = pixelList;
%         j = j + 1;
%     end
% end
%
% for j=1:length(cellObjects)
%     currentCell = zeros(size(data));
%     currentCell(cellObjects{j}) = 1;
%     currentCell = currentCell .* data;
%
%     maxSlice = 2;
%     maxValue = -1;
%     for slice = 2:size(data,3)-1
%         if max(max(currentCell(:,:,slice))) > maxValue
%             maxSlice = slice;
%             maxValue = max(max(currentCell(:,:,slice)));
%         end
%     end
%
%     sliceMask = zeros(size(data));
%     sliceMask(:,:,maxSlice) = 1;
%
%     currentCell = currentCell .* sliceMask;
%     cells(currentCell > 0) = 1;
% end

cc = bwconncomp(cells);
S = regionprops(cc,'centroid');
centCoords = round(reshape([S.Centroid],[3,numel([S.Centroid])/3]));

end