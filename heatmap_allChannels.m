%% INITIALIZATION
clear; clc; close all;

% add path for parameter setup
addpath('./parameter_setup/');

% load necessary variables
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

%% COMPUTE AVERAGE MIPS FOR ALL CHANNELS
heatMapDapi = zeros(p.gridSize, p.gridSize);
heatMapGFP = zeros(p.gridSize, p.gridSize);
heatMapmCherry = zeros(p.gridSize, p.gridSize);

for result = 1:numberOfResults
    % Load result data
    load([p.resultsPathAccepted,'/',fileNames{result,1}])
    
    % Get all cell center coordinates
    heatMapDapi = heatMapDapi + gatheredData.registered.DapiMIP;
    heatMapGFP = heatMapGFP + gatheredData.registered.GFPMIP;
    heatMapmCherry = heatMapmCherry + gatheredData.registered.mCherryMIP;
end
heatMapDapi = heatMapDapi ./ numberOfResults;
heatMapGFP = heatMapGFP ./ numberOfResults;
heatMapmCherry = heatMapmCherry ./ numberOfResults;

%% HANDLE HEATMAPS ( Computation, drawing and saving ) 
%handleHeatmaps(heatMapDapi,0,numberOfResults,p,p.option);

figure; imagesc(heatMapDapi); title('Average of registered DAPI channels');colormap('jet');
figure; imagesc(heatMapGFP); title('Average of registered GFP channels');colormap('jet');
figure; imagesc(heatMapmCherry); title('Average of registered mCherry channels');colormap('jet');

%% USER OUTPUT

disp('All results in folder processed!');
