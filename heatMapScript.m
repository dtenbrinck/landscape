%% INITIALIZATION
clear; clc; close all;

%% PARAMETER 
tole = 0.1;
%% SET PATH
resultsPath = './results/tilting_adjustments_first_priority/accepted'; % DONT APPEND '/' TO DIRECTORY NAME!!!

%% GET FILES TO PROCESS

% get filenames of MAT files in selected folder
fileNames = getMATfilenames(resultsPath);

% get number of experiments
numberOfResults = size(fileNames,1);

% check if any results have been found
if numberOfResults == 0
    disp('All results already processed or path to results folder wrong?');
    disp(resultsPath);
    return;
else
    disp([ num2str(numberOfResults) ' results found in folder for generating heat map.']);
end

%% GET DATA SIZE FOR ACCUMULATOR

% load first data set
load(fileNames{1,1});

% initialize accumulator
accumulator = zeros(size(registeredData.GFP));

%% MAIN ACCUMULATOR LOOP
for result = 1:numberOfResults
    
    % load result data
    load(fileNames{result,1})
    
    % Ignore all that are out of the domain
    registeredData.cellCoordinates(:,sum(abs(registeredData.cellCoordinates)>1)>=1) = [];
    
    % Compute norm of each column 
    normOfCoordinates = sqrt(sum(registeredData.cellCoordinates.^2,1));
    
    % Ignore all coordinates outside the sphere with a tolerance tole
    registeredData.cellCoordinates(:,normOfCoordinates > 1+tole) = [];
    
    % get rounded cell centroid coordinates 
    cellCoordinates = round(...
        (registeredData.cellCoordinates + repmat([1;1;1], 1, size(registeredData.cellCoordinates,2)))...
        * size(accumulator,1) / 2 );
    
    % indicator matrix
    indicator = zeros(size(accumulator));
    indicator(sub2ind(size(accumulator),cellCoordinates(1,:),cellCoordinates(2,:),cellCoordinates(3,:))) = 1;
    
    accumulator = accumulator + indicator;
end

%% VISUALIZATION
f1 = figure('Name','Heatmaps','units','normalized','outerposition',[0.25 0.25 0.5 0.5]);
subplot(1,3,1), 
imagesc(max(accumulator,[],3)),
title('MIP from the top'),
axis square
subplot(1,3,2), 
imagesc(reshape(max(accumulator,[],2),[size(accumulator,1),size(accumulator,3)])),
title('MIP from the head'),
axis square
subplot(1,3,3), 
imagesc(reshape(max(accumulator,[],1),[size(accumulator,2),size(accumulator,3)])),
title('MIP from the side'),
axis square

%% SAVING

fig_filename = [resultsPath '/MIP_Heatmaps.bmp'];
% saving figure as .bmp
saveas(f1,fig_filename);

results_filename = [resultsPath '/HeatmapAcculmulator.mat'];
        
% save heatmap
save(results_filename, 'accumulator');

%% USER OUTPUT
disp('All results in folder processed!');´