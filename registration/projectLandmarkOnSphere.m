function [ sphereCoordinates, landmarkCoordinates, landmarkOnSphere ] = projectLandmarkOnSphere(landmark,resolution,ellipsoid,samples)
%PROJECTIONONSPHERE:  This function will project the segmentation of the
%landmark onto the sphere and the cells into the unit ball
%% Input:
%   output:    	struct that contains all the segmentation data
%   samples:    sampling of the space
%   resolution: resolution of the original space
%% Output:
%   output:     same struct as before but contains two new values:
%               .regData:       These are the coordinates of the
%                segmentation on the sphere.
%               .centCoords:    These are the coordinates of the cells.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Main Code:

% % Sampling sphere
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


% Projection: %
%fprintf('Projection onto the unit sphere...');

landmarkOnSphere = zeros(size(alpha));
ellipsoid_tmp = ellipsoid;

% Transform unit sphere...

for tolerance = 0.8:0.01:1.2 
    
    ellipsoid_tmp.radii = ellipsoid.radii * tolerance;
    
    transformationMatrix = computeTransformationMatrix(ellipsoid_tmp);
    
    %[Xs_t,Ys_t,Zs_t] ...
       %= transformUnitSphere3D(Xs,Ys,Zs,transformation_matrix,ellipsoid.center);
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

% visualize projection on unit sphere
%visualizeProjectedLandmark(sphereCoordinates, landmarkOnSphere);

% compute coordinates of landmark on sphere
landmark_indices = find(landmarkOnSphere == 1);
landmarkCoordinates = [sphereCoordinates(landmark_indices,1), sphereCoordinates(landmark_indices,2), sphereCoordinates(landmark_indices,3)];

% Computing the coordinates of the segmentation
%regData = [(round(Xs(landmarkOnSphere == 1 & Zs <= 0)*10^10)/10^10)';...
%    (round(Ys(landmarkOnSphere == 1 & Zs <= 0)*10^10)/10^10)';...
%    (round(Zs(landmarkOnSphere == 1 & Zs <= 0)*10^10)/10^10)'];

% Delete all multiple points
%regData = unique(output.regData','rows')';

%fprintf('Done!\n');


end

