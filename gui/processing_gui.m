function processing_gui(p)
%processing_gui processes the selected data with given parameters p
    %This function allows the user to select a data path and then prepares
    %the data for analysis in 4 steps:
    %1. preprocessing
    %2. segmentation
    %3. normalization
    %4. rotation
    
%% PREPARE RESULTS DIRECTORY
checkDirectory(p.resultsPath);

%% LOAD DATA

% get filenames of STK / TIF files in selected folder
fileNames = getTIFfilenames(p.dataPath);

% extract only valid experiments with three data sets
allValidExperiments = checkExperimentChannels(fileNames);

% get number of experiments
numberOfExperiments = size(allValidExperiments,1);

%% MAIN LOOP

fprintf('Processing dataset:'); 
    
% process all existing data in parallel unless specified otherwise
if p.parallelpool == 1
    maximumNumberOfWorkers = Inf;
else
    maximumNumberOfWorkers = 0;
end

parfor (experiment=1:numberOfExperiments,maximumNumberOfWorkers)
    
    % show remotecurrent experiment number
    dispCounter(experiment, numberOfExperiments);
    
    try
        % get data of current experiment
        if p.debug_level >= 1; disp('Loading data...'); end
        experimentData = loadExperimentData(allValidExperiments(experiment,:), p.dataPath);
        

        %1. PREPROCESSING        
        % preprocess and rescale data
        if p.debug_level >= 1; disp('Preprocessing data...'); end
        processedData = preprocessData(experimentData, p);
        
        
        %2. SEGMENTATION
        % segment data in all three channels
        if p.debug_level >= 1; disp('Segmenting GFP channel...'); end
        [processedData.landmark, processedData.landmarkCentCoords] =...
            segmentGFP(processedData.GFP, p.GFPseg, p.resolution);
        
        if p.debug_level >= 1; disp('Segmenting DAPI channel...'); end
        [processedData.nuclei, processedData.nucleiCoordinates, processedData.embryoShape] =...
            segmentDAPI(processedData.Dapi, p.DAPIseg, p.resolution);
        
        %segment mCherry channel depending on selected mappingtype
        if p.debug_level >= 1; disp('Segmenting mCherry channel...'); end
        if strcmp(p.mappingtype, 'Cells')
        [processedData.cells, processedData.cellCoordinates] =...
            blobSegmentCells(processedData.mCherry, p.mCherryseg, processedData.embryoShape); 
        else
        [processedData.cells, processedData.cellCoordinates] =...
            segmentGFP(processedData.mCherry, p.TISSUEseg, p.resolution);
        end

        
        %3. NORMALIZATION
        % estimate embryo surface by fitting an ellipsoid
        if p.debug_level >= 1; disp('Estimating embryo surface...'); end
        ellipsoid = estimateEmbryoSurface(processedData.nucleiCoordinates, p.resolution, p.ellipsoidFitting);
        
        % compute transformation which normalizes the estimated ellipsoid to a unit sphere
        if p.debug_level >= 1; disp('Compute transformation from optimal ellipsoid...'); end
        normalizationMatrix = computeTransformationMatrix(ellipsoid);
        
        %%%%%%%%%%% VALIDITY CHECK FOR DEBUGGING
        if p.debug_level >= 2
            disp('Transform data for validity check...');
            [ ~, ~ ] = transformDataToSphere( processedData, p.resolution, normalizationMatrix, ellipsoid, p.samples_cube );
        end
        
        % project landmark onto unit sphere
        if p.debug_level >= 1; disp('Projecting landmark onto embryo surface...'); end
        [sphereCoordinates, landmarkCoordinates, landmarkOnSphere] = ...
            projectLandmarkOnSphere(processedData.landmark, p.resolution, ellipsoid, p.samples_sphere);
        
        
        %4. ROTATION
        % estimate optimal rotation to register data to reference point with reference orientation
        if p.debug_level >= 1; disp('Estimating transformation from projected landmark...'); end        
        rotationMatrix = ...
            registerLandmark(landmarkCoordinates, p.reg);
        
        % visualize the rotation of the projected landmark
        if p.reg.visualization
            % transform projected landmark with estimated rotation
            registered_sphere = ...
                transformCoordinates(sphereCoordinates, [0 0 0]', rotationMatrix, [0 0 0]');
            
            % visualize projection on unit sphere
            visualizeProjectedLandmark(sphereCoordinates, landmarkOnSphere);
            visualizeProjectedLandmark(registered_sphere', landmarkOnSphere);
        end
        
        
        % compute registration transformation from original data space
        transformation_registration = normalizationMatrix * rotationMatrix';
        
        % register data
        if p.debug_level >= 1; disp('Registering data...'); end
        registeredData = registerData( processedData, p.resolution, transformation_registration, ellipsoid, p.samples_cube);
                
        % create filename and save results
        results_filename = [p.resultsPath '/' experimentData.filename '_results.mat'];
        gatheredData = saveResults(experimentData, processedData, registeredData, ellipsoid, normalizationMatrix, rotationMatrix, results_filename, p);
        
        % visualize results if needed
        if p.visualization == 1
            visualizeResults_new(gatheredData);
        end
        
        %save proof of principle if needed 
        if p.proofOfPrinciple >= 1
            results_filename = [p.resultsPath '/' experimentData.filename];
            
            rotationMatrix = normalizationMatrix./repmat(ellipsoid.radii,[1,3]);
            proofOfPrinciple(results_filename, registeredData, experimentData, processedData, p.resolution, inv(rotationMatrix)*normalizationMatrix, ellipsoid.center, p.samples_cube);
        end
        
        
        if p.debug_level >= 1; disp('Saved results successfully!'); end
        
        catch ERROR_MSG  %% ONLY EXECUTED WHEN ERRORS HAPPENING
        
        disp(ERROR_MSG)
        
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
%clear all;
end
