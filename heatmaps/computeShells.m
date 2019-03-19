% we assume that allCellCoords contains coordinates in the reference coordinate system
function [cellCoordsPerShell, max_distance] = computeShells(allCellCoords, shellThickness, shellShiftWidth)

% get distance for each cell to origin
distances = sqrt(sum(double(allCellCoords).^2,1));

% determine largest cell distance to origin
max_distance = max(distances);

% determine smallest cell distance to origin
min_distance = min(distances);

% compute how many shells we will get based on shellThickness and shellShiftWidth
numberOfShells = ceil(( max_distance - shellThickness - min_distance) / shellShiftWidth) + 1;

% initialize container for saving coordinates per shell
cellCoordsPerShell = cell(1,numberOfShells);

% loop over all shells starting from the outside of the embryo
for shell=1:numberOfShells
    
    % determine maximum and minimum distance of coordinates to origin in this shell
    maxRadius = max_distance - shellShiftWidth*(shell-1);
    minRadius = maxRadius - shellThickness;
    
    % extract all cells in this shell
    cellCoordsPerShell{shell} = allCellCoords(:,...
        distances <= maxRadius & distances > minRadius);
    
end

end