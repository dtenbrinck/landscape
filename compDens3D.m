function [ densMat ] = compDens3D(sizeGrid, points, sizeNH, typeNH)
%COMPDENS3D: Computes the 3D denisity of the points. Therefore we use a
% neighbourhood of size sizeNH around the points. It also can be done with a
% cube or a spherical neighbourhood.
%% Input:
% sizeGrid: a 3D vector that stores the size of the grid.
% points:   3D points in space.
% sizeNH:   a value. Gives the size of the neighbourhood.
% typeNH:   string. Type of the neighbourhood: 'cube', 'sphere'
%           size cube:      sizeNHsizeNHxsizeNH
%           size sphere:    sizeNH is the diameter. radius = sizeNH/2
%% Output:
% densMat:  density  map. The higher the value the higher the density
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Main Code

if size(sizeGrid,2) == 1
    sizeGrid = sizeGrid*ones(1,3);
end

% Transform coordinates from the axis space to the image space
sizeGrid(1:2) = fliplr(sizeGrid(1:2));
points(1:2) = fliplr(points(1:2));

% Compute 3D matrix for the points. Value gives number of points at that
% coordinate.
coordMat = zeros(sizeGrid);

% Fucking workaround
points(points<=0) = 1;
indPoints = sub2ind(sizeGrid,points(1,:),points(2,:),points(3,:));

% Find out how many points are on the same gridpoint
[uniquePoints,ai,~] = unique(indPoints,'stable');

% Values give number of points on that gridpoint
coordMat(uniquePoints) = 1;

if numel(uniquePoints) < numel(indPoints);
    indPoints(ai)=[];
    l = numel(indPoints);
    while l > 0
        [uniquePoints,ai,~] = unique(indPoints,'stable');
        coordMat(uniquePoints) = coordMat(uniquePoints)+1;
        indPoints(ai) = [];
        l = numel(indPoints);
    end
end

if strcmp(typeNH,'cube');
    NHMat = ones(sizeNH,sizeNH,sizeNH);
    densMat = convn(coordMat,NHMat,'same');
elseif strcmp(typeNH,'gaussian')
    densMat = imgaussfilt3(coordMat, sizeNH);
elseif strcmp(typeNH,'sphere')
    % Size of ball matrix should be odd.
    if mod(sizeNH,2) == 0
        sizeGrid = sizeNH+1;
        radius = sizeNH/2;
    else
        sizeGrid = sizeNH;
        radius = (sizeNH-1)/2;
    end
    [xx,yy,zz] = meshgrid(1:sizeGrid,1:sizeGrid,1:sizeGrid);
    NHMat = ...
        (sqrt((xx-radius-1).^2+(yy-radius-1).^2+(zz-radius-1).^2))<=radius;
    densMat = convn(coordMat,NHMat,'same');
end


end

