%% INITIALIZATION
clear; clc; close all;

% add current folder and subfolders to path
addpath(genpath('./../..'));

p = initializeScript('heatmap');

% define if to use mCherry channel or accumulator
use_accumulator = true;

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


%% COMPUTE AVERAGE MIPS FOR ALL CHANNELS
heatMapDapi_registered = zeros(p.gridSize, p.gridSize);
heatMapGFP_registered = zeros(p.gridSize, p.gridSize);
heatMapmCherry_registered = zeros(p.gridSize, p.gridSize);

% make a test load for data size
%TODO: Put this in p struct
load([p.resultsPathAccepted,'/',fileNames{1,1}])
[ySize, xSize] = size(gatheredData.processed.DapiMIP);

heatMapDapi_unregistered = zeros(ySize, xSize);
heatMapGFP_unregistered = zeros(ySize, xSize);
heatMapmCherry_unregistered = zeros(ySize, xSize);

for result = 1:numberOfResults
    % Load result data
    load([p.resultsPathAccepted,'/',fileNames{result,1}])
    
    % compute heatmaps for each channel for registered data
    heatMapDapi_registered = heatMapDapi_registered + gatheredData.registered.DapiMIP;
    heatMapGFP_registered = heatMapGFP_registered + gatheredData.registered.GFPMIP;
    heatMapmCherry_registered = heatMapmCherry_registered + gatheredData.registered.mCherryMIP;
    
    % compute heatmaps for each channel for unregistered data
    heatMapDapi_unregistered = heatMapDapi_unregistered + gatheredData.processed.DapiMIP;
    heatMapGFP_unregistered = heatMapGFP_unregistered + gatheredData.processed.GFPMIP;
    heatMapmCherry_unregistered = heatMapmCherry_unregistered + gatheredData.processed.mCherryMIP;
end
%heatMapDapi_registered = heatMapDapi_registered ./ numberOfResults;
%heatMapGFP_registered = heatMapGFP_registered ./ numberOfResults;
%heatMapmCherry_registered = heatMapmCherry_registered ./ numberOfResults;

%% VISUALIZE COMPARISON OF MIPS FOR REGISTERED AND UNREGISTERED DATA

figure;

if use_accumulator
    subplot(2,3,1); imagesc(max(convAccumulator_unregistered,[],3)); axis image; title('MIP of unregistered mCherry channel');
    subplot(2,3,4); imagesc(max(convAccumulator_registered,[],3)); axis image; title('MIP of registered mCherry channel');
else
   subplot(2,3,1); imagesc(heatMapmCherry_unregistered); axis image; title('MIP of unregistered mCherry channel');
   subplot(2,3,4); imagesc(heatMapmCherry_registered); axis image; title('MIP of registered mCherry channel');
end

subplot(2,3,2); imagesc(heatMapDapi_unregistered); axis image; title('MIP of unregistered DAPI channel');
subplot(2,3,5); imagesc(heatMapDapi_registered); axis image; title('MIP of registered DAPI channel');
subplot(2,3,3); imagesc(heatMapGFP_unregistered); axis image; title('MIP of unregistered GFP channel');
subplot(2,3,6); imagesc(heatMapGFP_registered); axis image; title('MIP of registered GFP channel');
