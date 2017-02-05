function p =  ParameterProcessing()
%% PARAMETERS PROCESSING SCRIPT
% This file contains all parameters needed for the preocessing script with
% discriptios of each parameter. 


%% COMMON PARAMETER
p.resolution = [1.29, 1.29, 20];
p.scale = 0.75;

% Debug variables
p.debug_level = 3;
p.visualization = 1;
%% SEGMNENTATION
% -- PREPROCESSING -- %
% - removing background -%
p.rmbg.dapiDiskSize = 5;
p.rmbg.GFPDiskSize = 50;
p.rmbg.mCherryDiskSize = 11;
% -- GFP SEGMENTATION -- %
p.GFPseg.k = 4;
p.GFPseg.morphSize = 5;
p.GFPseg.method = 'k-means'; % 'k-means', 'CP'
% -- mCherry SEGMENTATION -- %
p.mCherryseg.k = 3;
p.mCherryseg.cellSize = 50; %in pixel
p.mCherryseg.method = 'k-means'; % 'k-means', 'k-means_local', 'CP'
% -- LANDMARK PROJECTION -- %
p.samples_sphere = 128;
%% REGISTRATION
% -- REGISTRATION OF LANDMARK -- %
p.reg.landmarkCharacteristic = 'middle';
p.reg.characteristicWeight = 0.5;
p.reg.reference_point = [0; 0; -1];
p.reg.reference_vector = [1; 0; 0];
% - register data - %
p.samples_cube = 256;
end