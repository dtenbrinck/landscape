%% INITIALIZATION
clear; clc; close all;

% define root directory
root_dir = fileparts(fileparts(pwd));

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

%% GET DATA SIZE FOR ACCUMULATOR

% Load first data set
load([p.resultsPathAccepted,'/',fileNames{1,1}]);

% Original data size (in mu)
% origSize = gatheredData.processed.originalSize;

%% COMPUTE ACCUMULATOR

% -- Compute all valid cell coordinates from the processed and registered data -- %
allCellCoords = getAllValidCellCoords_DAPI(p.gridSize,fileNames,numberOfResults,p.tole,p.resultsPathAccepted);


% -- Compute the Accumulator from the cell coordinates -- %
accumulator = computeAccumulator(allCellCoords, p.gridSize);


%% HANDLE HEATMAPS ( Computation, drawing and saving ) 
% make sure to use specific cell radius for dapi cells
if ( isfield(p.option, 'dapiCellradius') )
    p.option.cellradius = p.option.dapiCellradius;
else
    p.option.cellradius = 2; % use default size for dapi cell radius
end
handleHeatmaps(accumulator,size(allCellCoords,2),numberOfResults,p,p.option);


%% USER OUTPUT

disp('All results in folder processed!');