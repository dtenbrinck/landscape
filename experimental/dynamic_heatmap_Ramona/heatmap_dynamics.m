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

disp('All dynamic results in folder processed!');
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
[ allCellCoords, allCellVelocities]  = getAllValidDynamicCellData(p.gridSize,fileNames,numberOfResults,p.tole,p.resultsPathAccepted);

% -- Compute the accumulators from the cell coordinates and for the velocities -- %
accumulatorForSpeedValues = computeAccumulatorWithVelocities(allCellCoords, p.gridSize, allCellVelocities);
accumulator = computeAccumulator(allCellCoords, p.gridSize);

% Save accumulators
if p.option.heatmaps.saveAccumulator == 1
    mat_name = [p.resultsPath ,'/heatmaps/','AccumulatorPGCpositions.mat'];
    save(mat_name,'accumulator');
    mat_name = [p.resultsPath ,'/heatmaps/','AccumulatorPGCspeed.mat'];
    save(mat_name,'accumulatorForSpeedValues');
end
    
%% GENERATE HEATMAPS
fig_filename_base = [p.resultsPath ,'/heatmaps/'];
convAccPositions = createSlicesPlots(accumulator, p.option, 'Number of PGCs', referenceLandmark, [fig_filename_base, 'PGCs_positions'], 1);
createSlicesPlots(accumulatorForSpeedValues, p.option, 'Average speed [\mum / min]', referenceLandmark,[fig_filename_base, 'PGCs_average_velocities'], convAccPositions);

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