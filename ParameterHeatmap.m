function p =  ParameterHeatmap()
%% PARAMETERS PROCESSING SCRIPT
% This file contains all parameters needed for the heatmap script with
% discriptios of each parameter. 

%% PARAMETER 

% -- SIZE OF CELL IN THE GRID DOMAIN -- %
%  !!! Not working because not elaborated enough !!! %
% Size of the cells
p.sizeCells = 20; %um
% Size of the Pixel
p.sizeOfPixel = 0.29; %um
p.sizeCellsPixel = round(p.sizeCells/p.sizeOfPixel);

% -- PROCSESSING OF THE CELLS -- %
% Tolerance for the cell to be outside of the sphere. Cells with norm
% bigger than 1 but smaller than 1+tole will be normalized.
p.tole = 0.1;

% Grid size of the accumulator: 
% size(accumulator) = [gridSize,gridSize,gridSize];
p.gridSize = 256;

% -- OPTIONS FOR THE HEATMAP HANDLER -- %
p.option.cellradius = 5;
p.option.slider = 1;  %in progress

% - Options for the heatmap generation
p.option.heatmaps.types = {'MIP','SUM'};
p.option.heatmaps.process = 1;
p.option.heatmaps.save = 1;
p.option.heatmaps.saveHMmat = 1;
p.option.heatmaps.saveAccumulator = 1;
p.option.heatmaps.saveas = {'png','bmp'};
p.option.heatmaps.disp = 0;
p.option.heatmaps.scaled = 'both'; % 'true','false','both'
end
