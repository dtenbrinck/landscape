%% INITIALIZATION
clear; clc; close all;

% define root directory
root_dir = pwd;

% add path for parameter setup
addpath([root_dir '/parameter_setup/']);

% load necessary variables
p = initializeScript('heatmap', root_dir);

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
% Initialize matrix that will contain all landmark Coordinates
allLandmarkCoords = double.empty(3,0); 

for result = 1:numberOfResults
    %Load result data
    load([p.resultsPathAccepted,'/',fileNames{result,1}])
    
    landmarkCoords = gatheredData.registered.landmarkCentCoords;
    allLandmarkCoords = horzcat(allLandmarkCoords, landmarkCoords);
end
allLandmarkCoords = sortrows(allLandmarkCoords',1); %sort allLandmarkCoords along x-axis (from head to tail), we need this for slicewise construction of convex hull 

% slicewise boundary approach
scatter3(allLandmarkCoords(:,1), allLandmarkCoords(:,2), allLandmarkCoords(:,3),'.')
grid on
hold off
amount = 10; %amount of slices
len = ceil(size(allLandmarkCoords,1)/amount); %length of slice
for slice = 1:amount
    if slice*len <= size(allLandmarkCoords,1)
        scatter3(allLandmarkCoords(:,1), allLandmarkCoords(:,2), allLandmarkCoords(:,3),'.')
        hold on
        scatter3(allLandmarkCoords((1 + (slice-1)*len):(slice*len), 1), allLandmarkCoords((1 + (slice-1)*len):(slice*len), 2), allLandmarkCoords((1 + (slice-1)*len):(slice*len), 3),'.', 'red');
        grid on
        hold off
        landmark{slice} = boundary(allLandmarkCoords((1 + (slice-1)*len):(slice*len), :), 0); %boundary(landmarkCoords, shrinkfactor), shrinkfactor = 0 gives convex hull, TODO: ignore outliers
    else
        landmark{slice} = boundary(allLandmarkCoords((1 + (slice-1)*len):size(allLandmarkCoords,1), :), 0);
    end
end
 %hold on 
 %trisurf(landmark{1},allLandmarkCoords(:,1),allLandmarkCoords(:,2),allLandmarkCoords(:,3),'Facecolor','red','FaceAlpha',0.1)
 hold on 
 trisurf(landmark{5},allLandmarkCoords((1 + (5-1)*len):(5*len), 1), allLandmarkCoords((1 + (5-1)*len):(5*len), 2), allLandmarkCoords((1 + (5-1)*len):(5*len), 3),'Facecolor','red','FaceAlpha',0.1)