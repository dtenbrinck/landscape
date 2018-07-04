% for each dynamic feature, e.g., velocity or track straightness, we
% assume the value has been determined with respect to the next timepoint t+1

%% INITIALIZATION
clear; clc; close all;

% define root directory
root_dir = fileparts(fileparts(pwd));

% add path for parameter setup
addpath([root_dir '/parameter_setup/']);

% load necessary variables
p = initializeScript('processing_dynamic', root_dir);

% manual set resolution parameter
%manRes = [0,0,0];

% set scale of x-y resolution
p.scale = 0.5;

% adjust resolution according to scale parameter
% TODO: This has to be done in preprocessing not here!
%p.resolution(1:2) = p.resolution(1:2) / p.scale;


%% GET DATA METAINFORMATION

% get list of subdirectories in which the data resides
dirContent = dir(p.dataPath);
numberSubdirs = sum([dirContent(~ismember({dirContent.name},{'.','..'})).isdir]);
listSubdirs = dirContent(~ismember({dirContent.name},{'.','..'}) & [dirContent.isdir]);
namesSubdirs = cell(numberSubdirs,1);
for i=1:numberSubdirs
    namesSubdirs{i} = listSubdirs(i).name;
end


%% LOOP OVER ALL DATA DIRECTORIES
%%% WE ASSUME THAT EACH DYNAMIC DATA SET IS IN IT'S OWN SUBDIRECTORY

% initialize struct array to save dynamic information for all PGCs
results = struct([]);

% loop over all subdirectories each containing one dynamic data set
for i=1:numberSubdirs
    path_data = [p.dataPath '/' namesSubdirs{i}];
    
    fileNamesTIF = getTIFfilenames(path_data);
    
    % get static reference data of current data set
    if p.debug_level >= 1; disp('Loading data...'); end
    BFP = loadStaticTIF([path_data '/' fileNamesTIF{1}]); % load BFP
    GFP = loadStaticTIF([path_data '/' fileNamesTIF{2}]); % load GFP
    
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
      
    % compute registration transformation from original data space
    registrationMatrix = transformationMatrix * rotationMatrix';
    
    % get list of *.mat files in directory
    fileNamesMAT = getMATfilenames(path_data);
    
    % get index of *.mat file containing the substring 'corrected'
    %fileIndex = find(contains(fileNamesMAT, 'corrected'));
    fileIndex = find(~cellfun(@isempty,strfind(fileNamesMAT, 'corrected')));
    
    % load tracks of flow corrected PGC cells
    tmp = load([path_data '/' fileNamesMAT{fileIndex}]);
    PGC_tracks = tmp.tracks_PGC;
    
    % determine number of tracked PGCs for this data set
    numberPGCs = size(PGC_tracks,1);
 
    % initialize struct array to save dynamic information for this data set
    PGC_information = struct([]);
    
    % loop over every tracked PGC
    for j=1:numberPGCs
        
        % determine number of time points this PGC has been detected
        numberTimepoints = size(PGC_tracks{j},1);
        
        %% extract dynamic features of tracked PGCs
        % WE ASSUME: originalPositions(2,:) - originalPositions(1,:) = distance(1,:)
        
        % extract original position of PGC at time point t as (x,y,z) coordinates
        PGC_information(j).originalPositions = transpose(PGC_tracks{j}(:,2:4));
        
        % transform PGC coordinates into reference system
        PGC_information(j).registeredPositions = transformCoordinates(PGC_information(j).originalPositions', ellipsoid.center, registrationMatrix^-1, [0; 0; 0]);
        
        % extract time interval between timepoints
        PGC_information(j).deltaT = transpose(PGC_tracks{j}(:,5));
        
        % extract traveled distance of PGC in mumeter as (x,y,z) vector
        distance = PGC_tracks{j}(:,6:8);
        
        % extract velocity of PGC in mumeter/timeinterval as (x,y,z) vector
        velocity = PGC_tracks{j}(:,9:11);
        
        %%% SANITY CHECK: Check if velocity is distance / deltaT
        if p.debug_level >= 2
           assert(isequal(velocity, distance./repmat(deltaT,1,3)));
        end
        
        % extract background velocity in mumeter/timeinterval as (x,y,z) vector
        background_velocity = PGC_tracks{j}(:,12:14);
        
        % compute net velocity of PGC by subtracting background velocity
        PGC_information(j).net_velocity = (velocity - background_velocity)';
        
    end
    
    % concatenate PGC information from this data set with global struct array
    results{i}.PGC_information = PGC_information;
    results{i}.path = path_data;
    results{i}.registrationMatrix = registrationMatrix;

end

%% SAVE DYNAMIC INFORMATION TO FILE
% create filename to save results
results_filename = [p.resultsPath '/dynamic_features.mat'];

% save collected dynamic features of all tracked PGCs
save(results_filename,'results');

if p.debug_level >= 1; disp('Saved results successfully!'); end

%% USER OUTPUT
fprintf('\n');
disp('All data sets in folder processed!');
%clear all;