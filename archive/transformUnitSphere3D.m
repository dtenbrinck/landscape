function [Xs_t,Ys_t,Zs_t] = transformUnitSphere3D(Xs, Ys, Zs, scale_matrix, center)
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

% Transform matrix
transform = scale_matrix;
% Transform all coordinates of the unit sphere
X = transform^-1*[Xs(:),Ys(:),Zs(:)]';

% Set the output and reshape it.
Xs_t = reshape(X(1,:)+center(1),size(Xs));
Ys_t = reshape(X(2,:)+center(2),size(Ys));
Zs_t = reshape(X(3,:)+center(3),size(Zs));

end

