function [Xc_t,Yc_t,Zc_t] = transformUnitSphere3D_old(Xc, Yc, Zc, scale_matrix, rotation_matrix, center)
%TRANSFORMUNITcube This function transforms the unit cube. Therefore it
%will be scaled with 'scale_matrix', rotated with 'rotation_matrix' and
%will be set to the center 'center'.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Input: 
% Xc, Yc, Zc:       The coordinates of the unit cube. 
% scale_matrix:     Scales the unit cube in the different directions.
% rotation_matrix:  Rotates the unit cube in a certain direction.
% center:           Sets the unit cube to a certain center. Default: 0
%% Output:
% Xc_t, Yc_t, Zc_t: Coordinates of the output elipsoid or cube.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Main Code

% Get transformmatrix
%transform = scale_matrix*rotation_matrix;
transform = scale_matrix;
% Transform all coordinates of the unit cube
X = transform^-1*[Xc(:),Yc(:),Zc(:)]';

% Set the output and reshape it.
Xc_t = reshape(X(1,:)+center(1),size(Xc));
Yc_t = reshape(X(2,:)+center(2),size(Yc));
Zc_t = reshape(X(3,:)+center(3),size(Zc));

end

