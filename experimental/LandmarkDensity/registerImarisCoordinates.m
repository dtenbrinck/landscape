%% INITIALIZATION
clear; clc; close all;

% define root directory
root_dir = pwd;

% add path for parameter setup
addpath([root_dir '/parameter_setup/']);

% load necessary variables
p = initializeScript('heatmap', root_dir);
p2 = initializeScript('heatmap',root_dir);

%parameters
Ecken = [85, -10988, 245; 576, -11209, 93; 700 -18612, 890; 354 -16481, 858; 280, -16148, 1215];  

%% GET FILES TO PROCESS

% Get filenames of MAT files in selected folder
fileNames = getMATfilenames(p.resultsPathAccepted);
imarisCoordinates = getMATfilenames(p2.resultsPathAccepted);
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
load([p2.resultsPathAccepted,'/',fileNames{result,1}])
    
nucleiCoords = cells_all';  %these are the coordinates extracted from Imaris: cells_all/cells_total/....

EckMatrix = Ecken(i,:)';
for i = 2:size(nucleiCoords,2)
    EckMatrix = horzcat(EckMatrix, Ecken(i,:)');
end

%shift center of Imaris coordinate System 
nucleiCoords = nucleiCoords - EckMatrix; 

%registering
nucleiCoords = transformCoordinates(nucleiCoords', gatheredData.processed.ellipsoid.center, gatheredData.registered.transformation_full^-1,[0;0;0]);

end