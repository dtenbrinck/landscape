function [ registeredData ] = registerData( processedData, resolution, registrationMatrix, ellipsoid, samples_cube )

% register processed data using cubic interpolation
if isfield(processedData, 'GFP')
    [registeredData.GFP, ~] = transformVoxelData(single(processedData.GFP), resolution, registrationMatrix, ellipsoid.center, samples_cube, 'cubic');
end
if isfield(processedData, 'mCherry')
    [registeredData.mCherry, ~] = transformVoxelData(single(processedData.mCherry), resolution, registrationMatrix, ellipsoid.center, samples_cube, 'cubic');
end
if isfield(processedData, 'Dapi')
    [registeredData.Dapi, ~] = transformVoxelData(single(processedData.Dapi), resolution, registrationMatrix, ellipsoid.center, samples_cube, 'cubic');
end

% register segmentations using nearest neighbor interpolation

if isfield(processedData, 'landmark')
    [registeredData.landmark, ~] = transformVoxelData(single(processedData.landmark), resolution, registrationMatrix, ellipsoid.center, samples_cube, 'nearest');
end
if isfield(processedData, 'cells')
    [registeredData.cells, ~] = transformVoxelData(single(processedData.cells), resolution, registrationMatrix, ellipsoid.center, samples_cube, 'nearest');
end
if isfield(processedData, 'nuclei') % check for backward compatibilty
    [registeredData.nuclei, ~] = transformVoxelData(single(processedData.nuclei), resolution, registrationMatrix, ellipsoid.center, samples_cube, 'nearest');
end

if isfield(processedData, 'landmarkCentCoords') %%PIA
    % register landmark coordinates accordingly
    processedData.landmarkCentCoords(1,:) = processedData.landmarkCentCoords(1,:)*resolution(2);
    processedData.landmarkCentCoords(2,:) = processedData.landmarkCentCoords(2,:)*resolution(1);
    processedData.landmarkCentCoords(3,:) = processedData.landmarkCentCoords(3,:)*resolution(3);
    registeredData.landmarkCentCoords = transformCoordinates(processedData.landmarkCentCoords', ellipsoid.center, registrationMatrix^-1, [0; 0; 0]);
end

if isfield(processedData, 'cellCoordinates')
    % register cell coordinates accordingly
    processedData.cellCoordinates(1,:) = processedData.cellCoordinates(1,:)*resolution(2);
    processedData.cellCoordinates(2,:) = processedData.cellCoordinates(2,:)*resolution(1);
    processedData.cellCoordinates(3,:) = processedData.cellCoordinates(3,:)*resolution(3);
    registeredData.cellCoordinates = transformCoordinates(processedData.cellCoordinates', ellipsoid.center, registrationMatrix^-1, [0; 0; 0]);
elseif isfield(processedData, 'dynamic')
    % register dynamic cell coordinates accordingly
    % We save the cell coordinates also in
    % gathered.registered.cellCoordinates to ensure that further
    % evaluations on the cellCoordinates works well.
    % Moreover, we do not scale with the resolution parameter as we did not
    % scale the coordinates from the original data either.
    registeredData.cellCoordinates = transformCoordinates(processedData.dynamic.cellCoordinates', ellipsoid.center, registrationMatrix^-1, [0; 0; 0]);
end

if isfield(processedData, 'nucleiCoordinates')
    % register nuclei coordinates accordingly
    processedData.nucleiCoordinates(1,:) = processedData.nucleiCoordinates(1,:)*resolution(2);
    processedData.nucleiCoordinates(2,:) = processedData.nucleiCoordinates(2,:)*resolution(1);
    processedData.nucleiCoordinates(3,:) = processedData.nucleiCoordinates(3,:)*resolution(3);
    registeredData.nucleiCoordinates = transformCoordinates(processedData.nucleiCoordinates', ellipsoid.center, registrationMatrix^-1, [0; 0; 0]);
end

end

