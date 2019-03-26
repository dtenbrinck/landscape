%% INITIALIZATION
clear; clc; close all;

% define root directory
root_dir = pwd;

% add path for parameter setup
addpath([root_dir '/parameter_setup/']);

% load necessary variables
p = initializeScript('heatmap', root_dir);
        %other parameters:
%resolution = [1.29, 1.29, 10];
landmarkCharacteristic = 0;
weight = 0;
reference_point = [-1; 0; 0]; 
reference_vector = [0; 0; -1];
min_radius = 0;
max_radius = 1;
teta  = pi/2; %*90 degrees

%% GET FILES TO PROCESS

% Get filenames of MAT files in selected folder
fileNames = getMATfilenames(p.resultsPathAccepted);
fileNames(strcmp(fileNames,'ParameterProcessing.mat')) = [];
fileNames(strcmp(fileNames,'ParameterHeatmap.mat')) = [];
fileNames(strcmp(fileNames,'HeatmapAccumulator.mat')) = [];

if p.random == 1
    fileNames = drawRandomNames(fileNames,p.numberOfRandom);
end
% Get number of experiments
numberOfResults = numel(fileNames);

% Check if any results have been found
if numberOfResults == 0
    disp('All results already processed or path to results folder wrong?');
    disp(resultsPathAccepted);
    return;
else
    disp([ num2str(numberOfResults) ' results found in folder for generating heat map.']);
end

%% MAIN CODE

for result = 1:numberOfResults
    %Load result data
    load([p.resultsPathAccepted,'/',fileNames{result,1}])
    
    %project Landmark on Sphere and calculate great circle (pstar,vstar)
    landmarkPosition = double(gatheredData.processed.landmark);
    [sphereCoordinates, landmarkCoordinates, landmarkOnSphere] = ...
            projectLandmarkOnSphere(landmarkPosition, p.resolution, gatheredData.processed.ellipsoid, p.samples_sphere); 
    [pstar,vstar] = computeRegression_new(landmarkCoordinates','false');
    
    % Tilt refpstar onto the specified position
    [pstar,vstar] = getCharPos_daniel(pstar,vstar,landmarkCoordinates',landmarkCharacteristic,weight);
	pstar = pstar/norm(pstar);
    vstar = vstar/norm(vstar);
    
    % Rotationmatrix: Rotate the great circle s.t. pstar is on refpstar
    [Rp,~,~,~,vAngle]...
    = rotateGreatCircle(pstar,vstar,reference_point,reference_vector);

    % Rotationmatrix: Rotates the regression line onto the reference line
	Ra = rotAboutAxis(vAngle,reference_point);

    transformation = Ra * Rp;

    pstar = Rp*pstar;
    vstar = Ra*Rp*vstar;
    transformedCoordinates = transformation * landmarkCoordinates';
   
    %get points on surface that define equally large slices of landmark (from head to tail). We
    %will later calculate the cell density in each of the slices
    slices = 10; %PARAMETER
    pointsOnSurface = zeros(slices,3);
    for i = 0:slices
    [pstar,vstar] = getCharPos_daniel(pstar,vstar,transformedCoordinates,landmarkCharacteristic,i* 1/slices);
    pstar = pstar/norm(pstar);
    vstar = vstar/norm(vstar);
    pointsOnSurface(i+1,:) = pstar; 
    end
    pointsOnSurface(:,[2 3])= pointsOnSurface(:,[3 2]); %change order of coordinates, we need this for using spherical coordinates later
    
    %calculate intersections between landmark-shell and sttraight line between
    %pointsOnSurface and center (DO WE NEED THIS?)
    %for i = 1:slices+1
    %intersections_min(i,:) = min_radius*pointsOnSurface(i,:);
    %intersections_max(i,:) = max_radius*pointsOnSurface(i,:);
    %end 
   
    nucleiCoords = gatheredData.registered.nucleiCoordinates;
    nucleiCoords = nucleiCoords';
    nucleiCoords(:,[2 3])= nucleiCoords(:,[3 2]); %change order of coordinates, we need this for using spherical coordinates later
    
    %calculate [azimuth/phi, elevation/teta, radius] of pointsOnSurface (spherical
    %coordinates)
    for i = 1:slices+1
    [pointsOnSurface(i,1), pointsOnSurface(i,2), pointsOnSurface(i,3)] = cart2sph(pointsOnSurface(i,1),pointsOnSurface(i,2),pointsOnSurface(i,3));
    end
    %calculate [azimuth/phi, elevation/teta, radius] of nucleiCoords (spherical
    %coordinates)
    for i = 1:size(nucleiCoords,1)
    [nucleiCoords(i,1), nucleiCoords(i,2), nucleiCoords(i,3)] = cart2sph(nucleiCoords(i,1),nucleiCoords(i,2),nucleiCoords(i,3));
    end
    
    %calculate amount of nucleis inside slices and landmark area defined by
    %[azimuth/phi, elevation/teta, radius]
    
    amountofNucleis = zeros(slices,1);
    for i = 1: size(nucleiCoords,1)
        for slice = 1:slices
            %check boundaries for azimuth, elevation, radius
            if  nucleiCoords(i,1) <= 0 && pointsOnSurface(slice,1) <= 0
                if abs(nucleiCoords(i,1)) < abs(pointsOnSurface(slice,1)) && abs(nucleiCoords(i,1)) >= abs(pointsOnSurface(slice+1,1)) && nucleiCoords(i,2) >= pi/2-teta && nucleiCoords(i,2) <= pi/2+teta && nucleiCoords(i,3) >= min_radius && nucleiCoords(i,2) <= min_radius
                    amountOfNucleis(slice) = amountOfNucleis(slice) +1;
                end
            elseif nucleiCoords(i,1) > 0 && pointsOnSurface(slice,1) > 0
                if abs(nucleiCoords(i,1)) > abs(pointsOnSurface(slice,1)) && abs(nucleiCoords(slice,1)) <= abs(pointsOnSurface(slice+1,1)) && nucleiCoords(i,2) >= pi/2-teta && nucleiCoords(i,2) <= pi/2+teta && nucleiCoords(i,3)>= min_radius && nucleiCoords(i,2) <= min_radius  
                    amountOfNucleis(slice) = amountOfNucleis(slice) +1;
                end
            end
        end
    end
   
end



