function test_ellipsoid(p)

%% LOAD DATA
global nucleiTestCoordinates;
old_setting = p.ellipsoidFitting.visualization;
p.ellipsoidFitting.visualization = 1;

if ~isempty(nucleiTestCoordinates)
    processedData.nucleiCoordinates = nucleiTestCoordinates;
else

p.dataPath = uigetdir('Please select a folder with the data');

% get filenames of STK / TIF files in selected folder
fileNames = getTIFfilenames(p.dataPath);

% extract only valid experiments with three data sets
allValidExperiments = checkExperimentChannels(fileNames);

% get number of experiments
numberOfExperiments = size(allValidExperiments,1);

if numberOfExperiments < 1
    return
end

%% MAIN LOOP

experiment=1;
    
        
        % get data of current experiment
        if p.debug_level >= 1; disp('Loading data...'); end
        experimentData = loadExperimentData(allValidExperiments(experiment,:), p.dataPath);
        
        % preprocess and rescale data
        if p.debug_level >= 1; disp('Preprocessing data...'); end
        processedData = preprocessData(experimentData, p);
        
        % segment data
        if p.debug_level >= 1; disp('Segmenting DAPI channel...'); end
        [processedData.nuclei, processedData.nucleiCoordinates, processedData.embryoShape] =...
            segmentDAPI(processedData.Dapi, p.DAPIseg, p.resolution);
        nucleiTestCoordinates = processedData.nucleiCoordinates;
        end
        
        % estimate embryo surface by fitting an ellipsoid
        if p.debug_level >= 1; disp('Estimating embryo surface...'); end
        ellipsoid = estimateEmbryoSurface(processedData.nucleiCoordinates, p.resolution, p.ellipsoidFitting);
    
p.ellipsoidFitting.visualization = old_setting;