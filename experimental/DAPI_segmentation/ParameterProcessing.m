function p =  ParameterProcessing()
%% PARAMETERS PROCESSING SCRIPT
% This file contains all parameters needed for the preocessing script with
% discriptios of each parameter.        

            
%% COMMON PARAMETER
p.resolution = [1.29, 1.29, 20];
p.scale = 0.75;

% Debug variables
p.debug_level = 1; %1
p.visualization = 0; %0

%% PREPROCESSING
% -- BACKGROUND REMOVAL -- %
p.rmbg.dapiDiskSize = 5; %5
p.rmbg.GFPDiskSize = 50; %50
p.rmbg.mCherryDiskSize = 11; %11

%% SEGMENTATION

% -- DAPI SEGMENTATION -- %
p.DAPIseg.method = 'Laplacian'; % 'k-means', 'CP'
%p.DAPIseg.k = 3;
p.DAPIseg.maxNucleusSize = 20; % max. nucleus size
p.DAPIseg.minNucleusSize = 3; % min. nucleus size
% -- GFP SEGMENTATION -- %
p.GFPseg.method = 'k-means'; % 'k-means', 'CP'
p.GFPseg.k = 4; %4 
p.GFPseg.morphSize = 5; %5
% -- mCherry SEGMENTATION -- %
p.mCherryseg.k = 3; %3
p.mCherryseg.cellSize = 50; %50. in pixel
p.mCherryseg.method = 'k-means'; % 'k-means', 'k-means_local', 'CP'

%% REGISTRATION
% -- LANDMARK PROJECTION -- %
p.samples_sphere = 128;
% -- REGISTRATION OF LANDMARK -- %
p.reg.landmarkCharacteristic = 'middle';
p.reg.characteristicWeight = 0.5; %0,5
p.reg.reference_point = [0; 0; -1];
p.reg.reference_vector = [1; 0; 0];
% - register data - %
p.samples_cube = 256;
end
