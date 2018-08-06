function [ accumulatorPosition, accumulatorSpeed, accumulatorStraightness, numberCells, numberExperiments ] = computeAccumulatorDynamic( results, gridSize )
%This function computes the accumulator for the heatmap 

%% MAIN CODE

% extract all PGC coordinates
numberExperiments = size(results,2);

% WARNING: No preallocation!
PGC_Coordinates = zeros(3,0);
PGC_Velocities = zeros(3,0);
PGC_TrackStraightness = zeros(1,0);
for experiment=1:numberExperiments
    numberPGCs = size(results{experiment}.PGC_information,2);
    for cell=1:numberPGCs
        PGC_Coordinates = cat(2, PGC_Coordinates, results{experiment}.PGC_information(cell).registeredPositions);
        PGC_Velocities = cat(2, PGC_Velocities, results{experiment}.PGC_information(cell).net_velocity);
        
        % compute track straightness based on angle of consecutive tracks
        previousTracks = results{experiment}.PGC_information(cell).net_velocity(:,1:end-1);
        nextTracks = results{experiment}.PGC_information(cell).net_velocity(:,2:end);
        trackStraightness = diag(previousTracks' * nextTracks)' ./ (sqrt(sum(previousTracks.^2,1)) .* sqrt(sum(nextTracks.^2,1)));
        PGC_TrackStraightness = cat(2, PGC_TrackStraightness, [0, trackStraightness]);
    end
end

% Compute norm of each column
normOfCoordinates = sqrt(sum(PGC_Coordinates.^2,1));

tolerance = 0.1;
% Ignore all coordinates outside the sphere with a tolerance tole
PGC_Coordinates(:,normOfCoordinates > 1+tolerance) = [];
PGC_Velocities(:,normOfCoordinates > 1+tolerance) = [];
PGC_TrackStraightness(:,normOfCoordinates > 1+tolerance) = [];
normOfCoordinates(:,normOfCoordinates > 1+tolerance) = [];

numberCells = size(PGC_Coordinates,2);

% Get rounded cell center coordinates
PGC_Coordinates = round(...
    (PGC_Coordinates + repmat([1;1;1], 1, size(PGC_Coordinates,2)))...
    * gridSize / 2 );

% TODO: Better solution needed here!
PGC_Coordinates(PGC_Coordinates<=0)=1;
PGC_Coordinates(PGC_Coordinates>gridSize)=gridSize;

% Rewrite the cell coordinates into linear indexing
indPoints = sub2ind([gridSize,gridSize,gridSize]...
    ,PGC_Coordinates(2,:),PGC_Coordinates(1,:),PGC_Coordinates(3,:));

accumulatorPosition = reshape(...
    accumarray([indPoints';gridSize*gridSize*gridSize],[ones(size(indPoints'));0]),...
    [gridSize,gridSize,gridSize]);


% compute accumulator measuring the speed of PGCs
values = [sqrt(sum(PGC_Velocities'.^2,2));0];
accumulatorSpeed = reshape(...
    accumarray([indPoints';gridSize*gridSize*gridSize],values),...
    [gridSize,gridSize,gridSize]);
accumulatorSpeed = accumulatorSpeed ./ accumulatorPosition;
%accumulatorSpeed(isnan(accumulatorSpeed)) = 0;

% compute accumulator measuring the track straightness of PGCs
values = [PGC_TrackStraightness'];
accumulatorStraightness = reshape(...
    accumarray([indPoints';gridSize*gridSize*gridSize],[values;0]),...
    [gridSize,gridSize,gridSize]);
accumulatorStraightness = accumulatorStraightness ./ accumulatorPosition;
%accumulatorStraightness(isnan(accumulatorStraightness)) = 0;

