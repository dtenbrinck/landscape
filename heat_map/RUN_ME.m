% load registered data
load('validitystudy.mat')

% manually set validity of first data set
cellImages{1}.valid = 1;

% collect center-of-masses of cells in all data sets
%CoMs = getCoMs(cellImages,m);

% collect cells in all data sets
cells = getCells(cellImages,m);

% get GFP of reference data set for overlay
GFP_reference = cellImages{1}.GFP;

% visualization
plotHeatmap(cells);