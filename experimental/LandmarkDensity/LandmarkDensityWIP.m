%% INITIALIZATION
clear; clc; close all;

% define root directory
root_dir = pwd;

% add path for parameter setup
addpath([root_dir '/parameter_setup/']);

% load necessary variables
p = initializeScript('heatmap', root_dir);
        %in processing parameters:
%resolution = [1.29, 1.29, 10];
landmarkCharacteristic = 0;
weight = 0;

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
    
   
    %get points on surface that define equally large slices of landmark (from head to tail). We
    %will later calculate the cell density in each of the slices
    slices = 10; %PARAMETER
    pointsOnSurface = zeros(slices,3);
    for i = 0:slices
    [pstar,vstar] = getCharPos_daniel(pstar,vstar,landmarkCoordinates',landmarkCharacteristic,i* 1/slices);
    pstar = pstar/norm(pstar);
    vstar = vstar/norm(vstar);
    pointsOnSurface(i+1,:) = pstar; 
    end
    
    landmarkCoords = gatheredData.registered.landmarkCentCoords;
    allLandmarkCoords = landmarkCoords; %CHANGE SOON
    
    % slicewise convex boundary approach (not optimal yet!). 
    allLandmarkCoords = sortrows(allLandmarkCoords',1); %sort allLandmarkCoords along x-axis (from head to tail), we need this for slicewise construction of convex hull
    amount = 20; %amount of slices for creating convex boundary
    len = ceil(size(allLandmarkCoords,1)/amount); %length of slice
    for slice = 1:amount
        if slice*len <= size(allLandmarkCoords,1)
            landmark{slice} = boundary(allLandmarkCoords((1 + (slice-1)*len):(slice*len), :), 0); %boundary(landmarkCoords, shrinkfactor), shrinkfactor = 0 gives convex hull
        else
            landmark{slice} = boundary(allLandmarkCoords((1 + (slice-1)*len):size(allLandmarkCoords,1), :), 0); %Problems in last slice ??
        end
    end
    
    % Visualisation (problems with last slice!)
    scatter3(allLandmarkCoords(:,1), allLandmarkCoords(:,2), allLandmarkCoords(:,3),'.')
    grid on
    for i = 1:amount-1
    hold on 
    trisurf(landmark{i},allLandmarkCoords((1 + (i-1)*len):(i*len), 1), allLandmarkCoords((1 + (i-1)*len):(i*len), 2), allLandmarkCoords((1 + (i-1)*len):(i*len), 3),'Facecolor','red','FaceAlpha',0.1)
    end 
    
    %check if cells are in ball-wedges/lunes. The wedges are defined by
    %the pointsOnSurface
end
