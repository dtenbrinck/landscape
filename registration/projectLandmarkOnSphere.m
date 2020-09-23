function [ sphereCoordinates, landmarkCoordinates, landmarkOnSphere ] = projectLandmarkOnSphere(landmark,resolution,ellipsoid,samples)
%PROJECTLANDMARKONSPHERE:  This function will project the segmentation of the
%landmark onto the unit sphere surface
%% Input:
%  landmark:    	dim1xdim2xdim3-matrix containing the 3d landmark
%                   segmentation based on voxel labeling
%  resolution:      1x3 vector containing the scaled resolution in [x,y,z]-direction
%  ellipsoid:       struct containing the information about the ellipsoid
%                   ellipsoid.center: 3x1 vector
%                   ellipsoid.radii: 3x1 vector
%                   ellipsoid.axes: 3x3 matrix
%  samples:         integer that defines the resolution of the unit sphere
%                   surface and the size of sphereCoordinates
%% Output:
%  sphereCoordinates:       samples^2 x 3 - matrix containing the
%                           3d-coordinates that represent the unit sphere
%                           surface
%  landmarkCoordinates:     nx3-matrix containing the 3d coordinates of the
%                           projected landmark
%  landmarkOnSphere:        2*samples x samples/2 - matrix containing the
%                           2d segmentation of the projected landmark
%                           based on voxel labeling 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Main Code:

% Sampling sphere
[alpha, beta] = meshgrid(linspace(pi,2*pi,samples/2), linspace(0,2*pi,2*samples));
Xs = sin(alpha) .* sin(beta);
Ys = cos(beta);
Zs = cos(alpha) .* sin(beta);

% save sphere coordinates as N x 3 matrix
sphereCoordinates = [Xs(:), Ys(:), Zs(:)];

% Sample original space by creating meshgrid with same resolution as data
mind = [0 0 0]; maxd = size(landmark) .* resolution;
[ X, Y, Z ] = meshgrid( linspace( mind(2), maxd(2), size(landmark,2) ),...
    linspace( mind(1), maxd(1), size(landmark,1) ),...
    linspace( mind(3), maxd(3), size(landmark,3) ) );

landmarkOnSphere = zeros(size(alpha));
ellipsoid_tmp = ellipsoid;

% Transform unit sphere...

for tolerance = 0:0.01:2 %old:0.8:0.01:1.6 %TODO: Was there a reason for the old values except for being faster?
    
    ellipsoid_tmp.radii = ellipsoid.radii * tolerance;
    
    transformationMatrix = computeTransformationMatrix(ellipsoid_tmp);
    
    transformedCoordinates = ...
        transformCoordinates(sphereCoordinates, [0; 0; 0], transformationMatrix, ellipsoid.center);
    
    % reshape coordinates to parameter space size
    X_sphere_transformed = reshape(transformedCoordinates(1,:), size(alpha));
    Y_sphere_transformed = reshape(transformedCoordinates(2,:), size(alpha));
    Z_sphere_transformed = reshape(transformedCoordinates(3,:), size(alpha));
    
    % Project segmented landmark onto unit sphere...
    tmp ...
        = interp3(X, Y, Z, landmark, X_sphere_transformed, Y_sphere_transformed, Z_sphere_transformed,'nearest');
    
    landmarkOnSphere = max(landmarkOnSphere, tmp);
end

% compute coordinates of landmark on sphere
landmark_indices = find(landmarkOnSphere == 1);
landmarkCoordinates = [sphereCoordinates(landmark_indices,1), sphereCoordinates(landmark_indices,2), sphereCoordinates(landmark_indices,3)];

end
