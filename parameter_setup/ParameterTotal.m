function p = ParameterTotal()
%%ParameterTotal
%This script contains all paraneters needed for processing, evaluating or
%visualizing.

p.mappingtype = 'Cells'; %either Cells or Tissue, depending on how the mCherry channel should be treated
p.datatype = 'Zebrafish'; %Zebrafish or Drosophila

%% COMMON PARAMETER
if strcmp(p.datatype, 'Zebrafish')
    p.resolution = [1.29,1.29,10]; %1.29,1.29,10 default settings for SD 0.32,0.32,5 for Drosophila
elseif strcmp(p.datatype, 'Drosophila')
    p.resolution = [0.32,0.32,5];
end

p.scale = 0.75;
p.scaleAllDim = 0;

% adjust resolution according to scale parameter
p.resolution(1:2) = p.resolution(1:2) / p.scale;

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
%p.mCherryseg.cellSize = 15; %50. in pixel %15 for Drosophila
%p.mCherryseg.method = 'k-means'; % 'k-means', 'k-means_local', 'CP'
% -- LANDMARK PROJECTION -- %
p.samples_sphere = 256; %128 %PoP:256

%% ELLIPSOIDAL FITTING
p.ellipsoidFitting.percentage = 100; % 10 percent for old dapi segmentation
p.ellipsoidFitting.visualization = 0;

p.ellipsoidFitting.descentMethod = 'cg'; % 'grad'

if strcmp(p.datatype, 'Zebrafish')
    p.ellipsoidFitting.regularisationParams.mu0 = 10^-7; %10^8 for old dapi segmentation %now 10^-7 %Drosoph: 10^-4 
    p.ellipsoidFitting.regularisationParams.mu1 = 10^-4; %2*10â?»4 old % 0.002 for old dapi segmentation  %now1*10^-4 Drosoph: 0.008
    p.ellipsoidFitting.regularisationParams.mu2 = 1; %1 
    p.ellipsoidFitting.regularisationParams.gamma = 1;
    p.ellipsoidFitting.pcaType = 'Zebrafish';
elseif strcmp(p.datatype, 'Drosophila')
    p.ellipsoidFitting.regularisationParams.mu0 = 10^-4; %10^8 for old dapi segmentation %now 10^-7 %Drosoph: 10^-4 
    p.ellipsoidFitting.regularisationParams.mu1 = 0.008; %2*10â?»4 old % 0.002 for old dapi segmentation  %now1*10^-4 Drosoph: 0.008
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
p.reg.reference_vector = [-p.reg.reference_point(3);0;p.reg.reference_point(1)];
% - register data - %
if strcmp(p.datatype, 'Zebrafish')
    p.samples_cube = [256,256,256]; %[256,256,256]
elseif strcmp(p.datatype, 'Drosophila')
    p.samples_cube = [512,256,256]; %[512,256,256]
end



%---------------------------------------------------------------------------


%% COMMON PARAMETER

% -- SIZE OF CELL IN THE GRID DOMAIN -- %
%  !!! Not working because not elaborated enough !!! %
% Size of the cells
p.sizeCells = 20; %um
% Size of the Pixel
if strcmp(p.datatype, 'Zebrafish')
    p.sizeOfPixel = 1.29; %um 1.29 Zebrafish
elseif strcmp(p.datatype, 'Drosophila')
    p.sizeOfPixel = 0.32;
end
p.sizeCellsPixel = round(p.sizeCells/p.sizeOfPixel);

% -- PROCSESSING OF THE CELLS -- %
% Tolerance for the cell to be outside of the sphere. Cells with norm
% bigger than 1 but smaller than 1+tole will be normalized.
% Default: 0.1
p.tole = 0.5;

% Grid size of the accumulator: 
if strcmp(p.datatype, 'Zebrafish')
    p.gridSize = [255;255;255]; %255
elseif strcmp(p.datatype, 'Drosophila')
    p.gridSize = [510;255;255];
end
% Select a given number of random filnames
p.random = 0;

% Select number of random filenames and process them
p.numberOfRandom = 100;

% Choose if generated shell heatmaps should have equal size
% If set to "false" this will fall back to the default mode in which we
% compute a landmark shell heatmap and two shell heatmaps for all data
% above and below the landmark, respectively.
p.equalSizedShells = false;


% Choose if profile lines should be extracted for the DAPI channel
p.extractProfileLines = false;

%% OPTIONS FOR THE HEATMAP HANDLER -- %
% The cellradius in pixels in the sampled p.gridSize space.
% So this needs to be changed to depending on gridSize.
% The cell will be cellradius*2 pixels big. 
% !!! NEED A BETTER APPROACH !!! %
% Default: 5 with gridSize = 256
if strcmp(p.datatype, 'Zebrafish')
    p.option.cellradius = 7;  %for mCherry, Zebrafish:7  Dros:3
elseif strcmp(p.datatype, 'Drosophila')
    p.option.cellradius = 3;
end
% cell radius for nuclei cells in DAPI channel
% Default: 2 with gridSize = 256
%p.option.dapiCellradius = 1;

% - Slider options - %
% Will show the Slider 
p.option.slider = 0;  %in progress

% - Cropper options
p.option.cropper = 0;

% -- Options for the heatmap generation -- %

% Thickness of shells for mercator projection
p.option.shellThickness = 0.12;%0.0608;

% Shift width for shell computation
% Note that shellShiftWidth = shellThickness means no overlap between heatmaps
p.option.shellShiftWidth = 0.01;

% Resolution for the shell heatmap in pixels
if strcmp(p.datatype, 'Zebrafish')
    p.option.shellHeatmapResolution = [90, 90]; %(old:256,256 default) Zebrafish: 90,90, Dros 90,180
elseif strcmp(p.datatype, 'Drosophila')
    p.option.shellHeatmapResolution = [90,180];
end
% Types of heatmaps. Currently available 'MIP', 'SUM'.
% Can handle multiple input.
% Default: {'MIP','SUM'}
p.option.heatmaps.types = {'MIP','SUM'};

% - Saving - %
% Saves will be aved in results folder under "heatmaps"
% Save heatmaps
p.option.heatmaps.save = 1;

% Save heatmaps as file type
% Can handle multiple input
% Default: {'png','fig'}
p.option.heatmaps.saveas = {'png'};

% Save the heatmap structure with the matrices for the visualization in the
% figures.
p.option.heatmaps.saveHMmat = 1;

% Save the accumulator matrix. This is the pure 3D matrix which stores the
% number of cells at a voxel position
p.option.heatmaps.saveAccumulator = 1;

% Show the heatmaps figures. Doesn't need to be activated for the saving.
p.option.heatmaps.disp = 0;

% Scale the heatmaps. Input can be: 'true','false','both'
p.option.heatmaps.scaled = 'both';

% use an averaged amount of found landmark cells to be considered in the dynamic heatmaps
% the value indicates the percentage of of found cells in this area considering the total number of results
p.referenceLandmark.percentage = 0.5; 


p.dynamicHeatmapsize = 'true';
end