function heatmap_singleExperiment_shells (p)
%% GET FILES TO PROCESS

% Get filenames of MAT files in selected folder
fileNames = getMATfilenames(p.resultsPathAccepted);
fileNames(strcmp(fileNames,'ParameterProcessing.mat')) = [];
fileNames(strcmp(fileNames,'ParameterHeatmap.mat')) = [];
fileNames(strcmp(fileNames,'HeatmapAccumulator.mat')) = [];

if p.random == 1
    fileNames = drawRandomNames(fileNames,p.numberOfRandom);
end
% Get number of experiments
numberOfResults = numel(fileNames);

% Check if any results have been found
if numberOfResults == 0
    disp('All results already processed or path to results folder wrong?');
    disp(resultsPathAccepted);
    return;
else
    disp([ num2str(numberOfResults) ' results found in folder for generating heat map.']);
end

%% GET DATA SIZE FOR ACCUMULATOR

% Load first data set
load([p.resultsPathAccepted,'/',fileNames{1,1}]);

% Original data size (in mu)
% origSize = gatheredData.processed.originalSize;

%% COMPUTE ACCUMULATOR
if strcmp(p.handledChannel, 'DAPI')
    % -- Compute all valid cell coordinates from the processed and registered data -- %
    allCellCoords = getAllValidCellCoords_DAPI(p.gridSize,fileNames,numberOfResults,p.tole,p.resultsPathAccepted);

    % -- Compute the Accumulator from the cell coordinates -- %
    accumulator = computeAccumulator_DAPI(allCellCoords, p.gridSize);

    % make sure to use specific cell radius for dapi cells
    if ( isfield(p.option, 'dapiCellradius') )
        p.option.cellradius = p.option.dapiCellradius;
    else
        p.option.cellradius = 2; % use default size for dapi cell radius
    end
elseif strcmp(p.handledChannel, 'mCherry')
    % -- Compute all valid cell coordinates from the processed and registered data -- %
    allCellCoords = getAllValidCellCoords_shells(p.gridSize,fileNames,numberOfResults,p.tole,p.resultsPathAccepted);
    
    % -- Compute the Accumulator from the cell coordinates -- %
    accumulator = computeAccumulator(allCellCoords, p.gridSize);
    
    % -- Define shell with landmark inside
    %shell = getLandmarkShell(allCellCoords, p.option.shellThickness, p.option.shellShiftWidth);
    
    %% SLICE WISE PLOTS WITH PROJECTED REFERENCE LANDMARK
    fig_filename_base = [p.resultsPath ,'/heatmaps/'];
    referenceLandmark = computeReferenceLandmark(fileNames,numberOfResults, p);
    createSlicesPlots(accumulator, p.option, 'Number of PGCs', referenceLandmark, [fig_filename_base, 'PGCs_positions'], 1);

else
    fprintf('There is no correct channel selected to generate heatmaps!\n');
    return;
end

%% HANDLE HEATMAPS ( Computation, drawing and saving ) 
handleHeatmaps(accumulator,size(allCellCoords,2),numberOfResults,p,p.option);

%% USER OUTPUT
disp('All results in folder processed!');

end