%% INITIALIZATION
clear; clc; close all;

percOfAll = 0.5;

% add path for parameter setup
addpath('./parameter_setup/');

% load necessary variables
p = initializeScript('heatmap');

% define paths to heatmaps to be compared
result_path = [p.resultsPath,'/'];
path_accepted = p.resultsPathAccepted;

%% GET FILES TO PROCESS

% Get filenames of MAT files in selected folder
fileNames = getMATfilenames(p.resultsPathAccepted);
fileNames(find(strcmp(fileNames,'ParameterProcessing.mat'))) = [];
fileNames(find(strcmp(fileNames,'ParameterHeatmap.mat'))) = [];
fileNames(find(strcmp(fileNames,'HeatmapAccumulator.mat'))) = [];

[stackNames1,stackNames2] = drawRandomNames(fileNames,percOfAll);

% Get number of experiments
numberOfResults1 = size(stackNames1,1);
numberOfResults2 = size(stackNames2,1);

% Check if any results have been found
if numberOfResults1 == 0
    disp('All results already processed or path to results folder wrong?');
    disp(resultsPathAccepted);
    return;
else
end

%% GET DATA SIZE FOR ACCUMULATOR OF FIRST PART 

% Load first data set
load([p.resultsPathAccepted,'/',stackNames1{1,1}]);

% Original data size (in mu)
% origSize = gatheredData.processed.originalSize;

%% COMPUTE ACCUMULATOR

% -- Compute all valid cell coordinates from the processed and registered data -- %
allCellCoords = getAllValidCellCoords(p.gridSize,stackNames1,numberOfResults1,p.tole,p.resultsPathAccepted);

% -- Compute the Accumulator from the cell coordinates -- %
accum1 = computeAccumulator(allCellCoords, p.gridSize);

%% GET DATA SIZE FOR ACCUMULATOR OF FIRST PART 

% Load first data set
load([p.resultsPathAccepted,'/',stackNames2{1,1}]);

% Original data size (in mu)
% origSize = gatheredData.processed.originalSize;

%% COMPUTE ACCUMULATOR

% -- Compute all valid cell coordinates from the processed and registered data -- %
allCellCoords = getAllValidCellCoords(p.gridSize,stackNames2,numberOfResults2,p.tole,p.resultsPathAccepted);

% -- Compute the Accumulator from the cell coordinates -- %
accum2 = computeAccumulator(allCellCoords, p.gridSize);



% TODO: REALIZE MORE EFFICIENTLY BY CONVOLUTION!!!
for factor = [1 2 4 8]
  
  accum1_rzd = zeros(size(accum1) / factor);
  accum2_rzd = accum1_rzd;
  
  starting_points = 1:factor:256;
  
  for y=1:size(accum1_rzd,1)-1
    for x=1:size(accum1_rzd,2)-1
      for z=1:size(accum1_rzd,3)-1
        
        accum1_rzd(y,x,z) = sum(sum(sum(accum1(...
          starting_points(y):(starting_points(y+1)-1),...
          starting_points(x):(starting_points(x+1)-1),...
          starting_points(z):(starting_points(z+1)-1)...
          ))));
        
        accum2_rzd(y,x,z) = sum(sum(sum(accum2(...
          starting_points(y):(starting_points(y+1)-1),...
          starting_points(x):(starting_points(x+1)-1),...
          starting_points(z):(starting_points(z+1)-1)...
          ))));
      end
    end
  end
 
  %%% EXPERIMENTAL
  cellradius = 7 / factor;
  accum1_rzd = convolveAccumulator(accum1_rzd,cellradius,2*cellradius+1);
  accum2_rzd = convolveAccumulator(accum2_rzd,cellradius,2*cellradius+1);
  
  % compute MIPs / SUMS
  sum1 = sum(accum1_rzd,3);
  sum2 = sum(accum2_rzd,3);
  sum1 = sum1 ./ sum(accum1_rzd(:));
  sum2 = sum2 ./ sum(accum2_rzd(:));
  
  mip1 = computeMIP(accum1_rzd);
  mip2 = computeMIP(accum2_rzd);
  mip1 = mip1 ./ sum(accum1_rzd(:));
  mip2 = mip2 ./ sum(accum2_rzd(:));
  
  
  % generate sum images (from top view)
  
  % generate relative, min-max scaling
  sum_min_max = min(max(sum1(:)), max(sum2(:)));
  
  figure('units','normalized','outerposition',[0 0 1 1]); 
  subplot(1,2,1);imagesc(sum1, [0 sum_min_max]); colorbar; axis image; title(['Stack of ',num2str(size(stackNames1,1)),' random files.']); colormap jet;
  subplot(1,2,2);imagesc(sum2, [0 sum_min_max]); colorbar; axis image; title(['Stack of ',num2str(size(stackNames2,1)),' random files.']); colormap jet;
  ha = axes('Position',[0 0 1 1],'Xlim',[0 1],'Ylim',[0 1],'Box','off','Visible','off','Units','normalized', 'clipping' , 'off');
  text(0.5, 1,'\bf Relative, min-max scaling of sums','HorizontalAlignment','center','VerticalAlignment', 'top')
  print([result_path 'HeatmapComparison_SUM_factor_' num2str(factor) '_rel_minmax'],'-dpng');
  
  % generate relative, max-max scaling
  sum_max_max = max(max(mip1(:)), max(mip2(:)));
  
  figure('units','normalized','outerposition',[0 0 1 1]); 
  subplot(1,2,1);imagesc(sum1, [0 sum_max_max]); colorbar; axis image; title(['Stack of ',num2str(size(stackNames1,1)),' random files.']); colormap jet;
  subplot(1,2,2);imagesc(sum2, [0 sum_max_max]); colorbar; axis image; title(['Stack of ',num2str(size(stackNames2,1)),' random files.']); colormap jet;
  ha = axes('Position',[0 0 1 1],'Xlim',[0 1],'Ylim',[0 1],'Box','off','Visible','off','Units','normalized', 'clipping' , 'off');
  text(0.5, 1,'\bf Relative, max-max scaling of sums','HorizontalAlignment','center','VerticalAlignment', 'top')
  print([result_path 'HeatmapComparison_SUM_factor_' num2str(factor) '_rel_maxmax'],'-dpng');
  
  
  % generate MIP images
  
  % generate relative, min-max scaling
  mip_min_max = min(max(mip1(:)), max(mip2(:)));
  
  figure('units','normalized','outerposition',[0 0 1 1]); 
  subplot(1,2,1);imagesc(mip1, [0 mip_min_max]); colorbar; axis image; title(['Stack of ',num2str(size(stackNames1,1)),' random files.']); colormap jet;
  subplot(1,2,2);imagesc(mip2, [0 mip_min_max]); colorbar; axis image; title(['Stack of ',num2str(size(stackNames2,1)),' random files.']); colormap jet;
  ha = axes('Position',[0 0 1 1],'Xlim',[0 1],'Ylim',[0 1],'Box','off','Visible','off','Units','normalized', 'clipping' , 'off');
  text(0.5, 1,'\bf Relative, min-max scaling','HorizontalAlignment','center','VerticalAlignment', 'top')
  print([result_path 'HeatmapComparison_MIP_factor_' num2str(factor) '_rel_minmax'],'-dpng');
  
  % generate relative, max-max scaling
  mip_max_max = max(max(mip1(:)), max(mip2(:)));
  
  figure('units','normalized','outerposition',[0 0 1 1]); 
  subplot(1,2,1);imagesc(mip1, [0 mip_max_max]); colorbar; axis image; title(['Stack of ',num2str(size(stackNames1,1)),' random files.']); colormap jet;
  subplot(1,2,2);imagesc(mip2, [0 mip_max_max]); colorbar; axis image; title(['Stack of ',num2str(size(stackNames2,1)),' random files.']); colormap jet;
  ha = axes('Position',[0 0 1 1],'Xlim',[0 1],'Ylim',[0 1],'Box','off','Visible','off','Units','normalized', 'clipping' , 'off');
  text(0.5, 1,'\bf Relative, max-max scaling','HorizontalAlignment','center','VerticalAlignment', 'top')
  print([result_path 'HeatmapComparison_MIP_factor_' num2str(factor) '_rel_maxmax'],'-dpng');
  
  close all;
end

