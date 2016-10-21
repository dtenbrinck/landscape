function [ transformedData, transformedResolution ] = transformDataToSphere( processedData, resolution, transformationMatrix, ellipsoid, samples_cube )

% transform processed data using cubic interpolation
[transformedData.Dapi, transformedResolution] = ...
    transformVoxelData(processedData.Dapi, resolution, transformationMatrix, ellipsoid.center, samples_cube, 'cubic');
[transformedData.GFP, ~] = ...
    transformVoxelData(processedData.GFP, resolution, transformationMatrix, ellipsoid.center, samples_cube, 'cubic');
[transformedData.mCherry, ~] = ...
    transformVoxelData(processedData.mCherry, resolution, transformationMatrix, ellipsoid.center, samples_cube, 'cubic');

% transform segmentations using nearest neighbor interpolation
[transformedData.cells, ~] = ...
    transformVoxelData(processedData.cells, resolution, transformationMatrix, ellipsoid.center, samples_cube, 'nearest');
[transformedData.landmark, ~] = ...
    transformVoxelData(processedData.landmark, resolution, transformationMatrix, ellipsoid.center, samples_cube, 'nearest');

end

