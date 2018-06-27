function [ registeredData ] = registerData( processedData, resolution, registrationMatrix, ellipsoid, samples_cube )

% register processed data using cubic interpolation
[registeredData.GFP, ~] = transformVoxelData(single(processedData.GFP), resolution, registrationMatrix, ellipsoid.center, samples_cube, 'cubic');
% [registeredData.mCherry, ~] = transformVoxelData(single(processedData.mCherry), resolution, registrationMatrix, ellipsoid.center, samples_cube, 'cubic');
[registeredData.Dapi, ~] = transformVoxelData(single(processedData.Dapi), resolution, registrationMatrix, ellipsoid.center, samples_cube, 'cubic');

% register segmentations using nearest neighbor interpolation
[registeredData.landmark, ~] = transformVoxelData(single(processedData.landmark), resolution, registrationMatrix, ellipsoid.center, samples_cube, 'nearest');
% [registeredData.cells, ~] = transformVoxelData(single(processedData.cells), resolution, registrationMatrix, ellipsoid.center, samples_cube, 'nearest');
if isfield(processedData, 'nuclei') % check for backward compatibilty
    [registeredData.nuclei, ~] = transformVoxelData(single(processedData.nuclei), resolution, registrationMatrix, ellipsoid.center, samples_cube, 'nearest');
end

% register cell coordinates accordingly
processedData.cellCoordinates(1,:) = processedData.cellCoordinates(1,:)*resolution(2);
processedData.cellCoordinates(2,:) = processedData.cellCoordinates(2,:)*resolution(1);
processedData.cellCoordinates(3,:) = processedData.cellCoordinates(3,:)*resolution(3);
registeredData.cellCoordinates = transformCoordinates(processedData.cellCoordinates', ellipsoid.center, registrationMatrix^-1, [0; 0; 0]);
end

