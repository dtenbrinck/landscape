function [ allCellCoords_registered, allCellCoords_unregistered ] = getAllValidCellCoords(sizeAcc,fileNames,numberOfResults,tole,resultsPathAccepted)
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
allCellCoords_registered = double.empty(3,0);
allCellCoords_unregistered = double.empty(3,0);

% -- 1. Step --%
for result = 1:numberOfResults
    % Load result data
    load([resultsPathAccepted,'/',fileNames{result,1}])
    
    
        % Get all cell center coordinates for registered embryos
        allCellCoords_registered = horzcat(allCellCoords_registered, gatheredData.registered.cellCoordinates);
        
        % Get all cell center coordinates for unregistered embryos
        allCellCoords_unregistered = horzcat(allCellCoords_unregistered, gatheredData.processed.cellCoordinates);
        
end
    
% -- 2. Step --%
% Ignore all that are out of the domain
%allCellCoords(:,sum(abs(allCellCoords)>1)>=1) = [];

% -- 3. Step --%
% Compute norm of each column
normOfCoordinates_registered = sqrt(sum(allCellCoords_registered.^2,1));
%normOfCoordinates_unregistered = sqrt(sum(allCellCoords_unregistered.^2,1));

% Ignore all coordinates outside the sphere with a tolerance tole
%allCellCoords_registered(:,normOfCoordinates_registered > 1+tole) = [];
allCellCoords_registered(:,normOfCoordinates_registered > 2) = [];
%normOfCoordinates(:,normOfCoordinates > 1+tole) = [];

% -- 4. Step --%
% Normalize the coordinates that are too big but in tolerance
%allCellCoords(:,(normOfCoordinates < 1+tole) == (normOfCoordinates > 1)) ...
%    = allCellCoords(:,(normOfCoordinates < 1+tole) == (normOfCoordinates > 1))...
%    ./repmat(normOfCoordinates(:,(normOfCoordinates < 1+tole) == (normOfCoordinates > 1)),[3,1]);

% -- 5. Step --%
% Get rounded cell centroid coordinates in [1 sizeAcc]^3
%allCellCoords = round((allCellCoords * sizeAcc / 2 ))...
%    + repmat([1;1;1], 1, size(allCellCoords,2)) ;
%allCellCoords(allCellCoords==0)=1;


end

