function evaluation_gui(p)

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
h = figure('units','normalized','outerposition',[0 0 1 1]); 
result = 0;
while result < numberOfResults
    
    result = result + 1;
    % load result data
    load([p.resultsPath,'/',fileNames{result,1}])
    
    % visualize results
%     visualizeResults(experimentData, processedData, registeredData);
    visualizeResults_evaluation(h,gatheredData);
    
    % display user output
    fprintf(gatheredData.filename);
    
    % ask user to decide what to do with the results
    choice = questdlg(['What do you want to do with the results of dataset ' gatheredData.filename '?'], ...
        'Decision on results', ...
        'Accept','Improve', 'Reject','Accept');
    
    % Handle response
    switch choice
        case 'Accept'
            fprintf('\t -> Accepted!\n');
            movefile([p.resultsPath '/' fileNames{result,1}], [p.resultsPath '/accepted/' fileNames{result,1}]);
        case 'Improve'
            
            % ask user what he wants to improve
             choice = questdlg(['Which segmentation would you like to improve for ' gatheredData.filename '?'], ...
        'Choose one option', ...
        'Landmark','Cells','Cells');
            
            if strcmp(choice, 'Cells')
                modifiedData = gui_manualSegmentation(gatheredData,p,'cells');
            elseif strcmp(choice, 'Landmark')
                modifiedData = gui_manualSegmentation(gatheredData,p,'tissue');
            else
                error('This should never happen!');
            end
            
            if isempty(modifiedData)
              fprintf('\t -> Improvement aborted!\n');
              result = result - 1; % adjust for another try
              continue;
            end
            modifiedData.experiment.filename = modifiedData.filename;
            saveResults(modifiedData.experiment, modifiedData.processed, modifiedData.registered,...
                        modifiedData.processed.ellipsoid, modifiedData.registered.transformation_normalization, modifiedData.registered.transformation_rotation,...
                        [p.resultsPath,'/',fileNames{result,1}] );
            result = result - 1; % adjust for another try
            fprintf('\t -> Improved!\n');
        case 'Reject'
            fprintf('\t -> Rejected!\n');
            movefile([p.resultsPath '/' fileNames{result,1}], [p.resultsPath '/rejected/' fileNames{result,1}]);
      otherwise
            fprintf('\t -> Evaluation aborted!\n');
            aborted = true;
            break;
    end
    
end

%% USER OUTPUT
if exist('aborted','var')
  disp('Evaluation script terminated by user.');
else
  disp('All results in folder processed!');
end
%pause(1);
close 2;

end