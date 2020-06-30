function generateHeatmaps(p)
%% GET FILES TO PROCESS

if isfile([p.resultsPath, '/AllAccumulators.mat'])
    load([p.resultsPath, '/AllAccumulators.mat']);
    handleHeatmaps(accumulators,shells,numberOfResults,p);
    return
end

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
    disp([ num2str(numberOfResults) ' results found in folder for generating heatmap.']);
end

%% GET DATA SIZE FOR ACCUMULATOR

% Load first data set
load([p.resultsPathAccepted,'/',fileNames{1,1}]);
% Original data size (in px and um)
 origSize_px = gatheredData.processed.size;
 origSize_um = origSize_px .* p.resolution;
 
% adjust grid size and resolution of Mercator projection for dynamic Heatmap size 
try 
    dynamicHeatmapsize = p.dynamicHeatmapsize;
catch 
    dynamicHeatmapsize = 'false'; % in old versions this parameter did not exist
end

if strcmp(dynamicHeatmapsize, 'true')
     M = min(origSize_um); % find the shortest side of the image
     for i = 1:3 
        ratio = origSize_um(i)/M; % calculate ratios of the others sides to the shortest side
        p.gridSize(i) = round(ratio*p.gridSize(i)); % adjust gridSize of accumulator according to ratio
     end
     M = min(origSize_um(1:2)); % find the shortest side of the image (excluding z direction for mercator projection)
     for i = 1:2 
        ratio = origSize_um(i)/M; % calculate ratios of the others sides to the shortest side
        p.option.shellHeatmapResolution(i) = round(ratio*p.option.shellHeatmapResolution(i)); % adjust resolution of Mercator Projection according to ratio
     end    
end

%%% TODO: refactor code in this file to make pipeline more generic!

% -- Compute all valid cell coordinates from the processed and registered data -- %
[PGC_coords_grid, PGC_coords_unitsphere] = getAllValidCellCoords(p.gridSize,fileNames,numberOfResults,p.tole,p.resultsPathAccepted, 'mCherry');
[landmark_coords_grid, landmark_coords_unitsphere] = getAllValidCellCoords(p.gridSize,fileNames,numberOfResults,p.tole,p.resultsPathAccepted, 'GFP');
[nuclei_coords_grid, nuclei_coords_unitsphere] = getAllValidCellCoords(p.gridSize,fileNames,numberOfResults,p.tole,p.resultsPathAccepted, 'DAPI');

%DEBUG;
%lm = landmark_coords_unitsphere;
%PGC = PGC_coords_unitsphere;
%figure; scatter3(lm(3,:), lm(2,:), lm(1,:),5);
%hold on;
%scatter3(PGC(3,:), PGC(2,:), PGC(1,:),25,[1,0,0]);
%hold off;

% -- Compute the Accumulator from the cell coordinates -- %
GFP_accumulator = computeAccumulator(landmark_coords_grid, p);
DAPI_accumulator = computeAccumulator(nuclei_coords_grid, p);
mCherry_accumulator = computeAccumulator(PGC_coords_grid, p);

%clear landmark_coords_grid, nuclei_coords_grid, PGC_coords_grid;

% --- Generate shells with valid cell coordinates per shell
[minRadius, maxRadius] = computeLandmarkShell(p, fileNames, numberOfResults);

% TESTING for thicker shells
minRadius = minRadius - 0.0;
maxRadius = maxRadius + 0.0;

if p.equalSizedShells == true
    %% NEW APPROACH: SHELLS WITH EQUAL SIZE
    
    % compute thickness of landmark shell
    shellThickness = abs(maxRadius - minRadius);
    
    % extract landmark shells
    GFP_landmarkShell = getShell(landmark_coords_unitsphere, minRadius, maxRadius);
    DAPI_landmarkShell = getShell(nuclei_coords_unitsphere, minRadius, maxRadius);
    mCherry_landmarkShell = getShell(PGC_coords_unitsphere, minRadius, maxRadius);
    
    % initialize auxiliary variables
    numberOfShellsExtracted = 0;
    shellsEmpty = false;
    currentRadius = maxRadius;
    
    GFP_aboveShells = cell(0,1);
    DAPI_aboveShells = cell(0,1);
    mCherry_aboveShells = cell(0,1);
    
    % extract shells above landmark
    while shellsEmpty == false && numberOfShellsExtracted < 25
        
        % update counter variable
        numberOfShellsExtracted = numberOfShellsExtracted + 1;
        
        % extract shells
        GFP_aboveShells{numberOfShellsExtracted} = getShell(landmark_coords_unitsphere, currentRadius+eps, currentRadius + shellThickness);
        DAPI_aboveShells{numberOfShellsExtracted} = getShell(nuclei_coords_unitsphere, currentRadius+eps, currentRadius + shellThickness);
        mCherry_aboveShells{numberOfShellsExtracted} = getShell(PGC_coords_unitsphere, currentRadius+eps, currentRadius + shellThickness);
        
        % update currentRadius
        currentRadius = currentRadius + shellThickness;
        
        % check if all shells are empty (outside of region of interest)
        if sum(GFP_aboveShells{numberOfShellsExtracted}(:)) + sum(DAPI_aboveShells{numberOfShellsExtracted}(:)) + sum(mCherry_aboveShells{numberOfShellsExtracted}(:)) == 0
            shellsEmpty = true;
        end
    end
    
    % give some output
    disp(['Number of above shells extracted: ' num2str(numberOfShellsExtracted)]);
    
    % reinitialize auxiliary variables
    numberOfShellsExtracted = 0;
    shellsEmpty = false;
    currentRadius = minRadius;
    
    GFP_belowShells = cell(0,1);
    DAPI_belowShells = cell(0,1);
    mCherry_belowShells = cell(0,1);
    
    % extract shells above landmark
    while shellsEmpty == false && numberOfShellsExtracted < 25
        
        % update counter variable
        numberOfShellsExtracted = numberOfShellsExtracted + 1;
        
        % make sure we stay positive
        if currentRadius - shellThickness < 0
            shellThickness = currentRadius;
            shellsEmpty = true;
        end
        
        % extract shells
        GFP_belowShells{numberOfShellsExtracted} = getShell(landmark_coords_unitsphere, currentRadius - shellThickness, currentRadius-eps);
        DAPI_belowShells{numberOfShellsExtracted} = getShell(nuclei_coords_unitsphere, currentRadius - shellThickness, currentRadius-eps);
        mCherry_belowShells{numberOfShellsExtracted} = getShell(PGC_coords_unitsphere, currentRadius - shellThickness, currentRadius-eps);
        
        % update currentRadius
        currentRadius = currentRadius - shellThickness;
        
        % check if all shells are empty (outside of region of interest)
        if sum(GFP_belowShells{numberOfShellsExtracted}(:)) + sum(DAPI_belowShells{numberOfShellsExtracted}(:)) + sum(mCherry_belowShells{numberOfShellsExtracted}(:)) == 0
            shellsEmpty = true;
        end
    end
    
    % give some output
    disp(['Number of below shells extracted: ' num2str(numberOfShellsExtracted)]);
    
    % generate shells
    GFP_shells = cell(0,1);
    DAPI_shells = cell(0,1);
    mCherry_shells = cell(0,1);
    
    % above shells are saved in wrong order so we need to invert the order here
    numberOfShells = 1;
    for currentShell = size(GFP_aboveShells,2):-1:1
        GFP_shells{numberOfShells} = GFP_aboveShells{currentShell};
        DAPI_shells{numberOfShells} = DAPI_aboveShells{currentShell};
        mCherry_shells{numberOfShells} = mCherry_aboveShells{currentShell};
        numberOfShells = numberOfShells + 1;
    end
    
    % save landmark shell
    GFP_shells{numberOfShells} = GFP_landmarkShell;
    DAPI_shells{numberOfShells} = DAPI_landmarkShell;
    mCherry_shells{numberOfShells} = mCherry_landmarkShell;
    numberOfShells = numberOfShells + 1;
    
    % below shells are already in right order
    for currentShell = 1:size(GFP_belowShells,2)
        GFP_shells{numberOfShells} = GFP_belowShells{currentShell};
        DAPI_shells{numberOfShells} = DAPI_belowShells{currentShell};
        mCherry_shells{numberOfShells} = mCherry_belowShells{currentShell};
        numberOfShells = numberOfShells + 1;
    end
    
else
    %% OLD APPROACH: EXTRACT THREE SHELLS - LANDMARK, ABOVE, BELOW
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
    
end
%%

shells = struct;
shells.GFP = GFP_shells;
shells.DAPI = DAPI_shells;
shells.mCherry = mCherry_shells;


accumulators = struct;
accumulators.GFP = GFP_accumulator;
accumulators.DAPI = DAPI_accumulator;
accumulators.mCherry = mCherry_accumulator;

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
handleHeatmaps(accumulators,shells, origSize_px,numberOfResults, p);

%% USER OUTPUT
disp('All results in folder processed!');

end
