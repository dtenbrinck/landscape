function [cells, cellCoordinates] = evaluateVelocitiesFromTracking(tracks_PGC, scale)

% we calculate the mean velocities in the embryo domain by adding all
% absolute velocities of each cell in the corresponding location in the
% image domain over the whole recorded time interval and normalizing those 
% by the number of recorded time frames for this cell
% finally we normalize again by deviding the summed up velocities by the
% number of recorded cells for this experiment

numberOfCells = numel(tracks_PGC);

for trackedCellNo = 1:numberOfCells
    cellsFrames = tracks_PGC{trackedCellNo, 1};
    numberOfTrackedFrames = size(cellsFrames,1);
    for timeframe= 1:numberOfTrackedFrames
        fprintf('##############  timeframe %d of cell %d\n', timeframe, trackedCellNo);
    end
    
end
disp('###################################');
end