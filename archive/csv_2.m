%% INITIALIZATION
%clear; clc; close all;

% define root directory
root_dir = pwd;

% add path for parameter setup
addpath([root_dir '/parameter_setup/']);

% load necessary variables
p = initializeScript('evaluate', root_dir);


%% GET FILES TO PROCESS

% check results directory
checkDirectory(p.resultsPath);

% get filenames of STK files in selected folder
fileNames = getMATfilenames(p.resultsPath);
fileNames(find(strcmp(fileNames,'ParameterProcessing.mat'))) = [];
fileNames(find(strcmp(fileNames,'ParameterHeatmap.mat'))) = [];
% get number of experiments
numberOfResults = size(fileNames,1);

% check if any results have been found
if numberOfResults == 0
    disp('All results already processed or path to results folder wrong?');
    disp(p.resultsPath);
    return;
else
    disp([ num2str(numberOfResults) ' results found in folder for processing.']);
end

%% MAIN EVALUATION LOOP
result = 0;
summe_processed = [];
summe_registered = [];
label = [];

while result < numberOfResults
    
    result = result + 1;
    % load result data
    load([p.resultsPath,'/',fileNames{result,1}])
    
    % visualize results
%     visualizeResults(experimentData, processedData, registeredData);
    
    % display user output
    disp(gatheredData.filename);
    summe_processed = [summe_processed; sum(sum(sum(gatheredData.processed.landmark)))];
    summe_registered = [summe_registered; sum(sum(sum(gatheredData.registered.landmark)))];
    label = [label; -1];
end

%% USER OUTPUT
if exist('aborted','var')
  disp('Evaluation script terminated by user.');
else
  disp('All results in folder processed!');
  csvTable = table(summe_processed, summe_registered, label);
  writetable(csvTable, [p.resultsPath '/rejectedSums.csv'])
end
%close all;