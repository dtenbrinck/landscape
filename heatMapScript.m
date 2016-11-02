%% INITIALIZATION
clear; clc; close all;

p = initializeScript('heatmap');
%% GET FILES TO PROCESS

% Get filenames of MAT files in selected folder
fileNames = getMATfilenames(p.resultsPathAccepted);
fileNames(find(strcmp(fileNames,'ParameterProcessing.mat'))) = [];
fileNames(find(strcmp(fileNames,'ParameterHeatmap.mat'))) = [];

% Get number of experiments
numberOfResults = size(fileNames,1);

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
origSize = gatheredData.processed.originalSize;

%% COMPUTE ACCUMULATOR

% -- Compute all valid cell coordinates from the processed and registered data -- %
allCellCoords = getAllValidCellCoords(p.gridSize,fileNames,numberOfResults,p.tole,p.resultsPathAccepted);

% -- Compute the Accumulator from the cell coordinates -- %
accumulator = compAcc(allCellCoords, p.gridSize);


%% HANDLE HEATMAPS ( Computation, drawing and saving ) 
handleHeatmaps(accumulator,size(allCellCoords,2),numberOfResults,p,p.option);

%% USER OUTPUT

disp('All results in folder processed!');