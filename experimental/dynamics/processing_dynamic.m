%% INITIALIZATION
clear; clc; close all;

% define root directory
root_dir = fileparts(fileparts(pwd));

% add path for parameter setup
addpath([root_dir '/parameter_setup/']);

% load necessary variables
p = initializeScript('processing_dynamic', root_dir);

% manual set resolution parameter
manRes = [0,0,0];

% set scale of x-y resolution
p.scale = 0.5;

% adjust resolution according to scale parameter
p.resolution(1:2) = p.resolution(1:2) / p.scale;


%% GET DATA METAINFORMATION

% get list of subdirectories in which the data resides
dirContent = dir(p.dataPath);
numSubdirs = sum([dirContent(~ismember({dirContent.name},{'.','..'})).isdir]);
listSubdirs = dirContent(~ismember({dirContent.name},{'.','..'}) & [dirContent.isdir]);
namesSubdirs = cell(numSubdirs,1);
for i=1:numSubdirs
    namesSubdirs{i} = listSubdirs(i).name;
end

% processing all data is set to default
process_data = ones(1, numSubdirs);

% check if a common transformation is wanted and determine reference timepoint dataset
if p.commonTransformation == true
    midtime = round(numSubdirs/2);
    process_data = ~process_data;
    process_data(midtime) = 1;
end

% extract experiment data numbers to be processed
num_process_data = find(process_data);

% set dummy filename
%experimentData.filename = 'dynamic_data_experimental';

% set dummy resolutions
%experimentData.x_resolution = 312;
%experimentData.y_resolution = 312;

%% LOOP OVER ALL NEEDED DATA DIRECTORIES

% loop over all experiments that should be processed
for i=num_process_data
    path_data = [p.dataPath '/' namesSubdirs{i}];
    
    fileNames = getTIFfilenames(path_data);
    
    % get data of current experiment
    if p.debug_level >= 1; disp('Loading data...'); end
    BFP = loadStaticTIF([path_data '/' fileNames{1}]); % load BFP
    GFP = loadStaticTIF([path_data '/' fileNames{2}]); % load GFP
    
    if p.debug_level >= 1; disp('Preprocessing data...'); end
    %processedData.Dapi = preprocessData(BFP, p, 1); % preprocess BFP/DAPI
    %processedData.GFP = preprocessData(GFP, p, 1); % preprocess BFP/DAPI
    processedData.Dapi = BFP;
    processedData.GFP = GFP;
    
    % segment data
    if p.debug_level >= 1; disp('Segmenting GFP channel...'); end
    processedData.landmark = segmentGFP(processedData.GFP, p.GFPseg, p.resolution);
    
    if p.debug_level >= 1; disp('Segmenting DAPI channel...'); end
    [processedData.nuclei, processedData.nucleiCoordinates] = segmentDAPI(processedData.Dapi, p.DAPIseg, p.resolution);
    
    % estimate embryo surface by fitting an ellipsoid
    if p.debug_level >= 1; disp('Estimating embryo surface...'); end
    ellipsoid = estimateEmbryoSurface(processedData.nucleiCoordinates, p.resolution);
    
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
    
    %        % DEBUG
    %        transformedCoordinates = rotationMatrix * landmarkCoordinates';
    
    % compute registration transformation from original data space
    transformation_registration = transformationMatrix * rotationMatrix';
    
end

%% USER OUTPUT
fprintf('\n');
disp('All data sets in folder processed!');
%clear all;