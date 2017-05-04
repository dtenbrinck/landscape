%% INITIALIZATION
clear; clc; close all;

% change directory to root directory
cd ../../;

% add path for parameter setup
addpath('./parameter_setup/');
addpath(genpath('./experimental/'));

% load necessary variables
p = initializeScript('process');
rmpath('./preprocessing');

% manual set resolution parameter
manRes = [0,0,0];

% set scale of x-y resolution
p.scale = 0.5;

% adjust resolution according to scale parameter
p.resolution(1:2) = p.resolution(1:2) / p.scale;


%% LOAD AND PREPROCESS DATA

% get filenames of STK files in selected folder
fileNames = getSTKfilenames(p.dataPath);

% extract only valid experiments with three data sets
% TODO: DOES NOT WORK YET WITH DYNAMIC DATA!
%allValidExperiments = checkExperimentChannels(fileNames);

% get data of current experiment
if p.debug_level >= 1; disp('Loading data...'); end

% set dummy filename
experimentData.filename = 'dynamic_data_experimental';

% set dummy resolutions
experimentData.x_resolution = 312;
experimentData.y_resolution = 312;

% load first three channels assuming:
% 1 -> DAPI
% 2 -> GFP
% 3 -> mCherry

tmp1 = loadDynamicData([p.dataPath '/' fileNames{1}]); % load DAPI
experimentData.Dapi = preprocessData(tmp1, p, 1); % preprocess DAPI
clear tmp1; % delete original DAPI

tmp2 = loadDynamicData([p.dataPath '/' fileNames{2}]); % load GFP
experimentData.GFP = preprocessData(tmp2, p, 2); % preprocess GFP
clear tmp2; % delete original DAPI

tmp3 = loadDynamicData([p.dataPath '/' fileNames{3}]); % load mCherry
experimentData.mCherry = preprocessData(tmp3, p, 3); % preprocess mCherry
clear tmp3; % delete original DAPI


% get number of experiments
% TODO: determine dynamically in future
numberOfExperiments = 1;

%% PROCESS DATA (SEGMENTATION, OPTICAL FLOW, TRACKING)

for i = 1:numberOfExperiments
    
    try
        
        % extract number of timepoints
        numberOfTimepoints = size(experimentData.Dapi,4);
        
        if p.debug_level >= 1; disp('Segmenting mCherry channel...'); end
        
        % initialize container for segmentation
        segmentation = zeros(size(experimentData.mCherry));
        
        % initialize container for cell coordinates
        coordinates = cell(0,1);
              
        
        % PERFORM OPTICAL FLOW HERE
        % flow = computeOF(experimentData.Dapi);
        
        % CORRECT MCHERRY CHANNEL WITH FLOW
        % experimentData.mCherry = warping(experimentData.mCherry, flow);
        
        % segment each channel separately
        for t = 1:numberOfTimepoints
            
            % perform segmentation for current timestep
            [segmentedCells, cellCoordinates] = segmentCells(experimentData.mCherry(:,:,:,t), p.mCherryseg, p.resolution);
            
            % save result in container
            segmentation(:,:,:,t) = segmentedCells;
            
            coordinates{t} = cellCoordinates;
        end
        
        % PERFORM TRACKING HERE
        % tracks = cell_tracking(segmentation)
        
    catch ERROR_MSG  %% ONLY EXECUTED WHEN ERRORS HAPPENING
        
        % create filename to save results
        results_filename = [p.resultsPath '/bug/' experimentData.filename '_results.mat'];
        
        % save results
        save(results_filename, 'ERROR_MSG');
        
        if p.debug_level >= 1; disp('Saved buggy dataset!'); end
        
    end
    
end