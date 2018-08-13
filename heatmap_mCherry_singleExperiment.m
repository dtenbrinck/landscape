%% INITIALIZATION
clear; clc; close all;

% define root directory
root_dir = pwd;

% add path for parameter setup
addpath([root_dir '/parameter_setup/']);

% load necessary variables
p = initializeScript('heatmap', root_dir);
p.handledChannel = 'mCherry';

% generate heatmaps for single experiment
heatmap_singleExperiment(p);
