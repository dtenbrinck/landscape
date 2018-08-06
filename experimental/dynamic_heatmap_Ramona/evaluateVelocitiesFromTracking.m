function [cellCoordinates, cellVelocities] = evaluateVelocitiesFromTracking(tracks_PGC)

% we calculate the mean velocities in the embryo domain by adding all
% absolute velocities of each cell in the corresponding location in the
% image domain over the whole recorded time interval and normalizing those 
% by the number of recorded time frames for this cell
% finally we normalize again by deviding the summed up velocities by the
% number of recorded cells for this experiment


% as a first step we just add all cell coordinates for each of the recorded
% cell and its corresponding time frames

% define parameters to read and interpret PGC tracking data
maxNumberOfTimeframes = 20;
numberOfCells = numel(tracks_PGC);
positionPGC=2:4;
velocityNearestSomaticCell = 12:14;
velocityPGC = 9:11;

% allocate matrices for return values
cellCoordinates = zeros(3,numberOfCells * maxNumberOfTimeframes);
cellVelocities = zeros(1,numberOfCells * maxNumberOfTimeframes);

nextColumnIndexToInsert=0;
for trackedCellNo = 1:numberOfCells
    cellsFrames = tracks_PGC{trackedCellNo, 1};
    numberOfTrackedFrames = size(cellsFrames,1);
    
    cellCoordinates(:,nextColumnIndexToInsert+1:nextColumnIndexToInsert...
        +numberOfTrackedFrames) = (cellsFrames(:,positionPGC))';
   
    velocitiesMatrix = cellsFrames(:,velocityPGC) - cellsFrames(:, velocityNearestSomaticCell);
    for row = 1:numberOfTrackedFrames
        cellVelocities(1,nextColumnIndexToInsert+row) = norm(velocitiesMatrix(row,:));
    end
    nextColumnIndexToInsert = nextColumnIndexToInsert + numberOfTrackedFrames;
end

cellCoordinates( :, all(~cellCoordinates,1) ) = [];
cellVelocities( :, all(~cellVelocities,1) ) = [];

end