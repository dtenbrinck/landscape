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

%% SEGMNENTATION
% -- DAPI SEGMENTATION -- %
p.DAPIseg.method = 'k-means'; % 'Laplacian', 'CP'
p.DAPIseg.k = 3;
% -- GFP SEGMENTATION -- %
p.GFPseg.k = 4; %4 
p.GFPseg.morphSize = 5; %5
p.GFPseg.method = 'k-means'; % 'k-means', 'CP'
% -- mCherry SEGMENTATION -- %
% binarization step before actual (blob) segmentation is variable,
% default: 'kittler'
% 'k-means': Spinning Disc (SD) Confocal Microscopy data
% 'kittler': Epifluorescence Microscopy (EPI): kittler
p.mCherryseg.binarization = 'kittler'; % 'k-means', 'kittler'
p.mCherryseg.k = 3; %3
p.mCherryseg.cellSize = 50; %50. in pixel
p.mCherryseg.method = 'k-means'; % 'k-means', 'k-means_local', 'CP'
% -- LANDMARK PROJECTION -- %
p.samples_sphere = 128;

%% ELLIPSOIDAL FITTING
p.ellipsoidFitting.percentage = 10;
p.ellipsoidFitting.visualization = 0;
p.ellipsoidFitting.regularisationParams.mu0 = 10^-8;
p.ellipsoidFitting.regularisationParams.mu1 = 0.002; 
p.ellipsoidFitting.regularisationParams.mu2 = 1;
p.ellipsoidFitting.regularisationParams.gamma = 1; 
p.ellipsoidFitting.descentMethod = 'cg'; % 'grad'
%% REGISTRATION
% -- REGISTRATION OF LANDMARK -- %
p.reg.landmarkCharacteristic = 'middle';
p.reg.characteristicWeight = 0.5; %0,5
p.reg.reference_point = [0; 0; -1];
p.reg.reference_vector = [1; 0; 0];
% - register data - %
p.samples_cube = 256;
end
