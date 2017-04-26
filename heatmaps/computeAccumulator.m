function [ accumulator ] = computeAccumulator( allCellCoords, gridSize )
%This function computes the accumulator for the heatmap 

%% MAIN CODE

% Rewrite the cell coordinates into linear indexing
indPoints = sub2ind([gridSize,gridSize,gridSize]...
    ,allCellCoords(2,:),allCellCoords(1,:),allCellCoords(3,:));

accumulator = reshape(accumarray([indPoints';gridSize*gridSize*gridSize],[ones(size(indPoints'));0]),[gridSize,gridSize,gridSize]);



end

