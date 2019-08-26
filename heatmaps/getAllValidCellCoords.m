function [ allCellCoordsGrid, allCellCoords ] = getAllValidCellCoords(sizeAcc,fileNames,numberOfResults,tole,resultsPathAccepted, handledChannel)
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
if ( strcmp(handledChannel, 'mCherry') )
    for result = 1:numberOfResults
        % Load result data
        load([resultsPathAccepted,'/',fileNames{result,1}])

        % Get all cell center coordinates
        allCellCoords = horzcat(allCellCoords, gatheredData.registered.cellCoordinates);
        %allCellCoords = horzcat(allCellCoords, transformCoordinates(gatheredData.registered.cellCoordinates', [0,0,0]', inv(gatheredData.registered.transformation_full), [0,0,0]'));
    end
elseif (strcmp(handledChannel, 'DAPI') )
    for result = 1:numberOfResults
        % Load result data
        load([resultsPathAccepted,'/',fileNames{result,1}])

        % Get all cell center coordinates
        allCellCoords = horzcat(allCellCoords, gatheredData.registered.nucleiCoordinates);
        %allCellCoords = horzcat(allCellCoords, transformCoordinates(gatheredData.registered.nucleiCoordinates', [0,0,0]', inv(gatheredData.registered.transformation_full), [0,0,0]'));
    end
elseif (strcmp(handledChannel, 'GFP') )
    for result = 1:numberOfResults
        % Load result data
        load([resultsPathAccepted,'/',fileNames{result,1}])

        % Get all cell center coordinates
        allCellCoords = horzcat(allCellCoords, gatheredData.registered.landmarkCentCoords);
        %allCellCoords = horzcat(allCellCoords, transformCoordinates(gatheredData.registered.landmarkCentCoords', [0,0,0]', inv(gatheredData.registered.transformation_full), [0,0,0]'));
    end
end

% -- 2. Step --%
% Ignore all that are out of the domain
allCellCoords(:,sum(abs(allCellCoords)>1)>=1) = [];

% -- 3. Step --%
% Compute norm of each column
normOfCoordinates = sqrt(sum(allCellCoords.^2,1));

% Ignore all coordinates outside the sphere with a tolerance tole
allCellCoords(:,normOfCoordinates > 1+tole) = [];
normOfCoordinates(:,normOfCoordinates > 1+tole) = [];

% -- 4. Step --% only for mCherry channel
% Normalize the coordinates that are too big but in tolerance
% if ( strcmp(handledChannel, 'mCherry') )
%     allCellCoordsGrid(:,(normOfCoordinates < 1+tole) == (normOfCoordinates > 1)) ...
%         = allCellCoordsGrid(:,(normOfCoordinates < 1+tole) == (normOfCoordinates > 1))...
%         ./repmat(normOfCoordinates(:,(normOfCoordinates < 1+tole) == (normOfCoordinates > 1)),[3,1]);
% end

% -- 5. Step --%
% Get rounded cell centroid coordinates
allCellCoordsGrid = round(...
    (allCellCoords + repmat([1;1;1], 1, size(allCellCoords,2)))...
    * sizeAcc / 2 );
allCellCoordsGrid(allCellCoordsGrid==0)=1;
end

