function [ registeredData ] = registerData( processedData, resolution, registrationMatrix, ellipsoid, samples_cube )

% register processed data using cubic interpolation
[registeredData.GFP, ~] = transformVoxelData(processedData.GFP, resolution, registrationMatrix, ellipsoid.center, samples_cube, 'cubic');
[registeredData.mCherry, ~] = transformVoxelData(processedData.mCherry, resolution, registrationMatrix, ellipsoid.center, samples_cube, 'cubic');
[registeredData.Dapi, ~] = transformVoxelData(processedData.Dapi, resolution, registrationMatrix, ellipsoid.center, samples_cube, 'cubic');

% register segmentations using nearest neighbor interpolation
[registeredData.landmark, ~] = transformVoxelData(processedData.landmark, resolution, registrationMatrix, ellipsoid.center, samples_cube, 'nearest');
[registeredData.cells, ~] = transformVoxelData(processedData.cells, resolution, registrationMatrix, ellipsoid.center, samples_cube, 'nearest');

% register cell coordinates accordingly
processedData.cellCoordinates(1,:) = processedData.cellCoordinates(1,:)*resolution(2);
processedData.cellCoordinates(2,:) = processedData.cellCoordinates(2,:)*resolution(1);
processedData.cellCoordinates(3,:) = processedData.cellCoordinates(3,:)*resolution(3);
registeredData.cellCoordinates = transformCoordinates(processedData.cellCoordinates', ellipsoid.center, registrationMatrix^-1, [0; 0; 0]);
end

