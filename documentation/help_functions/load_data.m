function [ all_data ] = load_data( dataPathName )
%LOAD_DATA

% get filenames of STK files in selected folder
fileNames = getSTKfilenames(dataPathName);

% extract only valid experiments with three data sets
experimentSets = checkExperimentChannels(fileNames);

% load data for each experiment
all_data = loadExperimentData(experimentSets, dataPathName);

end

