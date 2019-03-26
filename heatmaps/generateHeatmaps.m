function generateHeatmaps(p)
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
[landmark_coords_grid, landmark_coords_unitsphere] = getAllValidCellCoords(p.gridSize,fileNames,numberOfResults,p.tole,p.resultsPathAccepted, 'GFP');
[nuclei_coords_grid, nuclei_coords_unitsphere] = getAllValidCellCoords(p.gridSize,fileNames,numberOfResults,p.tole,p.resultsPathAccepted, 'DAPI');
[PGC_coords_grid, PGC_coords_unitsphere] = getAllValidCellCoords(p.gridSize,fileNames,numberOfResults,p.tole,p.resultsPathAccepted, 'mCherry');


%DEBUG;
%lm = landmark_coords_unitsphere;
%PGC = PGC_coords_unitsphere;
%figure; scatter3(lm(3,:), lm(2,:), lm(1,:),5);
%hold on;
%scatter3(PGC(3,:), PGC(2,:), PGC(1,:),25,[1,0,0]);
%hold off;

% -- Compute the Accumulator from the cell coordinates -- %
GFP_accumulator = computeAccumulator(landmark_coords_grid, p.gridSize);
DAPI_accumulator = computeAccumulator(nuclei_coords_grid, p.gridSize);
mCherry_accumulator = computeAccumulator(PGC_coords_grid, p.gridSize);

%clear landmark_coords_grid, nuclei_coords_grid, PGC_coords_grid;

% --- Generate shells with valid cell coordinates per shell
[minRadius, maxRadius] = computeLandmarkShell(p, fileNames, numberOfResults);

GFP_landmarkShell = getShell(landmark_coords_unitsphere, minRadius, maxRadius);
GFP_aboveLandmark = getShell(landmark_coords_unitsphere, maxRadius+eps, Inf);
GFP_belowLandmark = getShell(landmark_coords_unitsphere, 0, minRadius-eps);

GFP_shells = cell(0,1);
GFP_shells{1} = GFP_aboveLandmark;
GFP_shells{2} = GFP_landmarkShell;
GFP_shells{3} = GFP_belowLandmark;
GFP_shells{4} = getShell(landmark_coords_unitsphere,0,Inf);

DAPI_landmarkShell = getShell(nuclei_coords_unitsphere, minRadius, maxRadius);
DAPI_aboveLandmark = getShell(nuclei_coords_unitsphere, maxRadius+eps, Inf);
DAPI_belowLandmark = getShell(nuclei_coords_unitsphere, 0, minRadius-eps);

DAPI_shells = cell(0,1);
DAPI_shells{1} = DAPI_aboveLandmark;
DAPI_shells{2} = DAPI_landmarkShell;
DAPI_shells{3} = DAPI_belowLandmark;
DAPI_shells{4} = getShell(nuclei_coords_unitsphere,0,Inf);

mCherry_landmarkShell = getShell(PGC_coords_unitsphere, minRadius, maxRadius);
mCherry_aboveLandmark = getShell(PGC_coords_unitsphere, maxRadius+eps, Inf);
mCherry_belowLandmark = getShell(PGC_coords_unitsphere, 0, minRadius-eps);

mCherry_shells = cell(0,1);
mCherry_shells{1} = mCherry_aboveLandmark;
mCherry_shells{2} = mCherry_landmarkShell;
mCherry_shells{3} = mCherry_belowLandmark;
mCherry_shells{4} = getShell(PGC_coords_unitsphere,0,Inf);

%%

shells = cell(0,1);
shells{1} = GFP_shells;
shells{2} = DAPI_shells;
shells{3} = mCherry_shells;


accumulators = cell(0,1);
accumulators{1} = GFP_accumulator;
accumulators{2} = DAPI_accumulator;
accumulators{3} = mCherry_accumulator;

% sanity check: for nonoverlapping shells the sum of all coordinates should stay constant
% if p.option.shellShiftWidth == p.option.shellThickness
%     numberOfCells=0;
%     for i=1:size(shells,2)
%         numberOfCells = numberOfCells + size(shells{i},2);
%     end
%     assert(numberOfCells == size(allCellCoords,2));
% end


% %% COMPUTE ACCUMULATOR
% if strcmp(p.handledChannel, 'DAPI')
%     
%     % make sure to use specific cell radius for dapi cells
%     if ( isfield(p.option, 'dapiCellradius') )
%        % p.option.cellradius = p.option.dapiCellradius;
%     else
%        % p.option.cellradius = 2; % use default size for dapi cell radius
%     end
% elseif strcmp(p.handledChannel, 'mCherry')
%     
%     %% SLICE WISE PLOTS WITH PROJECTED REFERENCE LANDMARK
%     %fig_filename_base = [p.resultsPath ,'/heatmaps/'];
%     %referenceLandmark = computeReferenceLandmark(fileNames,numberOfResults, p);
%     %createSlicesPlots(accumulator, p.option, 'Number of PGCs', referenceLandmark, [fig_filename_base, 'PGCs_positions'], 1);
% 
% else
%     fprintf('There is no correct channel selected to generate heatmaps!\n');
%     return;
% end

%% HANDLE HEATMAPS ( Computation, drawing and saving ) 
handleHeatmaps(accumulators,shells,numberOfResults,p);

%% USER OUTPUT
disp('All results in folder processed!');

end