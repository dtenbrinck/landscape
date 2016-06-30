function [samCoordsG, samCoordsU] = fitOnSamSphere(coords, numOfGridPoints)
%FITONSAMSPHERE: This function samples coordinates onto a sampled N-D unit
%sphere. The range is [-1,1].
%% Input:
% coords:           Coordinates of points inside a N-D sphere. Interpreted
%                   as an NxnumOfCoords matrix.
% numOfGridPoints:  Number of GridPoints in the N directions. If it is just
%                   a value, it will be set for each direction.
%
%% Output: 
% samCoordsG:      sampled coordinates in the grid
% samCoordsU:       sampled coordinates in the unit sphere
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Initialization

N = size(coords,1);

if (size(numOfGridPoints,2) == 1) && (N > 1)
    numOfGridPoints = numOfGridPoints*ones(N,1);
end

%% Main Code

% Flip x and y because in the data it is fliped.
numOfGridPoints(1:2) = fliplr(numOfGridPoints(1:2));

% These coordinates are still in the axis space.
samCoordsG = (round((coords+1)'*(diag(numOfGridPoints-1)/2)));
samCoordsU = (samCoordsG/((diag(numOfGridPoints-1)/2))-1)';
samCoordsG = samCoordsG'+1;

end

