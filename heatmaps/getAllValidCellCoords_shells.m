
function [ allCellCoords ] = getAllValidCellCoords_shells(sizeAcc,fileNames,numberOfResults,tole,resultsPathAccepted)
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
radii = zeros(2,numberOfResults);
%radii = zeros(2,1);

root_dir = pwd;
parameter = initializeScript('processing', root_dir);

average = [0,0]; %DELETE THIS SOON
var = [0,0];

% -- 1. Step --%
for result = 1:numberOfResults
    %Load result data
    load([resultsPathAccepted,'/',fileNames{result,1}])

% -- 0.1. Step --%
%get landmark shell
%the matrix radii will have the maximum radii in the
%first row and the minimum radii in the second row. The i-th column refers to
%the i-th embryo

%for i = 1:numberOfResults
    landmarkCoords = gatheredData.registered.landmarkCentCoords; %3D coordinates
    landmarkCoords = landmarkCoords';
     %_____________visualization
    % % Sampling sphere
    samples = parameter.samples_sphere;
    [alpha, beta] = meshgrid(linspace(pi,2*pi,samples/2), linspace(0,2*pi,2*samples));
    Xs = sin(alpha) .* sin(beta);
    Ys = cos(beta);
    Zs = cos(alpha) .* sin(beta);
     %save sphere coordinates as N x 3 matrix
    sphereCoordinates = [Xs(:), Ys(:), Zs(:)];
    normOfCoordinates = sqrt(sum(landmarkCoords'.^2,1));
    landmarkInShell = landmarkCoords';
    landmarkInShell(:,normOfCoordinates < 0.6914) = [];
    normOfCoordinates(:,normOfCoordinates < 0.6914) = [];
    landmarkInShell( :,normOfCoordinates > 0.7522) = [];
    normOfCoordinates(:,normOfCoordinates > 0.7522) = [];
    landmarkInShell = landmarkInShell';
   figure; scatter3(sphereCoordinates(:,1),sphereCoordinates(:,2),sphereCoordinates(:,3), 1,'*');
   %view(2);
   hold on
   scatter3(landmarkCoords(:,1),landmarkCoords(:,2),landmarkCoords(:,3), 100,'*');
   hold on
   scatter3(landmarkInShell(:,1),landmarkInShell(:,2),landmarkInShell(:,3), 100,'*');
   view(0,180);
   %view(0,90);
   drawnow;
   %-------------------------

    %landmarkCoords = [1 0 0 ; 0.5 0 0; 0.55 0 0]; % get all Landmark coordinates (TEST)
    %__________________ get all landmark coords, grid coords
    %Ramona/computeReferenceLandmark
    %unregisteredLandmarkCoords = gatheredData.processed.landmark;
    %registeredLandmarkCoords = transformVoxelData( ...
        %single(unregisteredLandmarkCoords), parameter.resolution, ...
        %gatheredData.registered.transformation_full, ...
        %gatheredData.processed.ellipsoid.center, ...
       %parameter.samples_cube, 'nearest');
    %indices = find(registeredLandmarkCoords > 0);
 
    %[tmpy, tmpx, tmpz] = ind2sub(size(registeredLandmarkCoords), indices);
    %landmarkCoords = [tmpy, tmpx, tmpz]; % grid coords, neu
    %scatter3(tmpx,tmpy,tmpz,'.');
    %xlim([0, size(registeredLandmarkCoords,1)]);
    %ylim([0, size(registeredLandmarkCoords,2)]);
    %zlim([0, size(registeredLandmarkCoords,3)]);
    %title('Registered Landmark');
    %view(3);
    
    %compute coordinates of landmark
    %landmark_indices = find(landmarkCoords == 1);
    %landmarkCoords = [sphereCoordinates(landmark_indices,1), sphereCoordinates(landmark_indices,2), sphereCoordinates(landmark_indices,3)];
    
    %as in register data:
    %landmarkCoords(1,:) = landmarkCoords(1,:)*parameter.resolution(2);
    %landmarkCoords(2,:) = landmarkCoords(2,:)*parameter.resolution(1);
    %landmarkCoords(3,:) = landmarkCoords(3,:)*parameter.resolution(3);
    %landmarkCoords = transformCoordinates(landmarkCoords', gatheredData.processed.ellipsoid.center, gatheredData.registered.transformation_full^-1, [0; 0; 0]);
    %__________________
    
    %shells = computeShells_Pia(landmarkCoords, p.option.shellThickness, p.option.shellSHiftWidth, GRIDSIZE); %get all shells depening on thickness and shift width
    shells = computeShells_Pia_alt(landmarkCoords',0.0608, 0.01216); %TEST 3D coords
    %shells = computeShells_Pia(landmarkCoords,0.0608, 0.01216,256); %TEST grid coords
    
    landmarkCellsPerShell = zeros(1,size(shells,2));  
        for j = 1: size(shells,2)
            landmarkCellsPerShell(j) = size(shells{j},2); %get amount of landmark cells per shell
        end    

    [M,I] = max(landmarkCellsPerShell);
    landmarkshell = I(1); %get the shell with the most landmark cells, TODO:What if there is more than one shell?

    %radii(1,i) = 1 - landmarkshell*p.option.shellShiftWidth ; %get radii defining the landmark shell
    radii(1,result) = 1 - landmarkshell*0.01216 ; 
    %radii(2,i) = radii(1,i) - p.option.shellThickness;
    radii(2,result) = radii(1,result) - 0.0608;
%end

% -- 1. Step --%

%for result = 1:numberOfResults
    %Load result data
    %load([resultsPathAccepted,'/',fileNames{result,1}])
    
    % -- 2. Step --%
    % Ignore all that are out of the domain 
    %(NOTE: Do we still need this?)
    gatheredData.registered.cellCoordinates(:,sum(abs(gatheredData.registered.cellCoordinates)>1)>=1) = [];
    
    % -- 3. Step --%
    % Compute norm of each column
    normOfCoordinates = sqrt(sum(gatheredData.registered.cellCoordinates.^2,1));
    
    % Ignore all coordinates outside the sphere with a tolerance tole
    %(NOTE: Do we still need this?)
    gatheredData.registered.cellCoordinates(:,normOfCoordinates > 1+tole) = [];
    normOfCoordinates(:,normOfCoordinates > 1+tole) = [];
    
    % -- 4. Step --%
    % Normalize the coordinates that are too big but in tolerance 
    %(NOTE: Do we still need this?)
    gatheredData.registered.cellCoordinates(:,(normOfCoordinates < 1+tole) == (normOfCoordinates > 1)) ...
    = gatheredData.registered.cellCoordinates(:,(normOfCoordinates < 1+tole) == (normOfCoordinates > 1))...
    ./repmat(normOfCoordinates(:,(normOfCoordinates < 1+tole) == (normOfCoordinates > 1)),[3,1]);

    % -- 4.2 Step --%
    %Ignore all cells outside of landmark shell. TODO: Find a way to
    %create two additional heatmaps, one under and one above the landmark
    %shell
    
    min_radius = radii(2,result);
    %min_radius = radii(2,1);   %TEST
    %min_radius = 0.7; %0.8625;   %TEST
    max_radius = radii(1,result);
    %max_radius = radii(1,1);   %TEST
    %max_radius = 0.8; %0.9233;   %TEST 
    
    gatheredData.registered.cellCoordinates(:, normOfCoordinates < min_radius) = [];
    normOfCoordinates(:,normOfCoordinates < min_radius) = [];
    gatheredData.registered.cellCoordinates(:, normOfCoordinates > max_radius) = [];
    normOfCoordinates(:,normOfCoordinates > max_radius) = [];
   
    % Get all cell center coordinates
    allCellCoords = horzcat(allCellCoords, gatheredData.registered.cellCoordinates);
 
%DELETE THIS SOON
 average = average + [1/numberOfResults*min_radius, 1/numberOfResults*max_radius];
end 

for result = 1:numberOfResults %DELETE THIS SOON
 var = var + [1/numberOfResults*(average(1)-radii(2,result))^2, 1/numberOfResults*(average(2)-radii(1,result))^2 ];
end

radii %TEST
numberOfResults
average
var

% -- 5. Step --%
% Get rounded cell centroid coordinates
allCellCoords = round(...
    (allCellCoords + repmat([1;1;1], 1, size(allCellCoords,2)))...
    * sizeAcc / 2 );
allCellCoords(allCellCoords==0)=1;
end