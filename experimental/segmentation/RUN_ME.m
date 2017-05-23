%% INITIALIZATION
clear; clc; close all;

% change directory to root directory
cd ../../;

% add path for parameter setup
addpath('./parameter_setup/');
addpath(genpath('./experimental/'));

% load necessary variables
p = initializeScript('process');

% manual set resolution parameter
manRes = [0,0,0];

%% PREPARE RESULTS DIRECTORY
checkDirectory(p.resultsPath);

%% LOAD DATA

% get filenames of STK files in selected folder
fileNames = getSTKfilenames(p.dataPath);

% extract only valid experiments with three data sets
allValidExperiments = checkExperimentChannels(fileNames);

% get number of experiments
numberOfExperiments = size(allValidExperiments,1);

% adjust resolution according to scale parameter
p.resolution(1:2) = p.resolution(1:2) / p.scale;

%% MAIN LOOP

fprintf(['Processing dataset: (0,' num2str(numberOfExperiments) ')']);

% process all existing data sequentially
for experiment=1:numberOfExperiments
  
  % show remotecurrent experiment number
  dispCounter(experiment, numberOfExperiments);
  
  % get data of current experiment
  if p.debug_level >= 1; disp('Loading data...'); end
  experimentData = loadExperimentData(allValidExperiments(experiment,:), p.dataPath,manRes);
  if isfield(experimentData,'manualxRes')
    manRes(1) = 1;
    manRes(2) = experimentData.manualxRes;
    manRes(3) = experimentData.manualyRes;
    experimentData = rmfield(experimentData,'manualyRes');
    experimentData = rmfield(experimentData,'manualxRes');
  end
  experimentData = experimentData.Data_1;
  
  % preprocess and rescale data
  if p.debug_level >= 1; disp('Preprocessing data...'); end
  processedData = preprocessData(experimentData, p);
  
  %% SEGMENTATION OF GFP CHANNEL
  
  % segment data
  %if p.debug_level >= 1; disp('Segmenting GFP channel...'); end
  %processedData.landmark = segmentGFP(processedData.GFP, p.GFPseg, p.resolution);
  
  
  %% SEGMENTATION OF MCHERRY CHANNEL (CELLS)
  if p.debug_level >= 1; disp('Segmenting mCherry channel...'); end
  %[processedData.cells, processedData.cellCoordinates] = segmentCells(processedData.mCherry, p.mCherryseg, p.resolution);
  
  segmentation_embryo = k_means_clustering(experimentData.mCherry,2,'scalar');
  embryo_processed = processedData.mCherry(segmentation_embryo == 2);
  
  indices_cells = k_means_clustering(embryo_processed,2,'scalar');
  
  segmentation = zeros(size(processedData.mCherry));
  segmentation(segmentation_embryo==2) = indices_cells;
  
  %% VISUALIZE SEGMENTATION RESULTS  
  
  figure; imagesc(computeMIP(processedData.mCherry));
  figure; imagesc(computeMIP(segmentation));
  
end

