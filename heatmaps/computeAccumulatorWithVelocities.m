function [ accumulator ] = computeAccumulatorWithVelocities( allCellCoords, gridSize, cellVelocities )
%This function computes the accumulator for the heatmap 

%% MAIN CODE

% Rewrite the cell coordinates into linear indexing
indPoints = sub2ind([gridSize(2),gridSize(1),gridSize(3)]...
    ,allCellCoords(2,:),allCellCoords(1,:),allCellCoords(3,:));

accumulator = reshape(accumarray([indPoints';gridSize(1)*gridSize(2)*gridSize(3)],[cellVelocities';0]),[gridSize(2),gridSize(1),gridSize(3)]);

end

