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
%% REGISTRATION
% -- REGISTRATION OF LANDMARK -- %
p.reg.landmarkCharacteristic = 'middle';
p.reg.characteristicWeight = 0; % 0 = head, 1 = tail
zwert = 0; %value for z (front - back) at the reference point, only works for points on the left half of the unit ball
p.reg.reference_point = [-sqrt(1-zwert^2); 0; zwert]; 
p.reg.reference_vector = [zwert/(-sqrt(1-zwert^2)); 0; -1];
% - register data - %
p.samples_cube = 256;
end
