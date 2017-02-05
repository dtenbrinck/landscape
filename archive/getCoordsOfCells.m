function [ centCoords ] = getCoordsOfCells( cells, resolution, radii )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

% Compute the different connected 3D cells
CC = bwconncomp(cells);
% Get centroids of the cells
S = regionprops(CC,'centroid');
% Coordinates of the centers of the cells
centCoords = zeros(3,CC.NumObjects);
for i = 1:CC.NumObjects
    centCoords(:,i) = S(i).Centroid;
end
% Get the centercoords in the real space and scale it
centCoords(1,:) = centCoords(2,:)*resolution(1)/radii(1);
centCoords(2,:) = centCoords(1,:)*resolution(2)/radii(2);
centCoords(3,:) = centCoords(3,:)*resolution(3)/radii(3);




