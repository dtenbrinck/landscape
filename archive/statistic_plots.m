clc; clear; close all;
addpath('./auxiliary/');

tmp = load('./results/allCellCoords2.mat');
coordinates = tmp.allCellCoords';
coordinates = 2 * ((coordinates - min(coordinates(:))) ./ (max(coordinates(:)) - min(coordinates(:))) - 0.5);
coordinates(:,3) = -coordinates(:,3);


sampling = 64;


minY = min(coordinates(:,1));
minX = min(coordinates(:,2));
minZ = min(coordinates(:,3));


sampled_data = round( (coordinates - repmat([minY, minX, minZ],[size(coordinates,1), 1])) * (sampling-1) / 2) + 1;


accumulator = zeros(sampling,sampling,sampling);

for i=1:size(sampled_data,1)
  accumulator(sub2ind([sampling sampling sampling],sampled_data(i,1),sampled_data(i,2),sampled_data(i,3))) =...
    accumulator(sub2ind([sampling sampling sampling],sampled_data(i,1),sampled_data(i,2),sampled_data(i,3))) + 1;
end

% turn accumulator for easier interpretation
for i=1:size(accumulator,3)
  accumulator(:,:,i) = rot90(accumulator(:,:,i),1);
end

reference = imread('results/GFP_heatmap.png');

% sum from the top
top_sum = sum(accumulator,3);

% left -> right plot
top_LR_sum = sum(top_sum,1);
figure; 
ax1 = axes('Position',[0 0 1 1],'Visible','off');
text(0.05,0.04,'Head','FontSize',26, 'FontWeight', 'bold');
text(0.9,0.04,'Tail','FontSize',26, 'FontWeight', 'bold');
ax2 = axes('Position',[0.05 0.1 0.92 0.85]);
plot(ax2,top_LR_sum,'LineWidth',2); xlim([1 64]);

figure; imagesc(top_sum);
hold on; hline(32,'r-',''); hold off
figure; imagesc(reference);
hold on; hline(round(size(reference,1)/2),'r-',''); hold off


% back -> front plot
top_BF_sum = sum(top_sum,2);
figure; 
ax1 = axes('Position',[0 0 1 1],'Visible','off');
text(0.05,0.04,'Back','FontSize',26, 'FontWeight', 'bold');
text(0.9,0.04,'Front','FontSize',26, 'FontWeight', 'bold');
ax2 = axes('Position',[0.05 0.1 0.92 0.85]);
plot(ax2,top_BF_sum,'LineWidth',2); xlim([1 64]);

figure; imagesc(top_sum);
hold on; vline(32,'r-',''); hold off
figure; imagesc(reference);
hold on; vline(round(size(reference,2)/2),'r-',''); hold off

%%%%

% sum from the back
back_sum = rot90(reshape(sum(accumulator,2),[sampling, sampling]),1);

% bottom -> top plot
back_BT_sum = sum(back_sum,2);
figure; 
ax1 = axes('Position',[0 0 1 1],'Visible','off');
text(0.05,0.04,'Top','FontSize',26, 'FontWeight', 'bold');
text(0.9,0.04,'Bottom','FontSize',26, 'FontWeight', 'bold');
ax2 = axes('Position',[0.05 0.1 0.92 0.85]);
plot(ax2,back_BT_sum,'LineWidth',2); xlim([1 64]);

figure; imagesc(back_sum);
hold on; vline(32,'r-',''); hold off
