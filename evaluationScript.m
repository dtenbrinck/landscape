%% INITIALIZATION
clear; clc; close all;

%% SET PATH
resultsPath = './results/tilting_adjustments_first_priority'; % DONT APPEND '/' TO DIRECTORY NAME!!!

%% GET FILES TO PROCESS

% check results directory
checkDirectory(resultsPath);

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
    disp([ num2str(numberOfResults) ' results found in folder for processing.']);
end

%% MAIN EVALUATION LOOP
for result = 1:numberOfResults
    
    % load result data
    load(fileNames{result,1})
    
    % visualize results
    visualizeResults(experimentData, processedData, registeredData);
    
    % display user output
    fprintf(experimentData.filename);
    
    % ask user to decide what to do with the results
    choice = questdlg(['What do you want to do with the results of dataset ' experimentData.filename '?'], ...
        'Decision on results', ...
        'Accept','Reject','Accept');
    
    % Handle response
    switch choice
        case 'Accept'
            fprintf('\t -> Accepted!\n');
            movefile([resultsPath '/' fileNames{result,1}], [resultsPath '/accepted/' fileNames{result,1}]);
        case 'Reject'
            fprintf('\t -> Rejected!\n');
            movefile([resultsPath '/' fileNames{result,1}], [resultsPath '/rejected/' fileNames{result,1}]);
        otherwise
            fprintf('\t -> Dialog closed!\n');
    end
    
    close all;
end

%% USER OUTPUT
disp('All results in folder processed!');
close all;