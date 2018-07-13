function [ accumulator ] = computeAccumulatorWithVelocities( allCellCoords, gridSize, cellVelocities )
%This function computes the accumulator for the heatmap 

%% MAIN CODE

% Rewrite the cell coordinates into linear indexing
indPoints = sub2ind([gridSize,gridSize,gridSize]...
    ,allCellCoords(2,:),allCellCoords(1,:),allCellCoords(3,:));

accumulatorVelo = reshape(accumarray([indPoints';gridSize*gridSize*gridSize],[cellVelocities';0]),[gridSize,gridSize,gridSize]);
accumulatorCoord = reshape(accumarray([indPoints';gridSize*gridSize*gridSize],[ones(size(indPoints'));0]),[gridSize,gridSize,gridSize]);

% normalize velocities in each and every pixel by deviding velocities by the number of counted
% velocities in that one
accumulatorCoord(~accumulatorCoord)=1;
accumulator = accumulatorVelo ./ accumulatorCoord;
end

