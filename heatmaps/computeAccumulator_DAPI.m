function [ accumulator ] = computeAccumulator_DAPI( allCellCoords, gridSize )
%This function computes the accumulator for the heatmap 

%% MAIN CODE

% get smallest coordinates per axes
minX = min(allCellCoords(1,:));
minY = min(allCellCoords(2,:));
minZ = min(allCellCoords(3,:));

allCellCoords_translated = -repmat([minX - 1;minY - 1;minZ - 1], 1, size(allCellCoords,2)) + allCellCoords;

maxCoord = max(allCellCoords_translated(:));

allCellCoords_scaled = reshape(round( (allCellCoords_translated(:) - 1) / (maxCoord-1) * (gridSize-1) + 1), size(allCellCoords));


% Rewrite the cell coordinates into linear indexing
indPoints = sub2ind([gridSize,gridSize,gridSize]...
    ,allCellCoords_scaled(2,:),allCellCoords_scaled(1,:),allCellCoords_scaled(3,:));
%indPoints = sub2ind([gridSize,gridSize,gridSize]...
    %,allCellCoords(2,:),allCellCoords(1,:),allCellCoords(3,:));

accumulator = reshape(accumarray([indPoints';gridSize*gridSize*gridSize],[ones(size(indPoints'));0]),[gridSize,gridSize,gridSize]);



end

