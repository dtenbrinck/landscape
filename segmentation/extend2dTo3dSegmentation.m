function segmentation_3D = extend2dTo3dSegmentation(segmentation_2D,data_3D)

full_segmentation = repmat(segmentation_2D,...
                          [1 1 size(data_3D,3)]);


segmentation_3D = zeros(size(full_segmentation));

% remove too small items
% Centroid for all cells
cc = bwconncomp(full_segmentation);
j = 1;
for i = 1:cc.NumObjects
    pixelList = cc.PixelIdxList{i};
    if length(pixelList) > 50
        cellObjects{j} = pixelList;
        j = j+1;
    end
end

for j=1:length(cellObjects)
    currentCell = zeros(size(data_3D));
    currentCell(cellObjects{j}) = 1;
    currentCell = currentCell .* single(data_3D);
    
    maxSlice = 2;
    maxValue = -1;
    for slice = 2:size(data_3D,3)-1
        if max(max(currentCell(:,:,slice))) > maxValue
            maxSlice = slice;
            maxValue = max(max(currentCell(:,:,slice)));
        end
    end
    
    sliceMask = zeros(size(data_3D));
    sliceMask(:,:,maxSlice) = 1;
    
    currentCell = currentCell .* sliceMask;
    segmentation_3D(currentCell > 0) = 1;
end

end