function [transformedData, transformedResolution] = transformVoxelData(processedData, resolution, transformationMatrix, ellipsoid_center, samples, interpolationMethod)
%TRANSFORMVOXELDATA Summary of this function goes here
%   Detailed explanation goes here

% set a tolerance paamameter (since the ellipsoid is not perfect
tolerance = 0.2;

% generate meshgrid for the original data space
[ X, Y, Z ] = ...
    meshgrid( linspace(0, resolution(2) * size(processedData,2), size(processedData,2) ), ...
              linspace(0, resolution(1) * size(processedData,1), size(processedData,1) ), ...
              linspace(0, resolution(3) * size(processedData,3), size(processedData,3) ) );

% generate meshgrid for unit cube
[ X_cube, Y_cube, Z_cube ] = ...
    meshgrid( linspace(-1-tolerance, 1+tolerance, samples ), ...
              linspace(-1-tolerance, 1+tolerance, samples ), ...
              linspace(-1-tolerance, 1+tolerance, samples ) );

 % initialize warped coordinates as unit cube coordinates
 warpedCoordinates = [X_cube(:), Y_cube(:), Z_cube(:)];
  
 % apply inverse of transformation matrix to unit cube coordinates
 warpedCoordinates = transformationMatrix * warpedCoordinates';
 
 % translate transformed unit cube coordinates to center of ellipsoid
 warpedCoordinates = warpedCoordinates + repmat(ellipsoid_center, 1, numel(X_cube(:)));
 
 % transform data
 transformedData = interp3(X, Y, Z, processedData, ...
     reshape(warpedCoordinates(1,:), size(X_cube)), ...
     reshape(warpedCoordinates(2,:), size(Y_cube)), ...
     reshape(warpedCoordinates(3,:), size(Z_cube)), interpolationMethod);
 transformedData(isnan(transformedData)) = 0;
           
 % calculate new resolution
 transformedResolution = (2 + 2*tolerance) / samples * [1, 1, 1];
          
end

