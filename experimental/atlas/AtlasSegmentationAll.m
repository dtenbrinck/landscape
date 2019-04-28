% INITIALIZATION
clear; clc; close all;

% add path for parameter setup
root_dir = fileparts(fileparts(pwd));
addpath([root_dir '/parameter_setup/']);
%addpath('./parameter_setup/');

% load necessary variables
p = initializeScript('processing', root_dir);

% Select the files
dname.dapi = uigetfile(p.dataPath,'Please select the dapi data!'); % Select all files to see the data
dname.gfp = uigetfile(p.dataPath,'Please select the GFP data!');
dname.meso = uigetfile(p.dataPath,'Please select the mesoderm data!');
dname.endo = uigetfile(p.dataPath,'Please select the endo/ectoderm data!');


% Import the Data, segment channels separately
if p.debug_level >= 1; disp('Dapi Data'); end
[binaryX.dapi, OriginalData.dapi] = AtlasSegmentationSingleTemp(dname.dapi, p);
if p.debug_level >= 1; disp('GFP Data'); end
[binaryX.gfp, OriginalData.gfp] = AtlasSegmentationSingleTemp(dname.gfp, p);
if p.debug_level >= 1; disp('Mesoderm Data'); end
[binaryX.meso, OriginalData.meso] = AtlasSegmentationSingleTemp(dname.meso, p);
if p.debug_level >= 1; disp('Endo/Ectoderm Data'); end
[binaryX.endo, OriginalData.endo] = AtlasSegmentationSingleTemp(dname.endo, p);

filename_original_data = [p.resultsPath '\' dname.dapi(1:end-8) 'all_original_data'];
save(filename_original_data,'OriginalData');
filename_segmentation = [p.resultsPath '\' dname.dapi(1:end-8) 'all_atlas_segmentation'];
save(filename_segmentation,'binaryX');

%clc; clear;