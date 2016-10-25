%% INITIALIZATION
clear; clc; close all;

% add current folder and subfolders to path variable
addpath(genpath(pwd));

%% SET PARAMETERS

% dataPath = '/home/f_gaed01/Projects/EmbryoProject/data/tilting_adjustments_first_priority';
dataPath = 'E:\Embryo_Registration\data\Small';
% dataPath = './data/tilting_adjustments_first_priority';
resultsPath = './results/Small'; % DONT APPEND '/' TO DIRECTORY NAME!!!
resolution = [1.29, 1.29, 20];
scale = 0.75;
samples_sphere = 128;
samples_cube = 256;
landmarkCharacteristic = 'middle';
reference_point = [0; 0; -1];
reference_vector = [1; 0; 0];

% some output variables
debug_level = 0;
visualization = 1;

%% PREPARE RESULTS DIRECTORY
checkDirectory(resultsPath);

%% LOAD DATA

% get filenames of STK files in selected folder
fileNames = getSTKfilenames(dataPath);

% extract only valid experiments with three data sets
allValidExperiments = checkExperimentChannels(fileNames);

% get number of experiments
numberOfExperiments = size(allValidExperiments,1);

% adjust resolution according to scale parameter
resolution(1:2) = resolution(1:2) / scale;

%% MAIN LOOP

fprintf(['Processing dataset: (0,' num2str(numberOfExperiments) ')']); 
    
% process all existing data sequentially
for experiment=1:numberOfExperiments
    
    % show remotecurrent experiment number
    dispCounter(experiment, numberOfExperiments);
    
    try
        % get data of current experiment
        if debug_level >= 1; disp('Loading data...'); end
        experimentData = loadExperimentData(allValidExperiments(experiment,:), dataPath);
        experimentData = experimentData.Data_1;
        
        % preprocess and rescale data
        if debug_level >= 1; disp('Preprocessing data...'); end
        processedData = preprocessData(experimentData, scale);
        
        % segment data
        if debug_level >= 1; disp('Segmenting GFP channel...'); end
        processedData.landmark = segmentGFP(processedData.GFP, resolution);
        
        if debug_level >= 1; disp('Segmenting mCherry channel...'); end
        [processedData.cells, processedData.cellCoordinates] = segmentCells(processedData.mCherry, resolution);
        
        % check the orientation of the embryo and flip to be head-right
        headOrientation = determineHeadOrientation(computeMIP(processedData.landmark));
        if strcmp(headOrientation, 'right')
            if debug_level >= 1; disp('Rotating data...'); end
            processedData = flipOrientation(processedData);
        end
        
        % estimate embryo surface by fitting an ellipsoid
        if debug_level >= 1; disp('Estimating embryo surface...'); end
        ellipsoid = estimateEmbryoSurface(processedData.Dapi, resolution);
        
        % compute transformation which normalizes the estimated ellipsoid to a unit sphere
        if debug_level >= 1; disp('Compute transformation from optimal ellipsoid...'); end
        transformationMatrix = computeTransformationMatrix(ellipsoid);
        
        %%%%%%%%%%% VALIDITY CHECK FOR DEBUGGING
        if debug_level >= 2;
            disp('Transform data for validity check...');
            [ transformedData, transformedResolution ] = transformDataToSphere( processedData, resolution, transformationMatrix, ellipsoid, samples_cube );
        end
        
        % project landmark onto unit sphere
        if debug_level >= 1; disp('Projecting landmark onto embryo surface...'); end
        [sphereCoordinates, landmarkCoordinates, landmarkOnSphere] = ...
            projectLandmarkOnSphere(processedData.landmark, resolution, ellipsoid, samples_sphere);
        
        % estimate optimal rotation to register data to reference point with reference orientation
        if debug_level >= 1; disp('Estimating transformation from projected landmark...'); end        
        rotationMatrix = ...
            registerLandmark(landmarkCoordinates, reference_point, reference_vector, landmarkCharacteristic);
        
        %%%%%%%%%%% VALIDITY CHECK FOR DEBUGGING
        if debug_level >= 2
            % transform projected landmark with estimated rotation
            registered_sphere = ...
                transformCoordinates(sphereCoordinates, [0 0 0]', rotationMatrix, [0 0 0]');
            
            % visualize projection on unit sphere
            visualizeProjectedLandmark(sphereCoordinates, landmarkOnSphere);
            visualizeProjectedLandmark(registered_sphere', landmarkOnSphere);
        end
        
        % compute registration transformation from original data space
        transformation_registration = transformationMatrix * rotationMatrix';
        
        % register data
        if debug_level >= 1; disp('Registering data...'); end
        registeredData = registerData( processedData, resolution, transformation_registration, ellipsoid, samples_cube);
        
        % visualize results if needed
        if visualization == 1
            visualizeResults(experimentData, processedData, registeredData);
        end
        
        % create filename to save results
        results_filename = [resultsPath '/' experimentData.filename '_results.mat'];
        
        % save results
        save(results_filename, 'experimentData', 'processedData', 'registeredData');
        
        if debug_level >= 1; disp('Saved results successfully!'); end
        
    catch ERROR_MSG  %% ONLY EXECUTED WHEN ERRORS HAPPENING
        
        % create filename to save results
        results_filename = [resultsPath '/bug/' experimentData.filename '_results.mat'];
        
        % save results
        save(results_filename, 'ERROR_MSG');
        
        if debug_level >= 1; disp('Saved buggy dataset!'); end
        
    end
end

%% USER OUTPUT
fprintf('\n');
disp('All data sets in folder processed!');
close all;
clear all;