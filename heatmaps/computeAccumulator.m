function [ accumulator ] = computeAccumulator( allCellCoords, gridSize )
%This function computes the accumulator for the heatmap 

%% MAIN CODE

accumulator = zeros(gridSize,gridSize,gridSize);
% Rewrite the cell coordinates into linear indexing
indPoints = sub2ind([gridSize,gridSize,gridSize]...
    ,allCellCoords(2,:),allCellCoords(1,:),allCellCoords(3,:));

% Find out how many points are on the same gridpoint
[uniquePoints,ai,~] = unique(indPoints,'stable');

% Values give number of points on that gridpoint
accumulator(uniquePoints) = 1;

if numel(uniquePoints) < numel(indPoints);
    indPoints(ai)=[];
    l = numel(indPoints);
    while l > 0
        [uniquePoints,ai,~] = unique(indPoints,'stable');
        accumulator(uniquePoints) = accumulator(uniquePoints)+1;
        indPoints(ai) = [];
        l = numel(indPoints);
    end
end



end

