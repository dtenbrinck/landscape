function referenceLandmark = computeReferenceLandmark(fileNames,numberOfResults, ...
    parameter)
fprintf('Computing refernce landmark ...\n');
referenceLandmark.MIP = zeros(256,256);
referenceLandmark.coords = zeros(256,256,256);

for result = 1:numberOfResults
    load([parameter.resultsPathAccepted,'/',fileNames{result,1}])
    referenceLandmark.MIP = referenceLandmark.MIP + ...
        gatheredData.registered.landmarkMIP;
    unregisteredLandmarkCoords = gatheredData.processed.landmark;
    registeredLandmarkCoords = transformVoxelData( ...
        single(unregisteredLandmarkCoords), parameter.resolution, ...
        gatheredData.registered.transformation_full, ...
        gatheredData.processed.ellipsoid.center, ...
        parameter.samples_cube, 'nearest');
    referenceLandmark.coords = referenceLandmark.coords + registeredLandmarkCoords;
end

% normalization: only 0 or 1 in return values indicating where cells for
% the landmark where found
referenceLandmark.MIP = referenceLandmark.MIP > 0;
referenceLandmark.coords = referenceLandmark.coords > 0;

end