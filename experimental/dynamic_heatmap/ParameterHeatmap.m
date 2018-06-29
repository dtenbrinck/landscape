function p =  ParameterHeatmap()
%% PARAMETERS PROCESSING SCRIPT
% This file contains all parameters needed for the heatmap script with
% discriptions of each parameter. 

%% COMMON PARAMETER

% -- SIZE OF CELL IN THE GRID DOMAIN -- %
%  !!! Not working because not elaborated enough !!! %
% Size of the cells
p.sizeCells = 20; %um
% Size of the Pixel
p.sizeOfPixel = 1.3; %um
p.sizeCellsPixel = round(p.sizeCells/p.sizeOfPixel);

% -- PROCSESSING OF THE CELLS -- %
% Tolerance for the cell to be outside of the sphere. Cells with norm
% bigger than 1 but smaller than 1+tole will be normalized.
% Default: 0.1
p.tole = 0.1;

% Grid size of the accumulator: 
% size(accumulator) = [gridSize,gridSize,gridSize];
p.gridSize = 256;

% Select a given number of random filnames
p.random = 0;

% Select number of random filenames and process them
p.numberOfRandom = 100;
%% OPTIONS FOR THE HEATMAP HANDLER -- %
% The cellradius in pixels in the sampled p.gridSize space.
% So this needs to be changed to depending on gridSize.
% The cell will be cellradius*2 pixels big. 
% !!! NEED A BETTER APPROACH !!! %
% Default: 5 with gridSize = 256
p.option.cellradius = 7; %7 for mCherry
% cell radius for nuclei cells in DAPI channel
% Default: 2 with gridSize = 256
p.option.dapiCellradius = 1;

% - Slider options - %
% Will show the Slider 
p.option.slider = 0;  %in progress

% - Cropper options
p.option.cropper = 0;

% -- Options for the heatmap generation -- %

% Process standard heatmaps? 1: yes, 0: no
% Every option beneath will be irrelevant if 0.
p.option.heatmaps.process = 1;

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
p.option.heatmaps.scaled = 'true';

% Frame number if several frames for dynamic data should be saved
p.option.frameNo = '';

% calculation of axis scaling active: default value -1
p.option.axisLimit = -1;
end
