function [ output ] = ProjectionOnSphere(output,samples,resolution)
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

% Sampling sphere
[alpha, beta] = meshgrid(linspace(pi,2*pi,samples/2), linspace(0,2*pi,samples));
Zs = cos(alpha) .* sin(beta);
Xs = sin(alpha) .* sin(beta);
Ys = cos(beta);

% Sample the unit cube
[Xc, Yc, Zc] = meshgrid(linspace(-1,1,samples), linspace(-1,1,samples), linspace(-1,1,samples));

% Compute the transformed sphere and cube
output.tSphere = struct;
output.tCube = struct;

% Projection: %
fprintf('Projection onto the unit sphere...');
% Sample original space
mind = [0 0 0]; maxd = size(output.landmark) .* resolution;
%Create meshgrid with same resolution as data
[ X, Y, Z ] = meshgrid( linspace( mind(2), maxd(2), size(output.landmark,2) ),...
    linspace( mind(1), maxd(1), size(output.landmark,1) ),...
    linspace( mind(3), maxd(3), size(output.landmark,3) ) );

% Transform unit sphere...
scale_matrix = diag(1./output.ellipsoid.radii);
rotation_matrix = output.ellipsoid.axes';

GFPOnSphere = zeros(size(alpha));

for boundary = 0.80:0.01:1.2
    
    scale_matrix = diag(1./output.ellipsoid.radii) * boundary;
    
    [output.tSphere.Xs_t,output.tSphere.Ys_t,output.tSphere.Zs_t,output.ellipsoid.axes] ...
        = transformUnitSphere3D(Xs,Ys,Zs,scale_matrix,rotation_matrix,output.ellipsoid.center);
    
    % Project segmented landmark onto unit sphere...
    tmp ...
        = interp3(X, Y, Z, output.landmark, output.tSphere.Xs_t, output.tSphere.Ys_t, output.tSphere.Zs_t,'nearest');
    
    GFPOnSphere = max(output.GFPOnSphere, tmp);
end

% Computing the coordinates of the segmentation
output.regData = [(round(Xs(GFPOnSphere == 1 & Zs <= 0)*10^10)/10^10)';...
        (round(Ys(GFPOnSphere == 1 & Zs <= 0)*10^10)/10^10)';...
        (round(Zs(GFPOnSphere == 1 & Zs <= 0)*10^10)/10^10)'];
% Delete all multiple points
output.regData = unique(output.regData','rows')';
fprintf('Done!\n');

% ... and cube
fprintf('Projection of the cells...');
[output.tCube.Xc_t,output.tCube.Yc_t,output.tCube.Zc_t] ...
    = transformUnitCube3D(Xc,Yc,Zc,scale_matrix,rotation_matrix,output.ellipsoid.center);

% ... and cells into unit cube
CellsInSphere ...
    = interp3(X, Y, Z, output.cells, output.tCube.Xc_t, output.tCube.Yc_t, output.tCube.Zc_t,'nearest');
CellsInSphere(isnan(CellsInSphere)) = 0;

% Compute the coordinates of the centroids of the cells
CC = bwconncomp(CellsInSphere);
rp = regionprops(CC,'Centroid');
centCoords = reshape([rp(:).Centroid],3,[]);
output.centCoords = centCoords;

% Only take the centers that are really inside the ball with a toleranz
tol = 0.1;
normCoords = sqrt(centCoords(1,:).^2+centCoords(2,:).^2+centCoords(3,:).^2);


% Delete each point that is > 1+tol
centCoords(:,normCoords>1+tol) = [];
normCoords = sqrt(centCoords(1,:).^2+centCoords(2,:).^2+centCoords(3,:).^2);

% Normalize each point that is > 1 but <= 1+tol
centCoords(:,normCoords>1&normCoords<1+tol) = ...
centCoords(:,(normCoords>1&normCoords<1+tol))...
    .*1./repmat(normCoords(:,(normCoords>1&normCoords<1+tol)),[3,1]);

fprintf('Done!\n');

end

