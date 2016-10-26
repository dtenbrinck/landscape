%% INITIALIZATION
clear; clc; close all;

%% PARAMETER 
tole = 0.1;
% Size of the cells
sizeCells = 20; %um
% Size of the Pixel
sizeOfPixel = 0.29; %um
sizeCellsPixel = round(sizeCells/sizeOfPixel);
%% SET PATH
resultsPath = './results/Small/'; % DONT APPEND '/' TO DIRECTORY NAME!!!
resultsPathAccepted = [resultsPath,'/accepted'];

%% GET FILES TO PROCESS

% Get filenames of MAT files in selected folder
fileNames = getMATfilenames(resultsPathAccepted);

% Get number of experiments
numberOfResults = size(fileNames,1);

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
load([resultsPathAccepted,'/',fileNames{1,1}]);

% Initialize accumulator
accumulator = zeros(gatheredData.registered.registeredSize);

% Original data size (in mu)
origSize = gatheredData.processed.originalSize;
% Accumulator size
accSize = size(accumulator);

% All coordinates of cell centers
allCellCoords = double.empty(3,0);

%% MAIN ACCUMULATOR LOOP
for result = 1:numberOfResults
    
    % Load result data
    load([resultsPathAccepted,'/',fileNames{result,1}])
    
    % Get all cell center coordinates
    allCellCoords = horzcat(allCellCoords, gatheredData.registered.cellCoordinates);
end

% Ignore all that are out of the domain
allCellCoords(:,sum(abs(allCellCoords)>1)>=1) = [];

% Compute norm of each column
normOfCoordinates = sqrt(sum(allCellCoords.^2,1));

% Ignore all coordinates outside the sphere with a tolerance tole
allCellCoords(:,normOfCoordinates > 1+tole) = [];
normOfCoordinates(:,normOfCoordinates > 1+tole) = [];

% Normalize the coordinates that are too big but in tolerance
allCellCoords(:,(normOfCoordinates < 1+tole) == (normOfCoordinates > 1)) ...
    = allCellCoords(:,(normOfCoordinates < 1+tole) == (normOfCoordinates > 1))...
    ./repmat(normOfCoordinates(:,(normOfCoordinates < 1+tole) == (normOfCoordinates > 1)),[3,1]);

% Get rounded cell centroid coordinates
allCellCoords = round(...
    (allCellCoords + repmat([1;1;1], 1, size(allCellCoords,2)))...
    * size(accumulator,1) / 2 );

% Rewrite the cell coordinates into linear indexing
indPoints = sub2ind(gatheredData.registered.registeredSize...
    ,allCellCoords(1,:),allCellCoords(2,:),allCellCoords(3,:));

% Find out how many points are on the same gridpoint
[uniquePoints,ai,~] = unique(indPoints,'stable');

% Values give number of points on that gridpoint
accumulator(uniquePoints) = 1;

if numel(uniquePoints) < numel(indPoints);
    indPoints(ai)=[];
    l = numel(indPoints);
    while l > 0
        [uniquePoints,ai,~] = unique(indPoints,'stable');
        accumulator(uniquePoints) = accumulator(uniquePoints)+1;
        indPoints(ai) = [];
        l = numel(indPoints);
    end
end

% -- Convolve over the points -- %

heatmapTopMIP  = smoothHeatmap(max(accumulator,[],3),0.05,'disk');
heatmapHeadMIP = smoothHeatmap(reshape(max(accumulator,[],2),[size(accumulator,1),size(accumulator,3)]),0.05,'disk');
heatmapSideMIP = smoothHeatmap(reshape(max(accumulator,[],1),[size(accumulator,2),size(accumulator,3)]),0.05,'disk');

heatmapTopSum  = smoothHeatmap(sum(accumulator,3),0.05,'disk');
heatmapHeadSum = smoothHeatmap(reshape(sum(accumulator,2),[size(accumulator,1),size(accumulator,3)]),0.05,'disk');
heatmapSideSum = smoothHeatmap(reshape(sum(accumulator,1),[size(accumulator,2),size(accumulator,3)]),0.05,'disk');

%% VISUALIZATION
f1 = figure('Name','Heatmaps MIP','units','normalized','outerposition',[0.25 0.25 0.65 0.65]);

% Set information box
mTextBox = uicontrol('style','text');
subplot(1,3,1), 
imagesc(heatmapTopMIP),
title('MIP from the top'),
axis square
set(gca,'xtick',[],'ytick',[])
subplot(1,3,2), 
imagesc(heatmapHeadMIP),
title('MIP from the head'),
axis square
set(gca,'xtick',[],'ytick',[])
subplot(1,3,3), 
imagesc(heatmapSideMIP),
title('MIP from the side'),
axis square
set(gca,'xtick',[],'ytick',[])
suptitle(['Number of processed dataset: ',num2str(numberOfResults),', Total number of cells: ', num2str(size(allCellCoords,2))]);

f2 = figure('Name','Heatmaps summation','units','normalized','outerposition',[0.25 0.25 0.65 0.65]);

% Set information box
mTextBox = uicontrol('style','text');
subplot(1,3,1), 
imagesc(heatmapTopSum),
title('Summation from the top'),
axis square
set(gca,'xtick',[],'ytick',[])
subplot(1,3,2), 
imagesc(heatmapHeadSum),
title('Summation from the head'),
axis square
set(gca,'xtick',[],'ytick',[])
subplot(1,3,3), 
imagesc(heatmapSideSum),
title('Summation from the side'),
axis square
set(gca,'xtick',[],'ytick',[])
suptitle(['Number of processed dataset: ',num2str(numberOfResults),', Total number of cells: ', num2str(size(allCellCoords,2))]);

%% SAVING

if ~exist([resultsPath '/heatmaps'],'dir')
    mkdir(resultsPath, 'heatmaps');
end
fig_filename = [resultsPath 'heatmaps/MIP_Heatmaps.bmp'];
% saving figure as .bmp
saveas(f1,fig_filename);

results_filename = [resultsPath, 'heatmaps/HeatmapAcculmulator.mat'];
        
% save heatmap
save(results_filename, 'accumulator');

disp('Heatmap saved in heatmaps directory.');
%% USER OUTPUT
disp('All results in folder processed!');