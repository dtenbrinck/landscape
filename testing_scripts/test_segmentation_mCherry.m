% clean up
clc; clear; close all;

% add needed subfolders
addpath(genpath('../'));

% check if data has been loaded already
if ~exist('all_data.mat','file')
  
  % define data path
  dataPathName = '../data/tilting_adjustments_first_priority';
  
  % get filenames of STK files in selected folder
  fileNames = getSTKfilenames(dataPathName);
  
  % extract only valid experiments with three data sets
  experimentSets = checkExperimentChannels(fileNames);
  
  % load data for each experiment
  all_data = loadExperimentData(experimentSets, dataPathName);
  
  % save data
  save('all_data.mat', 'all_data');
  
else
  
  % load data from mat file
  file_content = load('all_data.mat');
  all_data = file_content.all_data;
  
end

% perform background removal using morphological filters
%data = all_data.Data_1;
data = removeBackground(all_data.Data_1);

% resize data
scale = 0.5;
resized_data = rescaleSlices(data, scale);

% normalize data
resized_data = normalizeData(resized_data);

% set resolution of data
resolution = [1.29 1.29 20];
resolution(1:2) = resolution(1:2) / scale;


%%%  segment landmark in GFP channel

% segment GFP using Chambolle-Pock algorithm with ghresholding
%resized_landmark = segmentGFP(resized_data.GFP, resolution);

% segment GFP using k-means clustering
resized_landmark = k_means_clustering(resized_data.mCherry, 3, 'real');
resized_landmark = resized_landmark - 2;


% rescale result to full resolution
landmark = rescaleSlices(resized_landmark, 1/scale, 'nearest');

% plot result
figure; imagesc(computeMIP(data.mCherry)); hold on; contour(computeMIP(landmark), [0.5 0.5], 'r', 'LineWidth',2); hold off;