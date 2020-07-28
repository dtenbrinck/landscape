function p =  ParameterHeatmap()
%% PARAMETERS PROCESSING SCRIPT
% This file contains all parameters needed for the heatmap script with
% discriptions of each parameter. 

datatype = 'Zebrafish';
p.dynamicHeatmapsize = 'true'; % will consider the original data size

%% COMMON PARAMETER

% -- PROCSESSING OF THE CELLS -- %
% Tolerance for the cell to be outside of the sphere. Cells with norm
% bigger than 1 but smaller than 1+tole will be normalized.
% Default: 0.1
p.tole = 0.5;

% Grid size of the accumulator: 
% size(accumulator) = [gridSize,gridSize,gridSize];
if strcmp(p.dynamicHeatmapsize, 'true')
    p.gridSize = [255;255;255]; % Enter the same value for each direction! The value will be the minimum pixel size for each direction. Size will adjust to original data size.
elseif strcmp(datatype, 'Zebrafish')
    p.gridSize = [255;255;255]; %255
elseif strcmp(datatype, 'Drosophila')
    p.gridSize = [510;255;255];
end
% Select a given number of random filnames
p.random = 0;

% Select number of random filenames and process them
p.numberOfRandom = 100;

% This option allows to draw random cells for generating heatmaps when set to 1. 
p.drawRandomCells = 0;

% This specified percentage of cells will be drawn randomly during creation of
% heatmaps if the option drawRandomCells is activated.
p.percentageRandomCells = 10;

% Choose if generated shell heatmaps should have equal size
% If set to "false" this will fall back to the default mode in which we
% compute a landmark shell heatmap and two shell heatmaps for all data
% above and below the landmark, respectively.
p.equalSizedShells = false;


% Choose if profile lines should be extracted for the DAPI channel
p.extractProfileLines = false;

%% OPTIONS FOR THE HEATMAP HANDLER -- %

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
if strcmp(dynamicHeatmapsize, 'true')
    p.option.shellHeatmapResolution = [90, 90]; % Enter the same value for each direction! The value will be the minimum pixel size for each direction. Size will adjust to original data size.
if strcmp(datatype, 'Zebrafish')
    p.option.shellHeatmapResolution = [90, 90]; %(old:256,256 default) Zebrafish: 90,90, Dros 90,180
elseif strcmp(datatype, 'Drosophila')
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
end
