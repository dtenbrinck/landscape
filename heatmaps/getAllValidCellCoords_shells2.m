
function [ allCellCoords ] = getAllValidCellCoords_shells2(sizeAcc,fileNames,numberOfResults,tole,resultsPathAccepted)
%% DESCRIPTION

%This function gets all PGCs under, in and above a specific shell. Whe
%shell can be defined by min and max radius in the parameter section below.

%% PARAMETERS (add to parameter script and delete soon)

 min_radius = 0.7;
 max_radius = 0.8;

%% MAIN CODE

% Initialize all coordinates of PGC cell centers
allCellCoords = double.empty(3,0);
radii = zeros(2,numberOfResults);

for result = 1:numberOfResults
    %Load result data
    load([resultsPathAccepted,'/',fileNames{result,1}])
 
    % Get all cell center coordinates
    allCellCoords = horzcat(allCellCoords, gatheredData.registered.cellCoordinates);
end 

 normOfCoordinates = sqrt(sum(gatheredData.registered.cellCoordinates.^2,1));
    
    %get all PGC cells under landmark shell
    cells_under = gatheredData.registered.cellCoordinates;
    normOfCoordinates_under = normOfCoordinates;
    cells_under(:, normOfCoordinates_under > min_radius) = [];
    normOfCoordinates_under(:,normOfCoordinates_under > min_radius) = [];
 
    %get all PGC cells in landmark shell
    cells_in = gatheredData.registered.cellCoordinates;
    normOfCoordinates_in = normOfCoordinates;
    cells_in(:, normOfCoordinates_in < min_radius) = [];
    normOfCoordinates_in(:,normOfCoordinates_in < min_radius) = [];
    cells_in(:, normOfCoordinates_in > max_radius) = [];
    normOfCoordinates_in(:,normOfCoordinates_in > max_radius) = [];
    
    %get all PGC cells over landmark shell
    cells_over = gatheredData.registered.cellCoordinates;
    normOfCoordinates_over = normOfCoordinates;
    cells_over(:, normOfCoordinates_over < max_radius) = [];
    normOfCoordinates_over(:,normOfCoordinates_over < max_radius) = [];
    cells_over(:, normOfCoordinates_over > 1) = [];
    normOfCoordinates_over(:,normOfCoordinates_over > 1) = [];

% Get rounded cell centroid coordinates
allCellCoords_under = round(...
    (allCellCoords_under + repmat([1;1;1], 1, size(allCellCoords_under,2)))...
    * sizeAcc / 2 );
allCellCoords_under(allCellCoords_under==0)=1;

allCellCoords_in = round(...
    (allCellCoords_in + repmat([1;1;1], 1, size(allCellCoords_in,2)))...
    * sizeAcc / 2 );
allCellCoords_in(allCellCoords_in==0)=1;

allCellCoords_over = round(...
    (allCellCoords_over + repmat([1;1;1], 1, size(allCellCoords_over,2)))...
    * sizeAcc / 2 );
allCellCoords_over(allCellCoords_over==0)=1;

end
