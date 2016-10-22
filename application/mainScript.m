%% INITIALIZATION
clear; clc; close all;

% add current folder and subfolders to path variable
addpath(genpath('./..'));

%% SET PARAMETERS

% dataPath = 'E:\Embryo_Registration\data\SargonYigit\Image Registration\10hpf_data\tilting_adjustments_first_priority';
dataPath = './../data/tilting_adjustments_first_priority';
resolution = [1.29, 1.29, 20];
scale = 0.5;
samples_sphere = 96;
samples_cube = 256;
landmarkCharacteristic = 'middle';
reference_point = [0; 0; -1];
reference_vector = [1; 0; 0];

debug = 1;
visualization = 1;

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

% process all existing data sequentially
for experiment=1:numberOfExperiments
    
    % get data of current experiment
    experimentData = loadExperimentData(allValidExperiments(experiment,:), dataPath);
    experimentData = experimentData.Data_1;
    
    % preprocess and rescale data
    processedData = preprocessData(experimentData, scale);
    
    % segment data
    disp('Segmenting GFP channel...');
    processedData.landmark = segmentGFP(processedData.GFP, resolution);
    
    disp('Segmenting mCherry channel...');
    [processedData.cells, processedData.cellCoordinates] = segmentCells(processedData.mCherry, resolution);
    
    % check the orientation of the embryo and flip to be head-right
    headOrientation = determineHeadOrientation(computeMIP(processedData.landmark));
    if strcmp(headOrientation, 'left')
        disp('Rotating data...');
        processedData = flipOrientation(processedData); %TODO: Rotate cell coordinates
    end
    
    % estimate embryo surface by fitting an ellipsoid
    disp('Estimating embryo surface...');
    ellipsoid = estimateEmbryoSurface(processedData.Dapi, resolution);
    
    % compute transformation which normalizes the estimated ellipsoid to a unit sphere
    disp('Compute transformation from optimal ellipsoid...');
    transformationMatrix = computeTransformationMatrix(ellipsoid);
    
    %%%%%%%%%%% VALIDITY CHECK FOR DEBUGGING
    if debug == 1
        disp('Transform data for validity check...');
        [ transformedData, transformedResolution ] = transformDataToSphere( processedData, resolution, transformationMatrix, ellipsoid, samples_cube );
    end
    
    % project landmark onto unit sphere
    disp('Projecting landmark onto embryo surface...');
    [sphereCoordinates, landmarkCoordinates, landmarkOnSphere] = ...
        projectLandmarkOnSphere(processedData.landmark, resolution, ellipsoid, samples_sphere);
    
    % estimate optimal rotation to register data to reference point with reference orientation
    disp('Estimating transformation from projected landmark...');
    rotationMatrix = ...
        registerLandmark(landmarkCoordinates, reference_point, reference_vector, landmarkCharacteristic);
    
    %%%%%%%%%%% VALIDITY CHECK FOR DEBUGGING
    if debug == 1
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
    registeredData = registerData( processedData, resolution, transformation_registration, ellipsoid, samples_cube);
    
    % visualize results if needed
    if visualization == 1
        visualizeResults(experimentData, processedData, registeredData);
    end
end