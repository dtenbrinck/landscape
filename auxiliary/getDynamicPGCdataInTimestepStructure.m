function [cellCoordinates, cellSpeedValues] = ...
    getDynamicPGCdataInTimestepStructure(tracks_PGC, maxNumberOfTimeframes)

%% input:
% tracks_PGC:   struct containing dynamic PGC data consisting of 
%     column 1    :    timepoint
%     column 2:4  :    position of cell (mum)
%     column 5    :    delta t (min), time interval between consecutive positions
%     column 6:8  :    distance between consecutive positions
%     column 9:11 :    velocity (mum / min)
%     column 12:14:    (averaged) velocity of nearest somatic cells (mum / min)
%     
% maxNumberOfTimeframes: max. number of tracks with velocity values

%% output:
% cellCoordinates   : struct with accumulated cell positions for each time 
%                     step; appending all 3x1 pgc position vectors in
%                     horizontal array resulting in array of size
%                     3 x (number of tracked cells for this time step)
% cellSpeedValues   : struct with accumulated speed values of cells for
%                     each time step; appending all 3x1 pgc position 
%                     vectors in horizontal array resulting in array of size
%                     3 x (number of tracked cells for this time step)

%% define parameters to read and interpret PGC tracking data
timeframeColumn=1;
numberOfCells = numel(tracks_PGC);
positionPGCColumn=2:4;
velocityNearestSomaticCellColumn = 12:14;
velocityPGCColumn = 9:11;

%% allocate empty structs with fields for each time step
cellCoordinates{maxNumberOfTimeframes} = [];
cellSpeedValues{maxNumberOfTimeframes} = [];
   
%% accumulate PGC positions and speed values for each time step
for trackedCellNo = 1:numberOfCells
    cellsFrames = tracks_PGC{trackedCellNo, 1};
    numberOfTrackedFrames = size(cellsFrames,1);
   
    % compute net velocity by subtracting averaged somatic flow velocity of
    % surrounding somatic cells
    correctedVelocitiesMatrix = cellsFrames(:,velocityPGCColumn) - cellsFrames(:, velocityNearestSomaticCellColumn);
    for row = 1:numberOfTrackedFrames
        timePoint = cellsFrames(row,timeframeColumn);
        % cell positions
        cellCoordinates{timePoint} = ...
            [ cellCoordinates{timePoint}, (cellsFrames(row,positionPGCColumn))'];
        
        % speed values
        cellSpeedValues{timePoint} = ...
            [ cellSpeedValues{timePoint},  norm(correctedVelocitiesMatrix(row,:))];
    end
end

end