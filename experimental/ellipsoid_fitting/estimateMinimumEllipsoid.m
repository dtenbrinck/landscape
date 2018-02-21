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
% * center    -  ellispoid center coordinates [x_0; y_0; z_0]
% * radii     -  ellipsoid or other conic radii [a; b; c]
% * evecs     -  the radii directions as columns of the 3x3 matrix
% * v         -  the 10 parameters describing the ellipsoid algebraically: 
%         Ax^2 + By^2 + Cz^2 + 2Dxy + 2Exz + 2Fyz + 2Gx + 2Hy + 2Iz + J = 0
%   v_1     = A
%   v_2     = B
%   v_3     = C
%   v_4     = D
%   v_5     = E
%   v_6     = F
%   v_7     = G
%   v_8     = H
%   v_9     = I
%   v_10    = J
%
% Solving Minimization Problem to find smallest ellipsoid fitting when
% only allowing few data points to lie outside. 
% Find minimizer v of the following energy functional f:
% 
%   argmin f(v) = sum of all data rows in x ( max(0, < v, w > ) ) 
%                                           + volumetricPart(v)
%
% TODO volumetricPart(v)
%
% with w = (x^2, y^2, z^2, 2*x*y, 2*x*z, 2*y*z, 2*x, 2*y, 2*z, 1)
% and v initially derived from the implicit function describing 
% an arbitrarily oriented ellipsoid centered at center = (x_0; y_0; z_0)
%
%   ( (x;y;z)-(x_0; y_0; z_0) )' * M * ( (x;y;z)-(x_0; y_0; z_0) ) - 1 = 0
%
%   oE M=M', M has to be pos. def. (TODO check eigenvalues later)
%   v_1 = m_11
%
% Author:
% Ramona Sasse
% Date:
% February, 2018
%
    
if size( X, 2 ) ~= 3
    error( 'Input data must have three columns!' );
else
    x = X( :, 1 );
    y = X( :, 2 );
    z = X( :, 3 );
end

% need nine or more data points
if length( x ) < 9  
   error( 'Must have at least 10 points to fit a unique ellipsoid' );
end

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

end

