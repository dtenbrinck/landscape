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
%  f (v = v_1, ..., v_7) = sum(over all data points) H(< (v_1, ..., v_7) , (x^2, y^2, z^2, x, y, z, 1) >)
%           + 4/3 * pi * 1/sqrt(v_1) * 1/sqrt(v_2) * 1/sqrt(v_3)
%
%       first summand: smeared heaviside function of evaluated ellipsoid 
%           equation in all data points; only includes distances of data 
%                       points outside of ellipsoid
%       second summand: volume of ellipsoid
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

% need 7?! or more data points
if length( x ) < 7
   error( 'Must have at least 7 points to fit a unique ellipsoid' );
end

% to find minimizer of energy functional solve the optimality condition
% grad(f(v)) = 0 with newton iteration

% arbitrary starting vector v0 resulting from unit sphere with radii = 1 
% and center point in mean values of x, y and z 

center = [mean(x); mean(y); mean(z)];
radii = ones(3,1);
v0(1:3) = 1./(radii.^2);
v0(4:6) = -2*center./(radii.^2);
v0(7) = sum ( (center.^2) ./ (radii.^2));

tol_rel = 1e-5;
v = v0;
error_rel = realmax;

while error_rel > tol_rel
    H = hessianOfEnergyFunctional(v, x, y, z);
    g = gradientOfEnergyFunctional(v, x, y, z);
    delta_v = H \g;
    error_rel = norm(delta_v) / norm(v);
    v = v + delta_v';
end

if ( v(1) <= 0 || v(2) <= 0 || v(3) <= 0 )
    error( 'Cannot compute radii of ellipsoid. Newton Iteration results in a negative value for 1/r_i^2 is negativ ' );
end

% calculate output params
radii = 1./sqrt(v(1:3));
center = -v(4:6) ./ (2*v(1:3));

end

