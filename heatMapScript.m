%% INITIALIZATION
clear; clc; close all;

%% PARAMETER 
tole = 0.1;
% Size of the cells
sizeCells = 20; %um
% Size of the Pixel
sizeOfPixel = 0.29; %um
sizeCellsPixel = round(sizeCells/sizeOfPixel);
radius = 5;
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

% Initialize accumulator
accumulator = zeros(gatheredData.registered.registeredSize);

% Original data size (in mu)
origSize = gatheredData.processed.originalSize;
% Accumulator size
sizeAcc = size(accumulator);
gridSize = sizeAcc(1);



%% MAIN CODE

% -- Compute all valid cell coordinates from the processed and registered data -- %
allCellCoords = getAllValidCellCoords(sizeAcc(1),fileNames,numberOfResults,tole);

% -- Compute the Accumulator from the cell coordinates -- %
accumulator = compAcc(allCellCoords, gridSize);

% -- Convolve over the points -- %
convAcc = computeConvAcc(accumulator,radius,2*radius+1);

% -- Compute heatmap MIPs -- %
heatmapTopMIP  = (max(convAcc,[],3));
heatmapHeadMIP = (reshape(max(convAcc,[],2),[size(accumulator,1),size(accumulator,3)]));
heatmapSideMIP = (reshape(max(convAcc,[],1),[size(accumulator,2),size(accumulator,3)]));

% -- Compute heatmap Sums -- %
heatmapTopSum  = (sum(convAcc,3));
heatmapHeadSum = (reshape(sum(convAcc,2),[size(accumulator,1),size(accumulator,3)]));
heatmapSideSum = (reshape(sum(convAcc,1),[size(accumulator,2),size(accumulator,3)]));

% -- Scale them into the same scale -- %

maxScaleMIPregistered ...
    = max([max(heatmapTopMIP(:)),max(heatmapHeadMIP(:)),max(heatmapSideMIP(:))]);
maxScaleSumregistered ...
    = max([max(heatmapTopSum(:)),max(heatmapHeadSum(:)),max(heatmapSideSum(:))]);
climsMIP = [0,maxScaleMIPregistered];
climsSum = [0,maxScaleSumregistered];

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