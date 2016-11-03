function p =  ParameterProcessing()
%% PARAMETERS PROCESSING SCRIPT
% This file contains all parameters needed for the preocessing script with
% discriptios of each parameter. 


%% COMMON PARAMETER
p.resolution = [1.29, 1.29, 20];
p.scale = 0.75;

% some output variables
p.debug_level = 0;
p.visualization = 0;
%% SEGMNENTATION
% -- PREPROCESSING -- %
% - removing background -%
p.rmbg.dapiDiskSize = 5;
p.rmbg.GFPDiskSize = 50;
p.rmbg.mCherryDiskSize = 11;
% -- GFP SEGMENTATION -- %
p.GFPseg.k = 4;
p.GFPseg.morphSize = 5;
% -- mCherry SEGMENTATION -- %
p.mCherryseg.k = 3;
p.mCherryseg.cellSize = 50; %in pixel
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