%% INITIALIZATION
clear; clc; close all;

% define root directory
root_dir = pwd;

% add path for parameter setup
addpath([root_dir '/parameter_setup/']);

% load necessary variables
p = initializeScript('processing', root_dir);

%% PREPARE RESULTS DIRECTORY
checkDirectory(p.resultsPath);

%% LOAD DATA

% get filenames of STK files in selected folder
fileNames = getTIFfilenames(p.dataPath);
fileNamesCorrectedTracks = getMATtracks_corrected(p.dataPath);

% extract only valid experiments with three data sets
allValidExperiments = checkExperimentChannelsForBFPandGFPdata(fileNames);

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
    
    try
        % get data of current experiment
        if p.debug_level >= 1; disp('Loading data...'); end
        % get static reference data of current data set
        if p.debug_level >= 1; disp('Loading data...'); end
        experimentData = loadExperimentData(allValidExperiments(experiment,:), p.dataPath);
            
        % preprocess and rescale data
        if p.debug_level >= 1; disp('Preprocessing data...'); end
        processedData = preprocessData(experimentData, p);

        % segment data
        if p.debug_level >= 1; disp('Segmenting GFP channel...'); end
        processedData.landmark = segmentGFP(processedData.GFP, p.GFPseg, p.resolution);

        if p.debug_level >= 1; disp('Segmenting DAPI channel...'); end
        [processedData.nuclei, processedData.nucleiCoordinates] = segmentDAPI(processedData.Dapi, p.DAPIseg, p.resolution);

        % estimate embryo surface by fitting an ellipsoid
        if p.debug_level >= 1; disp('Estimating embryo surface...'); end
        ellipsoid = estimateEmbryoSurface(processedData.nucleiCoordinates, p.resolution, p.ellipsoidFitting);
        % compute transformation which normalizes the estimated ellipsoid to a unit sphere
        if p.debug_level >= 1; disp('Compute transformation from optimal ellipsoid...'); end
        transformationMatrix = computeTransformationMatrix(ellipsoid);

        %%%%%%%%%%% VALIDITY CHECK FOR DEBUGGING
        if p.debug_level >= 2
            disp('Transform data for validity check...');
            [ transformedData, transformedResolution ] = transformDataToSphere( processedData, p.resolution, transformationMatrix, ellipsoid, p.samples_cube );
        end

        % project landmark onto unit sphere
        if p.debug_level >= 1; disp('Projecting landmark onto embryo surface...'); end
        [sphereCoordinates, landmarkCoordinates, landmarkOnSphere] = ...
            projectLandmarkOnSphere(processedData.landmark, p.resolution, ellipsoid, p.samples_sphere);

        % estimate optimal rotation to register data to reference point with reference orientation
        if p.debug_level >= 1; disp('Estimating transformation from projected landmark...'); end        
        rotationMatrix = ...
            registerLandmark(landmarkCoordinates, p.reg);

        %%%%%%%%%%% VALIDITY CHECK FOR DEBUGGING
        if p.debug_level >= 2
            % transform projected landmark with estimated rotation
            registered_sphere = ...
                transformCoordinates(sphereCoordinates, [0 0 0]', rotationMatrix, [0 0 0]');

            % visualize projection on unit sphere
            visualizeProjectedLandmark(sphereCoordinates, landmarkOnSphere);
            visualizeProjectedLandmark(registered_sphere', landmarkOnSphere);
        end

        % DEBUG
        transformedCoordinates = rotationMatrix * landmarkCoordinates';

        % compute registration transformation from original data space
        transformation_registration = transformationMatrix * rotationMatrix';
        
        % evaluate PGC velocities
        load([p.dataPath,'/', fileNamesCorrectedTracks{experiment}]);
        if p.debug_level >= 1; disp('Consider PGC velocities from tracking info...'); end
        [processedData.dynamic.cellCoordinates, ...
            processedData.dynamic.cellVelocities] ...
            = evaluateVelocitiesFromTracking(tracks_PGC);
        
        %%% TODO sasser implement like Daniel a SANITY CHECK: Check if velocity is distance / deltaT
        
        % register data
        if p.debug_level >= 1; disp('Registering data...'); end
        registeredData = registerData( processedData, p.resolution, transformation_registration, ellipsoid, p.samples_cube);
        
        % create filename to save results
        results_filename = [p.resultsPath '/' experimentData.filename '_results.mat'];

        gatheredData = saveResultsDynamics(experimentData, processedData, registeredData, ellipsoid, transformationMatrix, rotationMatrix, results_filename);

        % visualize results if needed
        if p.visualization == 1
            visualizeResults_new(gatheredData);
        end
        
        if p.debug_level >= 1; disp('Saved results successfully!'); end
        
    catch ERROR_MSG  %% ONLY EXECUTED WHEN ERRORS HAPPENING
        
        % create filename to save results
        results_filename = [p.resultsPath '/bug/' experimentData.filename '_results.mat'];
        
        % save results
        saveErrorMsg(results_filename, ERROR_MSG);
        
        if p.debug_level >= 1; disp('Saved buggy dataset!'); end
        
    end
end

% Save parameters
save([p.resultsPath '/accepted/ParameterProcessing.mat'],'p');
%% USER OUTPUT
fprintf('\n');
disp('All data sets in folder processed!');
clear all;
