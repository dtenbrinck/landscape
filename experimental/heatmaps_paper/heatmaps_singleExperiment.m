%% INITIALIZATION
clear; clc; close all;

% define root directory
root_dir = '../../';

% add path for parameter setup
addpath([root_dir '/parameter_setup/']);

% load necessary variables
p = initializeScript('heatmap', root_dir);

% generate heatmaps for single experiment
generateHeatmapsFromAccumulator(p);
