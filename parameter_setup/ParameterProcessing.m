function p =  ParameterProcessing()
%% PARAMETERS PROCESSING SCRIPT
% This file contains all parameters needed for the processing script with
% discriptios of each parameter.        
  

p.mappingtype = 'Cells'; %either Cells or Tissue, depending on how the mCherry channel should be treated
p.datatype = 'Zebrafish'; %Zebrafish or Drosophila

%% COMMON PARAMETER
if strcmp(p.datatype, 'Zebrafish')
    p.resolution = [1.29,1.29,7.2639]; %1.29,1.29,10 default settings for SD 0.32,0.32,5 for Drosophila
elseif strcmp(p.datatype, 'Drosophila')
    p.resolution = [0.32,0.32,5];
end

p.scale = 0.75;
p.scaleAllDim = 0;


% Debug variables
p.debug_level = 1; %1
p.visualization = 0; %0
p.proofOfPrinciple = 0; %0 

%% PREPROCESSING
% -- BACKGROUND REMOVAL -- %
p.rmbg.dapiDiskSize = 5; %5
p.rmbg.GFPDiskSize = 50; %50
if strcmp(p.mappingtype, 'Cells') %the mCherry parameter depends on mapping type
    p.rmbg.mCherryDiskSize = 11; %11
else
    p.rmbg.mCherryDiskSize = 50; %50
end

%% SEGMNENTATION
% -- DAPI SEGMENTATION -- %
p.DAPIseg.method = 'k-means'; % 'Laplacian', 'CP'
p.DAPIseg.k = 3;
p.DAPIseg.minNucleusSize = 6; % min. nucleus size
% -- GFP SEGMENTATION -- %
p.GFPseg.k = 4; %4 
p.GFPseg.size_opening = 5; %5Manual
p.GFPseg.size_closing = 30;
p.GFPseg.method = 'k-means'; % 'k-means', 'CP'
p.GFPseg.downsampling_factor = 0.2;
p.GFPseg.minNumberVoxels = 2000;
% threshold level (percentage) to cut off blurry effects for EPI data
p.GFPseg.threshold = 0.75; % SD: 0, EPI: 0.98 e.g.
% -- mCherry SEGMENTATION -- %
% binarization step before actual (blob) segmentation is variable,
% default: 'kittler'
% 'k-means': Spinning Disc (SD) Confocal Microscopy data
% 'kittler': Epifluorescence Microscopy (EPI): kittler
p.mCherryseg.binarization = 'k-means'; % 'k-means', 'kittler'
p.mCherryseg.k = 3; %3
p.mCherryseg.cellSize = 15; %50. in pixel %15 for Drosophila
%p.mCherryseg.method = 'k-means'; % 'k-means', 'k-means_local', 'CP'
% -- LANDMARK PROJECTION -- %
p.samples_sphere = 256; %128 %PoP:256

%% ELLIPSOIDAL FITTING
p.ellipsoidFitting.percentage = 100; % 10 percent for old dapi segmentation
p.ellipsoidFitting.visualization = 0;

p.ellipsoidFitting.descentMethod = 'cg'; % 'grad'

if strcmp(p.datatype, 'Zebrafish')
    p.ellipsoidFitting.regularisationParams.mu0 = 10^-7; %10^8 for old dapi segmentation %now 10^-7 %Drosoph: 10^-4 
    p.ellipsoidFitting.regularisationParams.mu1 = 10^-4; %2*10⁻4 old % 0.002 for old dapi segmentation  %now1*10^-4 Drosoph: 0.008
    p.ellipsoidFitting.regularisationParams.mu2 = 1; %1 
    p.ellipsoidFitting.regularisationParams.gamma = 1;
    p.ellipsoidFitting.pcaType = 'Zebrafish';
elseif strcmp(p.datatype, 'Drosophila')
    p.ellipsoidFitting.regularisationParams.mu0 = 10^-4; %10^8 for old dapi segmentation %now 10^-7 %Drosoph: 10^-4 
    p.ellipsoidFitting.regularisationParams.mu1 = 0.008; %2*10⁻4 old % 0.002 for old dapi segmentation  %now1*10^-4 Drosoph: 0.008
    p.ellipsoidFitting.regularisationParams.mu2 = 1; %1 
    p.ellipsoidFitting.regularisationParams.gamma = 1;
    p.ellipsoidFitting.pcaType = 'Drosophila';
end
%% REGISTRATION
% -- REGISTRATION OF LANDMARK -- %
p.reg.landmarkCharacteristic = 'middle';

if strcmp(p.datatype, 'Zebrafish')
    p.reg.characteristicWeight = 0; % 0 = head, 1 = tail
    zwert =0; %value for z (front = -1 to back = 1. Default is left = 0) for the reference point, only works for points on the left half of the unit ball. -0.95 for Dros
elseif strcmp(p.datatype, 'Drosophila')
    p.reg.characteristicWeight = 0.5; % 0 = head, 1 = tail
    zwert =-0.95; %-0.95
end

p.reg.reference_point = [-sqrt(1-zwert^2); 0; zwert]; 
%if zwert < 0
%    p.reg.reference_vector = [-1; 0; -sqrt(1-zwert^2)/zwert];
%    p.reg.reference_vector = p.reg.reference_vector * 1/norm(p.reg.reference_vector); 
%elseif zwert > 0
%    p.reg.reference_vector = [1; 0; sqrt(1-zwert^2)/zwert];
%    p.reg.reference_vector = p.reg.reference_vector * 1/norm(p.reg.reference_vector);
%else    
%    p.reg.reference_vector = [0; 0; -1]; 
%end
p.reg.reference_vector = [-p.reg.reference_point(3);0;p.reg.reference_point(1)];
% - register data - %
if strcmp(p.datatype, 'Zebrafish')
    p.samples_cube = [256,256,256]; %[256,256,256]
elseif strcmp(p.datatype, 'Drosophila')
    p.samples_cube = [512,256,256]; %[512,256,256]
end

end
