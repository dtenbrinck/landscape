%% estimate minimal ellipsoid fitting for data set
function [ center, radii, axes, v ] = estimateMinimumEllipsoid( X )
%
% Fit an ellispoid/sphere to a set of xyz data points:
%
%   [center, radii, axes, v ] = estimateMinimumEllipsoid( X )
%   [center, radii, axes, v ] = estimateMinimumEllipsoid( [x y z] );
%
% Parameters:
% * X, [x y z]   - Cartesian data, n x 3 matrix or three n x 1 vectors
%
% Output:
% * center    -  ellispoid center coordinates [xc; yc; zc]
%                     xc = - v_4 / ( 2 * v_1 )
%                     yc = - v_5 / ( 2 * v_2 )
%                     zc = - v_6 / ( 2 * v_3 )
% * radii     -  ellipsoid radii [rx; ry; rz]
%                     rx = 1/sqrt(v_1) 
%                     ry = 1/sqrt(v_2)
%                     rz = 1/sqrt(v_3)
% * axes      -  the radii directions as columns of the 3x3 matrix
% * v         -  the 7 parameters describing the ellipsoid algebraically: 
%                Ax^2 + By^2 + Cz^2 + Dx + Ey + Fz + G = 0
%
% Solving Minimization Problem to find smallest ellipsoid fitting leaving
% only few data points outside. 
% Find minimizer of the following energy functional f:
% TODO
%
% Author:
% Ramona Sasse
% Date:
% January, 2018
%
    
if size( X, 2 ) ~= 3
    error( 'Input data must have three columns!' );
else
    x = X( :, 1 );
    y = X( :, 2 );
    z = X( :, 3 );
end



end

