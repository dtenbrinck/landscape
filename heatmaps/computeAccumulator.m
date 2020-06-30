function [ accumulator ] = computeAccumulator( allCellCoords, p )
%This function computes the accumulator for the heatmap 

%% MAIN CODE

% Rewrite the cell coordinates into linear indexing
%ratio = 1; % Zebrafish:1 Dros:2
%indPoints = sub2ind([gridSize,ratio*gridSize,gridSize]...
%    ,allCellCoords(2,:),ratio*allCellCoords(1,:),allCellCoords(3,:));

%accumulator = reshape(accumarray([indPoints';ratio*gridSize*gridSize*gridSize],[ones(size(indPoints'));0]),[gridSize,ratio*gridSize,gridSize]);

indPoints = sub2ind([p.gridSize(2),p.gridSize(1),p.gridSize(3)]...
    ,allCellCoords(2,:),allCellCoords(1,:),allCellCoords(3,:));

accumulator = reshape(accumarray([indPoints';p.gridSize(1)*p.gridSize(2)*p.gridSize(3)],[ones(size(indPoints'));0]),[p.gridSize(2),p.gridSize(1),p.gridSize(3)]);


end

