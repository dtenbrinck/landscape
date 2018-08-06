function heatmap_dynamics()
clear; clc; close all;

% define root directory
root_dir = fileparts(fileparts(pwd));

% add path for parameter setup
addpath(root_dir);

% add path for parameter setup
addpath([root_dir '/parameter_setup/']);

% load necessary variables
p = initializeScript('heatmap', root_dir);

% GENERATE HEATMAPS 
plotHeatmapsAveragedOverInterval(p);
% generateHeatmapsPerTimeStep(p);

disp('All results in folder processed!');
end

function generateHeatmapsPerTimeStep( p)
disp('Generate heatmaps per eacht time step...');

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

function plotHeatmapsAveragedOverInterval( p)
disp('Generating heatmaps using all cell coordinates over whole time interval...');

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

load([p.resultsPathAccepted,'/',fileNames{1,1}]);
referenceLandmark = computeReferenceLandmark(fileNames,numberOfResults, p.resultsPathAccepted);

%% COMPUTE ACCUMULATOR
% -- Compute all valid cell coordinates from the processed and registered data -- %
[ allCellCoords, allCellVelocities]  = getAllValidCellCoords(p.gridSize,fileNames,numberOfResults,p.tole,p.resultsPathAccepted);

% -- Compute the accumulators from the cell coordinates and for the velocities -- %
accumulatorForVelocities = computeAccumulatorWithVelocities(allCellCoords, p.gridSize, allCellVelocities);
accumulator = computeAccumulator(allCellCoords, p.gridSize);

%% GENERATE HEATMAPS
fig_filename_base = [p.resultsPath ,'/heatmaps/'];
convAccPositions = createSlicesPlots(accumulator, p.option, 'Number of PGCs', referenceLandmark, [fig_filename_base, 'PGCs_positions'], 1);
createSlicesPlots(accumulatorForVelocities, p.option, 'Average speed [\mum / min]', referenceLandmark,[fig_filename_base, 'PGCs_average_velocities'], convAccPositions);

end

function referenceLandmark = computeReferenceLandmark(fileNames,numberOfResults, resultsPathAccepted)
fprintf('Computing refernce landmark ...\n');
referenceLandmark.MIP = zeros(256,256);
referenceLandmark.coords = zeros(256,256,256);

for result = 1:numberOfResults
    load([resultsPathAccepted,'/',fileNames{result,1}])
    referenceLandmark.MIP = referenceLandmark.MIP + gatheredData.registered.landmarkMIP;
    referenceLandmark.coords = referenceLandmark.coords + gatheredData.registered.landmark;
end

% normalization: only 0 or 1 in return values indicating where cells for
% the landmark where found
referenceLandmark.MIP = referenceLandmark.MIP > 0;
referenceLandmark.coords = referenceLandmark.coords > 0;
end