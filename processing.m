%% INITIALIZATION
clear; clc; close all;

% define root directory
root_dir = pwd;

% add all required scripts
addpath([root_dir '/auxiliary/']);
addpath([root_dir '/fitting/']);
addpath([root_dir '/gui/']);
addpath([root_dir '/heatmaps/']);
addpath([root_dir '/io/']);
addpath([root_dir '/parameter_setup/']);
addpath([root_dir '/preprocessing/']);
addpath([root_dir '/registration/']);
addpath(genpath([root_dir '/segmentation/']));
addpath([root_dir '/visualization/']);

% load necessary variables. Settings can be adjusted here
p = ParameterTotal();

% Set default search path for data
dataPath = [root_dir '/data'];

% Set default search path for results
resultsPath = [root_dir '/results'];

% Get the paths for data and results
p.dataPath = uigetdir(dataPath,'Please select a folder with the data');
btn = questdlg('Do you want to use an existing results folder or create a new one?','New folder?','Create new','Use existing','Create new');
  
if strcmp(btn,'Create new')
    p.resultsPath = uigetdir(resultsPath,'Please select a directory for the new folder');
    answ = inputdlg('Please enter a name for the new folder');
    p.resultsPath = [p.resultsPath,'/',answ{1}];
    mkdir(p.resultsPath);
else
    p.resultsPath = uigetdir(resultsPath,'Please select a folder for the results');
end

% Call intern processing function
processing_gui(p)