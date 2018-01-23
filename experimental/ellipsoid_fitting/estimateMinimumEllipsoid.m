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
%                     rx = v_1^-0.5 
%                     ry = v_2^-0.5 
%                     rz = v_3^-0.5
% * axes      -  the radii directions as columns of the 3x3 matrix
% * v         -  the 7 parameters describing the ellipsoid algebraically: 
%                Ax^2 + By^2 + Cz^2 + Dx + Ey + Fz + G = 0
%
% Solving Minimization Problem to find smallest ellipsoid fitting leaving
% only few data points outside
%   sum(over all data points) H(< (v_1, ..., v_7) , (x^2, y^2, z^2, x, y, z, 1) >)
%           + 4/3 * pi * v_1^-0.5 * v_2^-0.5 * v_3^-0.5
%
%   first summand: smeared heaviside function of evaluated ellipsoid equation 
%                   in all data points; only includes distances of data 
%                   points outside of ellipsoid
%   second summand: volume of ellipsoid
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


% fit ellipsoid in the form Ax^2 + By^2 + Cz^2 + 2Dxy + 2Exz + 2Fyz + 2Gx +
% 2Hy + 2Iz + J = 0 and A + B + C = 3 constraint removing one extra
% parameter

%     D = [ x .* x + y .* y - 2 * z .* z, ...
%         x .* x + z .* z - 2 * y .* y, ...
%         2 * x .* y, ...
%         2 * x .* z, ...
%         2 * y .* z, ...
%         2 * x, ...
%         2 * y, ...
%         2 * z, ...
%         1 + 0 * x ];  % ndatapoints x 9 ellipsoid parameters


% solve the normal system of equations
d2 = x .* x + y .* y + z .* z; % the RHS of the llsq problem (y's)
u = ( D' * D ) \ ( D' * d2 );  % solution to the normal equations

% find the residual sum of errors
% chi2 = sum( ( 1 - ( D * u ) ./ d2 ).^2 ); % this chi2 is in the coordinate frame in which the ellipsoid is a unit sphere.

% find the ellipsoid parameters
% convert back to the conventional algebraic form
if strcmp( equals, '' )
    v(1) = u(1) +     u(2) - 1;
    v(2) = u(1) - 2 * u(2) - 1;
    v(3) = u(2) - 2 * u(1) - 1;
    v( 4 : 10 ) = u( 3 : 9 );
elseif strcmp( equals, 'xy' )
    v(1) = u(1) - 1;
    v(2) = u(1) - 1;
    v(3) = -2 * u(1) - 1;
    v( 4 : 10 ) = u( 2 : 8 );
elseif strcmp( equals, 'xz' )
    v(1) = u(1) - 1;
    v(2) = -2 * u(1) - 1;
    v(3) = u(1) - 1;
    v( 4 : 10 ) = u( 2 : 8 );
elseif strcmp( equals, '0' )
    v(1) = u(1) +     u(2) - 1;
    v(2) = u(1) - 2 * u(2) - 1;
    v(3) = u(2) - 2 * u(1) - 1;
    v = [ v(1) v(2) v(3) 0 0 0 u( 3 : 6 )' ];
elseif strcmp( equals, '0xy' )
    v(1) = u(1) - 1;
    v(2) = u(1) - 1;
    v(3) = -2 * u(1) - 1;
    v = [ v(1) v(2) v(3) 0 0 0 u( 2 : 5 )' ];
elseif strcmp( equals, '0xz' )
    v(1) = u(1) - 1;
    v(2) = -2 * u(1) - 1;
    v(3) = u(1) - 1;
    v = [ v(1) v(2) v(3) 0 0 0 u( 2 : 5 )' ];
elseif strcmp( equals, 'xyz' )
    v = [ -1 -1 -1 0 0 0 u( 1 : 4 )' ];
end
v = v';

% form the algebraic form of the ellipsoid
A = [ v(1) v(4) v(5) v(7); ...
      v(4) v(2) v(6) v(8); ...
      v(5) v(6) v(3) v(9); ...
      v(7) v(8) v(9) v(10) ];
% find the center of the ellipsoid
center = -A( 1:3, 1:3 ) \ v( 7:9 );
% form the corresponding translation matrix
T = eye( 4 );
T( 4, 1:3 ) = center';
% translate to the center
R = T * A * T';
% solve the eigenproblem
[ evecs, evals ] = eig( R( 1:3, 1:3 ) / -R( 4, 4 ) );
radii = sqrt( 1 ./ diag( abs( evals ) ) );
sgns = sign( diag( evals ) );
radii = radii .* sgns;

% calculate difference of the fitted points from the actual data normalized by the conic radii
d = [ x - center(1), y - center(2), z - center(3) ]; % shift data to origin
d = d * evecs; % rotate to cardinal axes of the conic;
d = [ d(:,1) / radii(1), d(:,2) / radii(2), d(:,3) / radii(3) ]; % normalize to the conic radii
chi2 = sum( abs( 1 - sum( d.^2 .* repmat( sgns', size( d, 1 ), 1 ), 2 ) ) );

if abs( v(end) ) > 1e-6
    v = -v / v(end); % normalize to the more conventional form with constant term = -1
else
    v = -sign( v(end) ) * v;
end




