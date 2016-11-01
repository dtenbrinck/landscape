%% INITIALIZATION
clear; clc; close all;

%% PARAMETER 
tole = 0.1;
% Size of the cells
sizeCells = 20; %um
% Size of the Pixel
sizeOfPixel = 0.29; %um
sizeCellsPixel = round(sizeCells/sizeOfPixel);
option.cellradius = 5;
heatmaptypes = {'MIP','SUM'};

% Heatmap vis options
option.slider = 1;  %in progress
option.heatmaps.saveHMmat = 1;
option.heatmaps.saveAccumulator = 1;
option.heatmaps.types = {'MIP','SUM'};
option.heatmaps.process = 1;
option.heatmaps.save = 1;
option.heatmaps.saveas = {'png','bmp'};
option.heatmaps.disp = 1;
option.heatmaps.scaled = 'both'; % 'true','false','both'
%% SET PATH
resultsPath = './results/Heatmap'; % DONT APPEND '/' TO DIRECTORY NAME!!!
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

% Original data size (in mu)
origSize = gatheredData.processed.originalSize;
% grid size size
gridSize = gatheredData.registered.registeredSize;



%% COMPUTE ACCUMULATOR

% -- Compute all valid cell coordinates from the processed and registered data -- %
allCellCoords = getAllValidCellCoords(gridSize,fileNames,numberOfResults,tole);

% -- Compute the Accumulator from the cell coordinates -- %
accumulator = compAcc(allCellCoords, gridSize);


%% HANDLE HEATMAPS
p.resultsPath = resultsPath;
handleHeatmaps(accumulator,size(allCellCoords,2),numberOfResults,p,option);


%% COMPUTE HEATMAP

%% VISUALIZATION



% -- scaled -- %
mycolormap = jet(256);
f1 = figure('Name','Heatmaps MIP (scaled)','units','normalized','outerposition',[0.25 0.25 0.65 0.65]);
colormap(mycolormap);

% Set information box
subplot(1,3,1), 
imagesc(heatmapTopMIP,climsMIP),
title('MIP from the top'),
axis square
xlabel(gca,'Head \leftarrow \rightarrow Tail','FontSize',13);
ylabel(gca,'Left \leftarrow \rightarrow Right','FontSize',13);
set(gca,'xtick',[],'ytick',[])
subplot(1,3,2), 
imagesc(heatmapHeadMIP',climsMIP),
title('MIP from the head'),
axis square
ylabel(gca,'Bottom \leftarrow \rightarrow Top','FontSize',13);
xlabel(gca,'Left \leftarrow \rightarrow Right','FontSize',13);
set(gca,'xtick',[],'ytick',[])
subplot(1,3,3), 
imagesc(heatmapSideMIP',climsMIP),
title('MIP from the side'),
axis square
ylabel(gca,'Bottom \leftarrow \rightarrow Top','FontSize',13);
xlabel(gca,'Tail \leftarrow \rightarrow Head','FontSize',13);
set(gca,'xtick',[],'ytick',[])
pca = get(gca,'position');
colorbar 
set(gca,'position',pca);
suptitle(['Number of processed dataset: ',num2str(numberOfResults),', Total number of cells: ', num2str(size(allCellCoords,2))]);

f2 = figure('Name','Heatmaps summation (scaled)','units','normalized','outerposition',[0.25 0.25 0.65 0.65]);
colormap(mycolormap);
% Set information box
subplot(1,3,1), 
imagesc(heatmapTopSum,climsSum),
title('Summation from the top'),
axis square
xlabel(gca,'Head \leftarrow \rightarrow Tail','FontSize',13);
ylabel(gca,'Left \leftarrow \rightarrow Right','FontSize',13);
set(gca,'xtick',[],'ytick',[])
subplot(1,3,2), 
imagesc(heatmapHeadSum',climsSum),
title('Summation from the head'),
axis square
ylabel(gca,'Bottom \leftarrow \rightarrow Top','FontSize',13);
xlabel(gca,'Left \leftarrow \rightarrow Right','FontSize',13);
set(gca,'xtick',[],'ytick',[])
subplot(1,3,3), 
imagesc(heatmapSideSum',climsSum),
title('Summation from the side'),
axis square
ylabel(gca,'Bottom \leftarrow \rightarrow Top','FontSize',13);
xlabel(gca,'Tail \leftarrow \rightarrow Head','FontSize',13);
set(gca,'xtick',[],'ytick',[])
pca = get(gca,'position');
colorbar 
set(gca,'position',pca);
suptitle(['Number of processed dataset: ',num2str(numberOfResults),', Total number of cells: ', num2str(size(allCellCoords,2))]);


% -- unscaled -- %
mycolormap = jet(256);
f3 = figure('Name','Heatmaps MIP (unscaled)','units','normalized','outerposition',[0.25 0.25 0.65 0.65]);
colormap(mycolormap);

% Set information box
subplot(1,3,1), 
imagesc(heatmapTopMIP),
title('MIP from the top'),
axis square
xlabel(gca,'Head \leftarrow \rightarrow Tail','FontSize',13);
ylabel(gca,'Left \leftarrow \rightarrow Right','FontSize',13);
set(gca,'xtick',[],'ytick',[])
pca = get(gca,'position');
colorbar 
set(gca,'position',pca);
subplot(1,3,2), 
imagesc(heatmapHeadMIP'),
title('MIP from the head'),
axis square
ylabel(gca,'Bottom \leftarrow \rightarrow Top','FontSize',13);
xlabel(gca,'Left \leftarrow \rightarrow Right','FontSize',13);
set(gca,'xtick',[],'ytick',[])
pca = get(gca,'position');
colorbar 
set(gca,'position',pca);
subplot(1,3,3), 
imagesc(heatmapSideMIP'),
title('MIP from the side'),
axis square
ylabel(gca,'Bottom \leftarrow \rightarrow Top','FontSize',13);
xlabel(gca,'Tail \leftarrow \rightarrow Head','FontSize',13);
set(gca,'xtick',[],'ytick',[])
pca = get(gca,'position');
colorbar 
set(gca,'position',pca);
suptitle(['Number of processed dataset: ',num2str(numberOfResults),', Total number of cells: ', num2str(size(allCellCoords,2))]);

f4 = figure('Name','Heatmaps summation (unscaled)','units','normalized','outerposition',[0.25 0.25 0.65 0.65]);
colormap(mycolormap);
% Set information box
subplot(1,3,1), 
imagesc(heatmapTopSum),
title('Summation from the top'),
axis square
xlabel(gca,'Head \leftarrow \rightarrow Tail','FontSize',13);
ylabel(gca,'Left \leftarrow \rightarrow Right','FontSize',13);
set(gca,'xtick',[],'ytick',[])
pca = get(gca,'position');
colorbar 
set(gca,'position',pca);
subplot(1,3,2), 
imagesc(heatmapHeadSum'),
title('Summation from the head'),
axis square
ylabel(gca,'Bottom \leftarrow \rightarrow Top','FontSize',13);
xlabel(gca,'Left \leftarrow \rightarrow Right','FontSize',13);
set(gca,'xtick',[],'ytick',[])
pca = get(gca,'position');
colorbar 
set(gca,'position',pca);
subplot(1,3,3), 
imagesc(heatmapSideSum'),
title('Summation from the side'),
axis square
ylabel(gca,'Bottom \leftarrow \rightarrow Top','FontSize',13);
xlabel(gca,'Tail \leftarrow \rightarrow Head','FontSize',13);
set(gca,'xtick',[],'ytick',[])
pca = get(gca,'position');
colorbar 
set(gca,'position',pca);
suptitle(['Number of processed dataset: ',num2str(numberOfResults),', Total number of cells: ', num2str(size(allCellCoords,2))]);


%% SAVING

if ~exist([resultsPath '/heatmaps'],'dir')
    mkdir(resultsPath, 'heatmaps');
end
fig_filename = [resultsPath '/heatmaps/MIP_Heatmaps.png'];
% saving figure as .png
saveas(f1,fig_filename);
fig_filename = [resultsPath '/heatmaps/SUM_Heatmaps.png'];
% saving figure as .png
saveas(f2,fig_filename);
fig_filename = [resultsPath '/heatmaps/MIP_Heatmaps(unscaled).png'];
% saving figure as .png
saveas(f3,fig_filename);
fig_filename = [resultsPath '/heatmaps/SUM_Heatmaps(unscaled).png'];
% saving figure as .png
saveas(f4,fig_filename);

results_filename = [resultsPath, '/heatmaps/HeatmapAcculmulator.mat'];
        
% save heatmap
save(results_filename, 'accumulator');

disp('Heatmap saved in heatmaps directory.');
%% USER OUTPUT
disp('All results in folder processed!');