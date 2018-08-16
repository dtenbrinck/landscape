%% INITIALIZATION
clear; clc; close all;

% define root directory
root_dir = fileparts(fileparts(pwd));

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
allValidExperiments = checkExperimentChannelsForDynamicData(fileNames);

% get number of experiments
numberOfExperiments = size(allValidExperiments,1);

% adjust resolution according to scale parameter
p.resolution(1:2) = p.resolution(1:2) / p.scale;

if (p.resolution(3) == 10 )
    % special case: 10µm slices
    numberOfSlices = 40;
else
    % default case: 20µm slices
    numberOfSlices = 20;
end

%% MAIN LOOP

fprintf('Processing datasets:'); 

% process all existing data sequentially
parfor currentExpNo=1:numberOfExperiments
    
    % show remotecurrent experiment number
    fprintf('\n(%d/%d)\n', currentExpNo, numberOfExperiments);
    
    try
        % get data of current experiment
        if p.debug_level >= 1; disp('Loading dynamic nuclei and landmark data...'); end
        experimentDataWholeTimeInterval = loadExperimentData(allValidExperiments(currentExpNo,:), p.dataPath);
 
        % determine number of timesteps
        numberOfRecordedTimesteps = size(experimentDataWholeTimeInterval.Dapi, 3) / numberOfSlices; 
        numberOfPGCVelocityFrames = numberOfRecordedTimesteps-1;
        
        if p.debug_level >= 1; disp('Loading dynamic pgc data...'); end
        loaded = load([p.dataPath,'/', fileNamesCorrectedTracks{currentExpNo}]);
        tracks_PGC = loaded.tracks_PGC;
        [dynamicCellCoordinatesWholeTimeInterval, ...
                    dynamicCellVelocitiesWholeTimeInterval] ...
                    = getDynamicPGCdataInTimestepStructure...
                    (tracks_PGC, numberOfPGCVelocityFrames );
                
        % TODO: ask wether to start at first or second slices block because
        % we get one more block than from dynamic and corrected pgc data
        for timeframe = 1:numberOfPGCVelocityFrames % TODO: 2:numberOfTimesteps
            fprintf('Processing time frame %d...\n', timeframe);
            
            try
                
                % include data for this timeframe
                % empty initilization to avoid conflict in parfor loop
                experimentData = struct('Dapi', {}, 'GFP', {}, 'filename', {});
                experimentData(1).Dapi = experimentDataWholeTimeInterval.Dapi(:,:,...
                    numberOfSlices*(timeframe-1)+1 : numberOfSlices*timeframe);

                experimentData(1).GFP = experimentDataWholeTimeInterval.GFP(:,:,...
                    numberOfSlices*(timeframe-1)+1 : numberOfSlices*timeframe);

                experimentData(1).filename = [experimentDataWholeTimeInterval.filename ...
                    '_timeframe_' num2str(timeframe) ];
                
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

                % project landmark onto unit sphere
                if p.debug_level >= 1; disp('Projecting landmark onto embryo surface...'); end
                [sphereCoordinates, landmarkCoordinates, landmarkOnSphere] = ...
                    projectLandmarkOnSphere(processedData.landmark, p.resolution, ellipsoid, p.samples_sphere);

                % estimate optimal rotation to register data to reference point with reference orientation
                if p.debug_level >= 1; disp('Estimating transformation from projected landmark...'); end        
                rotationMatrix = ...
                    registerLandmark(landmarkCoordinates, p.reg);
                
                % compute registration transformation from original data space
                transformation_registration = transformationMatrix * rotationMatrix';

                % evaluate PGC velocities
                if p.debug_level >= 1; disp('Consider PGC velocities from tracking info...'); end
                processedData.dynamic.cellCoordinates = dynamicCellCoordinatesWholeTimeInterval{timeframe};
                processedData.dynamic.cellVelocities = dynamicCellVelocitiesWholeTimeInterval{timeframe};

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
    catch ERROR_MSG  %% ONLY EXECUTED WHEN ERRORS HAPPENING

        % create filename to save results
        results_filename = [p.resultsPath '/bug/' experimentDataWholeTimeInterval.filename '_results.mat'];

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
