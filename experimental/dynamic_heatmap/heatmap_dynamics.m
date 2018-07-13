function heatmap_dynamics()
clear; clc; close all;

% define root directory
root_dir = fileparts(fileparts(pwd));

% add path for parameter setup
addpath(root_dir);

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
fileNames = getMATfilenames(p.resultsPath);
fileNames(~strcmp(fileNames,'dynamicPGCdata_results.mat')) = [];

% Get number of experiments
numberOfResults = numel(fileNames);

% Check if any results have been found
if numberOfResults == 0
    disp('Did not find dynamicPGCdata_results.mat. Is the path to dynamic results correct?');
    disp(p.resultsPath);
    return;
else
    disp([ num2str(numberOfResults) ' dynamic PGC results found in folder for generating heat map.']);
end

%% GET DATA SIZE FOR ACCUMULATOR

% Load data set
load([p.resultsPath,'/',fileNames{1,1}]);

% iterate over all time steps and generate heatmap for each
numberOfTimeSteps = numel(dynamicPGCdata.coords);
leadingZeros = ['%0' num2str(numel(num2str(numberOfTimeSteps))) 'd'];
p.option.axisLimit = dynamicPGCdata.maxNumberCellsPerTimeStep;
for timestep = 1: numberOfTimeSteps
    fprintf('Generating heat map for time step %d...\n', timestep);
    %% COMPUTE ACCUMULATOR
    
    % -- Compute all valid cell coordinates from the processed and registered data -- %
    allCellCoords = getAllValidCellCoordsPerTimeStep(p.gridSize,fileNames,p.tole,p.resultsPath, dynamicPGCdata.coords{timestep});
    % -- Compute the Accumulator from the cell coordinates -- %
    accumulator = computeAccumulator(allCellCoords, p.gridSize);

    %% HANDLE HEATMAPS ( Computation, drawing and saving ) 
    p.option.frameNo = sprintf(leadingZeros, timestep);
    handleHeatmaps(accumulator,size(allCellCoords,2),numberOfResults,p,p.option);
end

end