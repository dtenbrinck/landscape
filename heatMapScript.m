%% INITIALIZATION
clear; clc; close all;

%% SET PATH
resultsPath = './results/tilting_adjustments_first_priority/accepted'; % DONT APPEND '/' TO DIRECTORY NAME!!!

%% GET FILES TO PROCESS

% get filenames of STK files in selected folder
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

%% MAIN EVALUATION LOOP
for result = 1:numberOfResults
    
    % load result data
    load(fileNames{result,1})
    
    % get rounded cell centroid coordinates 
    cellCoordinates = round((registeredData.cellCoordinates + repmat([1;1;1], 1, size(registeredData.cellCoordinates,2))) * size(accumulator,1) );
    
    % indicator matrix
    indicator = zeros(size(accumulator));
    indicator(sub2ind(size(accumulator),cellCoordinates(1,:),cellCoordinates(2,:),cellCoordinates(3,:))) = 1;
    
    accumulator = accumulator + indicator;
end

%% USER OUTPUT
disp('All results in folder processed!');
close all;