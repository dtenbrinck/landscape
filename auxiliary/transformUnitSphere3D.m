function [Xs_t,Ys_t,Zs_t,axes] = transformUnitSphere3D(Xs, Ys, Zs, scale_matrix, rotation_matrix, center)
%TRANSFORMUNITSPHERE This function transforms the unit sphere. Therefore it
%will be scaled with a scale_matrix, rotated with a rotation_matrix and
%will be set to the center center
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Input: 
% Xs, Ys, Zs:       The coordinates of the unit sphere. 
% scale_matrix:     Scales the unit sphere in the different directions.
% rotation_matrix:  Rotates the unit sphere in a certain direction.
% center:           Sets the unit sphere to a certain center. Default: 0
%% Output:
% Xs_t, Ys_t, Zs_t: Coordinates of the output elipsoid or sphere.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Main Code

% Get transformmatrix and take care of direction of axes.
sign = (-0.5+ (acos([1,0,0]*rotation_matrix(:,1)) < acos([-1,0,0]*rotation_matrix(:,1))))*2;
rotation_matrix(:,1) = sign*rotation_matrix(:,1);
sign = (-0.5+ (acos([0,1,0]*rotation_matrix(:,2)) < acos([0,-1,0]*rotation_matrix(:,2))))*2;
rotation_matrix(:,2) = sign*rotation_matrix(:,2);
transform = scale_matrix*rotation_matrix;
% Transform all coordinates of the unit sphere
X = transform^-1*[Xs(:),Ys(:),Zs(:)]';

% Set the output and reshape it.
Xs_t = reshape(X(1,:)+center(1),size(Xs));
Ys_t = reshape(X(2,:)+center(2),size(Ys));
Zs_t = reshape(X(3,:)+center(3),size(Zs));

axes = rotation_matrix';
end

