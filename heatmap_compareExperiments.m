%% INITIALIZATION
clear; clc; close all;

% add path for parameter setup
addpath('./parameter_setup/');

% load necessary variables
p = initializeScript('heatmapComparison');


%% GET ACCUMULATOR FILES TO PROCESS

% define paths to heatmaps to be compared
path1 = p.p1.resultsPath;
path2 = p.p2.resultsPath;

% define result path
result_path = [p.p3.resultsPath '/'];
%result_path = './results/Heatmap_Comparison/';

% load accumulators
load([path1 '/Accumulator.mat'],'accumulator');
accum1 = accumulator;

load([path2 '/Accumulator.mat'],'accumulator');
accum2 = accumulator;

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
  subplot(1,2,1);imagesc(sum1, [0 sum_min_max]); colorbar; axis image; title(p.p1.resultsPath); colormap jet;
  subplot(1,2,2);imagesc(sum2, [0 sum_min_max]); colorbar; axis image; title(p.p2.resultsPath); colormap jet;
  ha = axes('Position',[0 0 1 1],'Xlim',[0 1],'Ylim',[0 1],'Box','off','Visible','off','Units','normalized', 'clipping' , 'off');
  text(0.5, 1,'\bf Relative, min-max scaling of sums','HorizontalAlignment','center','VerticalAlignment', 'top')
  print([result_path 'HeatmapComparison_SUM_factor_' num2str(factor) '_rel_minmax'],'-dpng');
  
  % generate relative, max-max scaling
  sum_max_max = max(max(mip1(:)), max(mip2(:)));
  
  figure('units','normalized','outerposition',[0 0 1 1]); 
  subplot(1,2,1);imagesc(sum1, [0 sum_max_max]); colorbar; axis image; title(p.p1.resultsPath); colormap jet;
  subplot(1,2,2);imagesc(sum2, [0 sum_max_max]); colorbar; axis image; title(p.p2.resultsPath); colormap jet;
  ha = axes('Position',[0 0 1 1],'Xlim',[0 1],'Ylim',[0 1],'Box','off','Visible','off','Units','normalized', 'clipping' , 'off');
  text(0.5, 1,'\bf Relative, max-max scaling of sums','HorizontalAlignment','center','VerticalAlignment', 'top')
  print([result_path 'HeatmapComparison_SUM_factor_' num2str(factor) '_rel_maxmax'],'-dpng');
  
  
  % generate MIP images
  
  % generate relative, min-max scaling
  mip_min_max = min(max(mip1(:)), max(mip2(:)));
  
  figure('units','normalized','outerposition',[0 0 1 1]); 
  subplot(1,2,1);imagesc(mip1, [0 mip_min_max]); colorbar; axis image; title(p.p1.resultsPath); colormap jet;
  subplot(1,2,2);imagesc(mip2, [0 mip_min_max]); colorbar; axis image; title(p.p2.resultsPath); colormap jet;
  ha = axes('Position',[0 0 1 1],'Xlim',[0 1],'Ylim',[0 1],'Box','off','Visible','off','Units','normalized', 'clipping' , 'off');
  text(0.5, 1,'\bf Relative, min-max scaling','HorizontalAlignment','center','VerticalAlignment', 'top')
  print([result_path 'HeatmapComparison_MIP_factor_' num2str(factor) '_rel_minmax'],'-dpng');
  
  % generate relative, max-max scaling
  mip_max_max = max(max(mip1(:)), max(mip2(:)));
  
  figure('units','normalized','outerposition',[0 0 1 1]); 
  subplot(1,2,1);imagesc(mip1, [0 mip_max_max]); colorbar; axis image; title(p.p1.resultsPath); colormap jet;
  subplot(1,2,2);imagesc(mip2, [0 mip_max_max]); colorbar; axis image; title(p.p2.resultsPath); colormap jet;
  ha = axes('Position',[0 0 1 1],'Xlim',[0 1],'Ylim',[0 1],'Box','off','Visible','off','Units','normalized', 'clipping' , 'off');
  text(0.5, 1,'\bf Relative, max-max scaling','HorizontalAlignment','center','VerticalAlignment', 'top')
  print([result_path 'HeatmapComparison_MIP_factor_' num2str(factor) '_rel_maxmax'],'-dpng');
  
  close all;
end

