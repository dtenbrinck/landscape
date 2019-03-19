function heatmap_singleExperiment (p)
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

%%% TODO: refactor code in this file to make pipeline more generic!

% -- Compute all valid cell coordinates from the processed and registered data -- %
[allCellCoordsGrid, allCellCoords] = getAllValidCellCoords(p.gridSize,fileNames,numberOfResults,p.tole,p.resultsPathAccepted, p.handledChannel);

% -- Compute the Accumulator from the cell coordinates -- %
accumulator = computeAccumulator(allCellCoordsGrid, p.gridSize);

% --- Generate shells with valid cell coordinates per shell
[landmarkShell, aboveLandmark, belowLandmark] = computeLandmarkShell(allCellCoords, p, fileNames, numberOfResults);

shells = cell(0,1);
shells{1} = aboveLandmark;
shells{2} = landmarkShell;
shells{3} = belowLandmark;

% sanity check: for nonoverlapping shells the sum of all coordinates should stay constant
if p.option.shellShiftWidth == p.option.shellThickness
    numberOfCells=0;
    for i=1:size(shells,2)
        numberOfCells = numberOfCells + size(shells{i},2);
    end
    assert(numberOfCells == size(allCellCoords,2));
end

%% COMPUTE ACCUMULATOR
if strcmp(p.handledChannel, 'DAPI')
    
    % make sure to use specific cell radius for dapi cells
    if ( isfield(p.option, 'dapiCellradius') )
        p.option.cellradius = p.option.dapiCellradius;
    else
        p.option.cellradius = 2; % use default size for dapi cell radius
    end
elseif strcmp(p.handledChannel, 'mCherry')
    
    %% SLICE WISE PLOTS WITH PROJECTED REFERENCE LANDMARK
    %fig_filename_base = [p.resultsPath ,'/heatmaps/'];
    %referenceLandmark = computeReferenceLandmark(fileNames,numberOfResults, p);
    %createSlicesPlots(accumulator, p.option, 'Number of PGCs', referenceLandmark, [fig_filename_base, 'PGCs_positions'], 1);

else
    fprintf('There is no correct channel selected to generate heatmaps!\n');
    return;
end

%% HANDLE HEATMAPS ( Computation, drawing and saving ) 
handleHeatmaps(accumulator,shells,size(allCellCoords,2),numberOfResults,p,p.option);

%% USER OUTPUT
disp('All results in folder processed!');

end