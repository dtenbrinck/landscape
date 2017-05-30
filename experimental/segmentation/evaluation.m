%% INITIALIZATION
clear; clc; close all;

% define root directory
root_dir = fileparts(fileparts(pwd));

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
f = figure('units','normalized','outerposition',[0 0 1 1]); 
for result = 1:numberOfResults
    
    % load result data
    load([p.resultsPath,'/',fileNames{result,1}])
    
    % visualize results
%     visualizeResults(experimentData, processedData, registeredData);
    visualizeResults_evaluation(f,gatheredData);
    
    % display user output
    fprintf(gatheredData.filename);
    
    % ask user to decide what to do with the results
    choice = questdlg(['What do you want to do with the results of dataset ' gatheredData.filename '?'], ...
        'Decision on results', ...
        'Accept','Improve','Reject','Accept');
    
    % Handle response
    switch choice
        case 'Accept'
            fprintf('\t -> Accepted!\n');
            movefile([p.resultsPath '/' fileNames{result,1}], [p.resultsPath '/accepted/' fileNames{result,1}]);
        case 'Improve'
            modifiedData = gui_manualSegmentation(gatheredData);
            save([p.resultsPath,'/',fileNames{result,1}], 'modifiedData');
            fprintf('\t -> Improved!\n');
            result = result - 1; % adjust for another try
        case 'Reject'
            fprintf('\t -> Rejected!\n');
            movefile([p.resultsPath '/' fileNames{result,1}], [p.resultsPath '/rejected/' fileNames{result,1}]);
        otherwise
            fprintf('\t -> Dialog closed!\n');
    end
    
end

%% USER OUTPUT
disp('All results in folder processed!');
close all;
clear all;