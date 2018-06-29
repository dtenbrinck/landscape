function heatmap_dynamics()
%% GENERATE HEATMAPS 
disp('Generating heatmaps using all cell coordinates over whole time interval...');
heatmap_singleExperiment();

disp('Generate heatmaps per eacht time step...');
generateHeatmapsPerTimeStep();

%% USER OUTPUT

disp('All results in folder processed!');
end

function generateHeatmapsPerTimeStep()
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
fileNames(~strcmp(fileNames,'dynamicPGCdata_results.mat')) = [];

% Get number of experiments
numberOfResults = numel(fileNames);

% Check if any results have been found
if numberOfResults == 0
    disp('Did not find dynamicPGCdata_results.mat. Is the path to dynamic results correct?');
    disp(resultsPathAccepted);
    return;
else
    disp([ num2str(numberOfResults) ' dynamic PGC results found in folder for generating heat map.']);
end

%% GET DATA SIZE FOR ACCUMULATOR

% Load data set
load([p.resultsPathAccepted,'/',fileNames{1,1}]);

% iterate over all time steps and generate heatmap for each
numberOfTimeSteps = numel(dynamicPGCdata);
for timestep = 1: numberOfTimeSteps
    fprintf('Generating heat map for time step %d...\n', timestep);
    %% COMPUTE ACCUMULATOR
    
    % -- Compute all valid cell coordinates from the processed and registered data -- %
    allCellCoords = getAllValidCellCoords(p.gridSize,fileNames,p.tole,p.resultsPathAccepted, dynamicPGCdata{timestep});
    % -- Compute the Accumulator from the cell coordinates -- %
    accumulator = computeAccumulator(allCellCoords, p.gridSize);

    %% HANDLE HEATMAPS ( Computation, drawing and saving ) 
    handleHeatmaps(accumulator,size(allCellCoords,2),numberOfResults,p,p.option);
end

end