% we assume that allCellCoords contains coordinates in the reference coordinate system
function [cellCoordsInShell] = getShell(allCellCoords, minRadius, maxRadius)

% get distance for each cell to origin
distances = sqrt(sum(double(allCellCoords).^2,1));

% extract all cells in this shell
cellCoordsInShell= allCellCoords(:,...
    distances <= maxRadius & distances >= minRadius);

end