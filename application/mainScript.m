%% INITIALIZATION

% add current folder and subfolders to path variable
addpath(genpath('./..'));

%% SET PARAMETERS

dataPath = '../data/tilting_adjustments_first_priority';
resolution = [1.29, 1.29, 20];
scale = 0.5;
samples_sphere = 64;
samples_cube = 256;
landmarkCharacteristic = 'middle';
reference_point = [0; 0; -1];
reference_vector = [1; 0; 0];

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
    landmark = segmentGFP(processedData.GFP, resolution);
    disp('Segmenting mCherry channel...');
    [cells, cellCoordinates] = segmentCells(processedData.mCherry, resolution);
    
    % check the orientation of the embryo and flip to be head-right
    headOrientation = determineHeadOrientation(computeMIP(landmark));
    if strcmp(headOrientation, 'left')
        disp('Rotating data...');
        [processedData, landmark, cells, cellCoordinates] = ...
            flipOrientation(processedData, landmark, cells, cellCoordinates);
    end
    
    % estimate embryo surface by fitting an ellipsoid
    disp('Estimating embryo surface...');
    ellipsoid = estimateEmbryoSurface(processedData.Dapi, resolution);
    
    % compute transformation which normalizes the estimated ellipsoid to a
    % unit sphere
    disp('Compute transformation from optimal ellipsoid...');
    transformationMatrix = computeTransformationMatrix(ellipsoid);
    
    %%%%%%%%%%% VALIDITY CHECK
    disp('Transform data for validity check...');
    [transformedData.Dapi, transformedResolution] = ...
        transformVoxelData(processedData.Dapi, resolution, transformationMatrix, ellipsoid.center, samples_cube);
    [transformedData.GFP, ~] = ...
        transformVoxelData(processedData.GFP, resolution, transformationMatrix, ellipsoid.center, samples_cube);
    [transformedData.mCherry, ~] = ...
        transformVoxelData(processedData.mCherry, resolution, transformationMatrix, ellipsoid.center, samples_cube);
    [transformedCells, ~] = ...
        transformVoxelData(cells, resolution, transformationMatrix, ellipsoid.center, samples_cube);
    [transformedLandmark, ~] = ...
        transformVoxelData(landmark, resolution, transformationMatrix, ellipsoid.center, samples_cube);
    
    % project landmark onto unit sphere
    disp('Projecting landmark onto embryo surface...');
    [sphereCoordinates, landmarkCoordinates, landmarkOnSphere] = ...
        projectLandmarkOnSphere(landmark, resolution, ellipsoid, samples_sphere);
    
    
    %%%%%%%%%%%%%% DEBUG -> AB HIER FUNKTIONIERT NOCHT NICHT!
    
    % estimate transformation needed to register data to reference point
    % with reference orientation
    disp('Registering data...');
    transformation_registration = ...
        registerLandmark(landmarkCoordinates, reference_point, reference_vector, landmarkCharacteristic);
    
    registered_sphere = ...
        transformCoordinates(sphereCoordinates, [0 0 0]', transformaton_registration^-1, [0 0 0]');
    
    % visualize projection on unit sphere
    visualizeProjectedLandmark(sphereCoordinates, landmarkOnSphere);
    visualizeProjectedLandmark(registered_sphere, landmarkOnSphere);
    
    % klappt noch nicht
    [registeredData.GFP, ~] = ...
        transformVoxelData(transformedData.GFP, transformedResolution, transformation_registration, [0 0 0]', samples_cube);
    
end