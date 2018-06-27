function [ allCellCoords ] = getAllValidCellCoords_DAPI(sizeAcc,fileNames,numberOfResults,tole,resultsPathAccepted)
% This function computes the valid cell coordinates for the heatmap.
% This will be done in multiple steps:
% 1. load and gather all cell coordinates.
% 2. Ignore all cells that are not in the domain.
% 3. Ignore all cells with a tolerance outside of the domain.
% 4. Normalize all cells that are within the sphere with a tolerance.
% 5. Put cells into the correct grid.

%% MAIN CODE
% -- 0. Step --%
% Initialize all coordinates of cell centers
allCellCoords = double.empty(3,0);

% -- 1. Step --%
for result = 1:numberOfResults
    % Load result data
    load([resultsPathAccepted,'/',fileNames{result,1}])
    
    % Get all cell center coordinates
    allCellCoords = horzcat(allCellCoords, gatheredData.registered.nucleiCoordinates);
end

end

