function referenceLandmark = computeReferenceLandmark(fileNames,numberOfResults, ...
    parameter)
fprintf('Computing refernce landmark ...\n');
referenceLandmark.MIP = zeros(parameter.samples_cube, ...
    parameter.samples_cube);
referenceLandmark.coords = zeros(parameter.samples_cube,...
    parameter.samples_cube,parameter.samples_cube);
f=figure('pos',[10 10 600 750], 'Name', 'Plotting unregistered and registered landmark');% TODO delete this again
for resultCounter = 1:numberOfResults
    load([parameter.resultsPathAccepted,'/',fileNames{resultCounter,1}])
    referenceLandmark.MIP = referenceLandmark.MIP + ...
        gatheredData.registered.landmarkMIP;
    unregisteredLandmarkCoords = gatheredData.processed.landmark;
    registeredLandmarkCoords = transformVoxelData( ...
        single(unregisteredLandmarkCoords), parameter.resolution, ...
        gatheredData.registered.transformation_full, ...
        gatheredData.processed.ellipsoid.center, ...
        parameter.samples_cube, 'nearest');
    referenceLandmark.coords = referenceLandmark.coords + registeredLandmarkCoords;
    plotScatteredLandmark(registeredLandmarkCoords, unregisteredLandmarkCoords,numberOfResults, resultCounter);% TODO delete this again
end

saveas(f, [parameter.resultsPath ,'/heatmaps/Landmarks'], parameter.option.heatmaps.saveas{1});% TODO delete this again
% normalization: only 0 or 1 in return values indicating where cells for
% the landmark where found
referenceLandmark.MIP = referenceLandmark.MIP > 0;
referenceLandmark.coords = referenceLandmark.coords > 0;

end

% TODO delete this again
function plotScatteredLandmark(registeredLandmarkCoords, unregisteredLandmarkCoords, numberOfResults, resultCounter)
if (numberOfResults <6)
    subplot(numberOfResults,2, 2*resultCounter-1);
    indices = find(unregisteredLandmarkCoords > 0);
    [tmpy, tmpx, tmpz] = ind2sub(size(unregisteredLandmarkCoords), indices);
    scatter3(tmpx,tmpy,tmpz,'.');
    title('Unregistered Landmark');
    xlim([0, size(unregisteredLandmarkCoords,1)]);
    ylim([0, size(unregisteredLandmarkCoords,2)]);
    zlim([0, size(unregisteredLandmarkCoords,3)]);
    view(3);
    subplot(numberOfResults,2, 2*resultCounter);
    indices = find(registeredLandmarkCoords > 0);
    [tmpy, tmpx, tmpz] = ind2sub(size(registeredLandmarkCoords), indices);
    scatter3(tmpx,tmpy,tmpz,'.');
    xlim([0, size(registeredLandmarkCoords,1)]);
    ylim([0, size(registeredLandmarkCoords,2)]);
    zlim([0, size(registeredLandmarkCoords,3)]);
    title('Registered Landmark');
    view(3);
else
    fprintf('Too many inputs, no plotting of landmark!\n');
end
end