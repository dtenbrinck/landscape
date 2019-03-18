function [ allCellCoords_under, allCellCoords_in, allCellCoords_over ] = getAllValidCellCoords_shells(sizeAcc,fileNames,numberOfResults,tole,resultsPathAccepted)
%% DESCRIPTION

% This function gets all PGCs under, in and above the shell with the most landmark coordinates. 

%% PARAMETERS (add to parameter script and delete soon)

shellThickness = 0.0608;
shellShiftWidth = 0.01216;

%% MAIN CODE

% Initialize all coordinates of PGC cell centers
allCellCoords_under = double.empty(3,0); % PGCs under landmark shell will be saved here
allCellCoords_in = double.empty(3,0); % PGCs in landmark shell will be saved here
allCellCoords_over = double.empty(3,0); % PGCs over landmark shell will be saved here
radii = zeros(2,numberOfResults);

for result = 1:numberOfResults
    %Load result data
    load([resultsPathAccepted,'/',fileNames{result,1}])

    %get landmark shell
    %the matrix radii will have the maximum radii in the
    %first row and the minimum radii in the second row. The i-th column refers to
    %the i-th embryo
    landmarkCoords = gatheredData.registered.landmarkCentCoords; 
    landmarkCoords = landmarkCoords';
    
    %compute all shells containing landmark coordinates depending on thickness and shift width
    shells = computeShells_Pia(landmarkCoords', shellThickness, shellShiftWidth);
    
    %get amount of landmark cells per shell
    landmarkCellsPerShell = zeros(1,size(shells,2));  
        for j = 1: size(shells,2)
            landmarkCellsPerShell(j) = size(shells{j},2);
        end    

    %get the shell with the most landmark cells, TODO:What if there is more than one shell?      
    [M,I] = max(landmarkCellsPerShell);
    landmarkshell = I(1);
          
    %get radii defining landmark shell
    radii(1,result) = 1 - landmarkshell*shellShiftWidth; % for now we save all radii, but we don't need this later
    radii(2,result) = radii(1,result) - shellThickness;
    min_radius = radii(2,result);
    max_radius = radii(1,result);
    
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
 

    % Get all cell center coordinates
    allCellCoords_under = horzcat(allCellCoords_under, cells_under);
    allCellCoords_in = horzcat(allCellCoords_in, cells_in);
    allCellCoords_over = horzcat(allCellCoords_over, cells_over);    
end 

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

