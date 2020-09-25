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

% Set default search path for results
resultsPath = [root_dir '/results'];

% Get the results location from the user
p.resultsPath = uigetdir(resultsPath,'Please select a results folder to generate heatmap');
p.resultsPathAccepted = [p.resultsPath,'/accepted'];
if ~exist([p.resultsPath,'/heatmaps'],'dir')
    mkdir([p.resultsPath,'/heatmaps']);
end

% generate heatmaps for single experiment
generateHeatmaps(p);
