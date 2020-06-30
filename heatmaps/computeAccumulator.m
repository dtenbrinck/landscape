function [ accumulator ] = computeAccumulator( allCellCoords, p )
%This function computes the accumulator for the heatmap 

%% MAIN CODE

% Rewrite the cell coordinates into linear indexing
%ratio = 1; % Zebrafish:1 Dros:2
%indPoints = sub2ind([gridSize,ratio*gridSize,gridSize]...
%    ,allCellCoords(2,:),ratio*allCellCoords(1,:),allCellCoords(3,:));

%accumulator = reshape(accumarray([indPoints';ratio*gridSize*gridSize*gridSize],[ones(size(indPoints'));0]),[gridSize,ratio*gridSize,gridSize]);

%get parameters
gridSize = p.gridSize;
resolution = [1.72, 1.72, 10]; %TODO: Solve problem with saving resolution and load the resolution from the parameter file
dynamicHeatmapsize = 'true'; %TODO: siehe oben
if strcmp(dynamicHeatmapsize, 'true') 
     dataSize_um = p.scaledDataSize .* resolution; % calculate size of the image in um
     M = min(dataSize_um); % find the shortest side of the image
     for i = 1:3 
        ratio = dataSize_um(i)/M; % calculate ratios of the others sides to the shortest side
        gridSize(i) = round(ratio*gridSize(i)); % adjust gridSize according to ratio
     end   
end

indPoints = sub2ind([gridSize(2),gridSize(1),gridSize(3)]...
    ,allCellCoords(2,:),allCellCoords(1,:),allCellCoords(3,:));

accumulator = reshape(accumarray([indPoints';gridSize(1)*gridSize(2)*gridSize(3)],[ones(size(indPoints'));0]),[gridSize(2),gridSize(1),gridSize(3)]);


end

