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
p.sizeOfPixel = 1.29; %um
p.sizeCellsPixel = round(p.sizeCells/p.sizeOfPixel);

% -- PROCSESSING OF THE CELLS -- %
% Tolerance for the cell to be outside of the sphere. Cells with norm
% bigger than 1 but smaller than 1+tole will be normalized.
% Default: 0.1
p.tole = 0.1;

% Grid size of the accumulator: 
% size(accumulator) = [gridSize,gridSize,gridSize];
p.gridSize = 255;

% Select a given number of random filnames
p.random = 0;

% Select number of random filenames and process them
p.numberOfRandom = 100;

% Choose if generated shell heatmaps should have equal size
% If set to "false" this will fall back to the default mode in which we
% compute a landmark shell heatmap and two shell heatmaps for all data
% above and below the landmark, respectively.
p.equalSizedShells = true;


% Choose if profile lines should be extracted for the DAPI channel
p.extractProfileLines = true;

%% OPTIONS FOR THE HEATMAP HANDLER -- %
% The cellradius in pixels in the sampled p.gridSize space.
% So this needs to be changed to depending on gridSize.
% The cell will be cellradius*2 pixels big. 
% !!! NEED A BETTER APPROACH !!! %
% Default: 5 with gridSize = 256
p.option.cellradius = 7; %7 for mCherry
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
p.option.shellThickness = 0.1;%0.0608;

% Shift width for shell computation
% Note that shellShiftWidth = shellThickness means no overlap between heatmaps
p.option.shellShiftWidth = p.option.shellThickness;

% Resolution for the shell heatmap in pixels
p.option.shellHeatmapResolution = [90, 90]; %256,256 default

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
end
