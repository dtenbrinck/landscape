%% INITIALIZATION
clear; clc; close all;

% add current folder and subfolders to path
addpath(genpath('./../..'));

p = initializeScript('heatmap');
%% GET FILES TO PROCESS

% Get filenames of MAT files in selected folder
fileNames = getMATfilenames(p.resultsPathAccepted);
fileNames(find(strcmp(fileNames,'ParameterProcessing.mat'))) = [];
fileNames(find(strcmp(fileNames,'ParameterHeatmap.mat'))) = [];
fileNames(find(strcmp(fileNames,'HeatmapAccumulator.mat'))) = [];

if p.random == 1
    fileNames = drawRandomNames(fileNames,p.numberOfRandom);
end
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
% origSize = gatheredData.processed.originalSize;

%% COMPUTE ACCUMULATOR

% -- Compute all valid cell coordinates from the unregistered and registered data -- %
[allCellCoords_registered, allCellCoords_unregistered] = getAllValidCellCoords(p.gridSize,fileNames,numberOfResults,p.tole,p.resultsPathAccepted);

% -- Compute the accumulator for the registered cells -- %
accumulator_registered = computeAccumulator(allCellCoords_registered, p.gridSize);

% -- Compute the accumulator for the unregistered cells -- %
accumulator_unregistered = computeAccumulator(allCellCoords_unregistered, p.gridSize);


%% CONVOLVE ACCUMULATOR

convAccumulator_registered = convolveAccumulator(accumulator_registered,p.option.cellradius,2*p.option.cellradius+1);
convAccumulator_unregistered = convolveAccumulator(accumulator_unregistered,p.option.cellradius,2*p.option.cellradius+1);


%% VISUALIZE COMPARISON OF MIPS FOR REGISTERED AND UNREGISTERED DATA

figure;
subplot(1,2,1); imagesc(max(convAccumulator_registered,[],3)); axis image; title('MIP for registered data');
subplot(1,2,2); imagesc(max(convAccumulator_unregistered,[],3)); axis image; title('MIP for unregistered data');

%% USER OUTPUT

disp('All results in folder processed!');