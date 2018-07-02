function [ accumulator ] = computeAccumulatorWithVelocities( allCellCoords, gridSize, cellVelocities )
%This function computes the accumulator for the heatmap 

%% MAIN CODE

% Rewrite the cell coordinates into linear indexing
indPoints = sub2ind([gridSize,gridSize,gridSize]...
    ,allCellCoords(2,:),allCellCoords(1,:),allCellCoords(3,:));
averagedVelocities = cellVelocities / size(cellVelocities,2);
accumulator = reshape(accumarray([indPoints';gridSize*gridSize*gridSize],[averagedVelocities';0]),[gridSize,gridSize,gridSize]);

end

