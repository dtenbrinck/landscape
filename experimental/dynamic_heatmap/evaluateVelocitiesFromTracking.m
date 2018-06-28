function [cellCoordinates, cellVelocities] = evaluateVelocitiesFromTracking(tracks_PGC, scale, resolution)

% we calculate the mean velocities in the embryo domain by adding all
% absolute velocities of each cell in the corresponding location in the
% image domain over the whole recorded time interval and normalizing those 
% by the number of recorded time frames for this cell
% finally we normalize again by deviding the summed up velocities by the
% number of recorded cells for this experiment


% as a first step we just add all cell coordinates for each of the recorded
% cell and its corresponding time frames
maxNumberOfTimeframes = 20;
numberOfCells = numel(tracks_PGC);
cellCoordinates = zeros(3,numberOfCells * maxNumberOfTimeframes);
cellVelocities = zeros(1,numberOfCells * maxNumberOfTimeframes);

nextColumnIndexToInsert=0;
for trackedCellNo = 1:numberOfCells
    cellsFrames = tracks_PGC{trackedCellNo, 1};
    numberOfTrackedFrames = size(cellsFrames,1);
%     cellCoordinates(:,nextColumnIndexToInsert+1:nextColumnIndexToInsert...
%         +numberOfTrackedFrames) = [round(scale*cellsFrames(:,2:3)); round(cellsFrames(:,4), -1)]';
    cellCoordinates(:,nextColumnIndexToInsert+1:nextColumnIndexToInsert...
        +numberOfTrackedFrames) = (cellsFrames(:,2:4) ./ repmat(resolution,size(cellsFrames,1),1))';
    cellVelocities(1,nextColumnIndexToInsert+1:nextColumnIndexToInsert...
        +numberOfTrackedFrames) = vecnorm(cellsFrames(:,9:11) - cellsFrames(:, 12:14), 2, 2); 
    nextColumnIndexToInsert = nextColumnIndexToInsert + numberOfTrackedFrames;
end

cellCoordinates( :, all(~cellCoordinates,1) ) = [];
cellVelocities( :, all(~cellVelocities,1) ) = [];
%cellCoordinates=cellCoordinates(:,1:nextColumnIndexToInsert);
% for trackedCellNo = 1:numberOfCells
%     cellsFrames = tracks_PGC{trackedCellNo, 1};
%     numberOfTrackedFrames = size(cellsFrames,1);
%     for timeframe= 1:numberOfTrackedFrames
%         fprintf('##############  timeframe %d of cell %d\n', timeframe, trackedCellNo);
%     end
%     
% end
disp('###################################');
end