%% INITIALIZATION
clear; clc; close all;

% define root directory
root_dir = fileparts(fileparts(pwd));

% add path for parameter setup
addpath([root_dir '/parameter_setup/']);

% load necessary variables
p = initializeScript('dynamic_heatmap', root_dir);


%% GET FILES TO PROCESS

% Get filenames of MAT files in selected folder
fileNames = getMATfilenames(p.resultsPathAccepted);
fileNames(strcmp(fileNames,'ParameterProcessing.mat')) = [];
fileNames(strcmp(fileNames,'ParameterHeatmap.mat')) = [];
fileNames(strcmp(fileNames,'HeatmapAccumulator.mat')) = [];

% Check if any results have been found
if isempty(fileNames)
    disp('No dynamic information found. Path to results folder wrong?');
    disp(resultsPathAccepted);
    return;
end

%% LOAD DATA

% Load dynamic data
load([p.resultsPathAccepted,'/',fileNames{1,1}]);

%% COMPUTE ACCUMULATOR

% -- Compute the Accumulator from the cell coordinates -- %
[accumulatorPosition, accumulatorSpeed, accumulatorStraightness, numberCells, numberExperiments] = computeAccumulatorDynamic(results,p.gridSize);


%% HANDLE HEATMAPS ( Computation, drawing and saving ) 

handleDynamicHeatmaps(accumulatorStraightness,numberCells,numberExperiments,p,p.option,'straightness');
handleDynamicHeatmaps(accumulatorPosition,numberCells,numberExperiments,p,p.option,'position');
handleDynamicHeatmaps(accumulatorSpeed,numberCells,numberExperiments,p,p.option,'speed');



%% USER OUTPUT

disp('All results in folder processed!');