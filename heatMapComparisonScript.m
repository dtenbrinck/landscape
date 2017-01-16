%% INITIALIZATION
clear; clc; close all;

% add current folder and subfolders to path
addpath(genpath(pwd));

% define paths to heatmaps to be compared
path1 = './results/Heatmap_Comparison/Heatmap/Accumulator.mat';
path2 = './results/Heatmap_Comparison/Spadetail/Accumulator.mat';

% define result path
result_path = './results/Heatmap_Comparison/';

% load accumulators
load(path1,'accumulator');
accum1 = accumulator;

load(path2,'accumulator');
accum2 = accumulator;


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
  
  % compute MIPs
  mip1 = sum(accum1_rzd,3);%computeMIP(accum1_rzd);
  mip2 = sum(accum2_rzd,3);%computeMIP(accum2_rzd);
  
  % generate relative, independent scaling
  figure('units','normalized','outerposition',[0 0 1 1]);
  subplot(1,2,1);imagesc(mip1); colorbar; axis image; title('Heatmap folder');
  subplot(1,2,2);imagesc(mip2); colorbar; axis image; title('Spadetail folder');
  ha = axes('Position',[0 0 1 1],'Xlim',[0 1],'Ylim',[0 1],'Box','off','Visible','off','Units','normalized', 'clipping' , 'off');
  text(0.5, 1,'\bf Absolute, independent scaling','HorizontalAlignment','center','VerticalAlignment', 'top');
  print([result_path 'HeatmapComparison_factor_' num2str(factor) '_abs_indep'],'-dpng');
  
  % generate relative, independent scaling
  figure('units','normalized','outerposition',[0 0 1 1]);  
  subplot(1,2,1);imagesc(mip1 ./ sum(accum1_rzd(:))); colorbar; axis image; title('Heatmap folder');
  subplot(1,2,2);imagesc(mip2 ./ sum(accum2_rzd(:))); colorbar; axis image; title('Spadetail folder');
  ha = axes('Position',[0 0 1 1],'Xlim',[0 1],'Ylim',[0 1],'Box','off','Visible','off','Units','normalized', 'clipping' , 'off');
  text(0.5, 1,'\bf Relative, independent scaling','HorizontalAlignment','center','VerticalAlignment', 'top')
  print([result_path 'HeatmapComparison_factor_' num2str(factor) '_rel_indep'],'-dpng');
  
  % generate Absolute, min-max scaling
  min_max = min(max(mip1(:)), max(mip2(:)));
  
  figure('units','normalized','outerposition',[0 0 1 1]); 
  subplot(1,2,1);imagesc(mip1, [0 min_max]); colorbar; axis image; title('Heatmap folder');
  subplot(1,2,2);imagesc(mip2, [0 min_max]); colorbar; axis image; title('Spadetail folder');
  ha = axes('Position',[0 0 1 1],'Xlim',[0 1],'Ylim',[0 1],'Box','off','Visible','off','Units','normalized', 'clipping' , 'off');
  text(0.5, 1,'\bf Absolute, min-max scaling','HorizontalAlignment','center','VerticalAlignment', 'top')
  print([result_path 'HeatmapComparison_factor_' num2str(factor) '_abs_minmax'],'-dpng');
  
  % generate Absolute, max-max scaling
  max_max = max(max(mip1(:)), max(mip2(:)));
  
  figure('units','normalized','outerposition',[0 0 1 1]); 
  subplot(1,2,1);imagesc(mip1, [0 max_max]); colorbar; axis image; title('Heatmap folder');
  subplot(1,2,2);imagesc(mip2, [0 max_max]); colorbar; axis image; title('Spadetail folder');
  ha = axes('Position',[0 0 1 1],'Xlim',[0 1],'Ylim',[0 1],'Box','off','Visible','off','Units','normalized', 'clipping' , 'off');
  text(0.5, 1,'\bf Absolute, max-max scaling','HorizontalAlignment','center','VerticalAlignment', 'top')
  print([result_path 'HeatmapComparison_factor_' num2str(factor) '_abs_maxmax'],'-dpng');
  
  close all;
end

