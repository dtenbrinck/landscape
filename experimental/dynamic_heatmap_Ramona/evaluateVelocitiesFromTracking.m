function [cellCoordinates, cellSpeedValues] = evaluateVelocitiesFromTracking(tracks_PGC)

% define parameters to read and interpret PGC tracking data
maxNumberOfTimeframes = 20;
numberOfCells = numel(tracks_PGC);
positionPGC=2:4;
velocityNearestSomaticCell = 12:14;
velocityPGC = 9:11;

% allocate matrices for return values
cellCoordinates = zeros(3,numberOfCells * maxNumberOfTimeframes);
cellSpeedValues = zeros(1,numberOfCells * maxNumberOfTimeframes);

nextColumnIndexToInsert=0;
for trackedCellNo = 1:numberOfCells
    cellsFrames = tracks_PGC{trackedCellNo, 1};
    numberOfTrackedFrames = size(cellsFrames,1);
    
    cellCoordinates(:,nextColumnIndexToInsert+1:nextColumnIndexToInsert...
        +numberOfTrackedFrames) = (cellsFrames(:,positionPGC))';
   
    % compute net velocity by subtracting averaged somatic flow velocity of
    % surrounding somatic cells
    velocitiesMatrix = cellsFrames(:,velocityPGC) - cellsFrames(:, velocityNearestSomaticCell);
    for row = 1:numberOfTrackedFrames
        cellSpeedValues(1,nextColumnIndexToInsert+row) = norm(velocitiesMatrix(row,:));
    end
    nextColumnIndexToInsert = nextColumnIndexToInsert + numberOfTrackedFrames;
end

cellCoordinates( :, all(~cellCoordinates,1) ) = [];
cellSpeedValues( :, all(~cellSpeedValues,1) ) = [];

end