%% estimate minimal ellipsoid fitting for data set
function [ center, radii, evecs, v ] = estimateMinimumEllipsoid2( X )
%
% Fit an ellispoid/sphere to a set of xyz data points:
%
%   [center, radii, evecs, v ] = estimateMinimumEllipsoid( X )
%   [center, radii, evecs, v ] = estimateMinimumEllipsoid( [x y z] );
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
%
% Solving Minimization Problem to find smallest ellipsoid fitting when
% only allowing few data points to lie outside. 
% Find minimizer v of the following energy functional f:
% 
%   argmin f(v) = alpha * energyPart(v) + beta * volumetricPart(v)
%
%   with:   volumetricPart(v) = 1 / ( v_1 + v_2 + v_3 )
%           energyPart(v) = sum of all data rows in X ( max(0, < v, w > ) )
%            = sum of all data rows in X (log(exp(0) + exp( < v, w > )) )
%            = sum of all data rows in X (log( 1 + exp( < v, w > )) )
%            = sum of all data rows in X (S + log( exp(-S) + exp( < v, w > - S )) )
%           with S = max<v,w> as a shift to prevent overflow
%
% with w = (x^2, y^2, z^2, 2*x*y, 2*x*z, 2*y*z, 2*x, 2*y, 2*z, 1)
% and v initially derived from the implicit function describing 
% an arbitrarily oriented ellipsoid centered at center = (x_0; y_0; z_0)
%
%   [ (x;y;z)-(x_0; y_0; z_0) ]' * M * [ (x;y;z)-(x_0; y_0; z_0) ] - 1 = 0
%
%   oE M=M', M has to be pos. def. (TODO check eigenvalues later)
%   v_1     = A     = m_11
%   v_2     = B     = m_22
%   v_3     = C     = m_33
%
%   v_4     = D     = m_12 = m_21
%   v_5     = E     = m_13 = m_31
%   v_6     = F     = m_23 = m_32
%
%   v_7     = G     = - ( m_11 * x_0 + m_12 * y_0 + m_13 * z_0 )
%   v_8     = H     = - ( m_21 * x_0 + m_22 * y_0 + m_23 * z_0 )
%   v_9     = I     = - ( m_31 * x_0 + m_32 * y_0 + m_33 * z_0 )
%   v_10    = J     = m_11 * x_0^2 + m_22 * y_0^2 + m_33 * z_0^2
%                       + 2 * m_12 * x_0 * y_0  
%                       + 2 * m_13 * x_0 * z_0 
%                       + 2 * m_23 * y_0 * z_0 - 1
%
% We observe that: V(1:3,1:3) = M(1:3,1:3)
%
%   Determine output parameter:
% * center:   [ v_1 v_4 v_5    [x_0             [ v_7
%               v_4 v_2 v_6  *  y_0   = (-1) *    v_8
%               v_5 v_6 v_3 ]   z_0]              v_9 ]
% Author:
% Ramona Sasse
% Date:
% February, 2018
%

% initialze weights for energy part and volumetric penalty part
alpha = 1; beta = 1;

if size( X, 2 ) ~= 3
    error( 'Input data must have three columns!' );
else
    x = X( :, 1 );
    y = X( :, 2 );
    z = X( :, 3 );
end

% need 10 or more data points
if length( x ) < 10 
   error( 'Must have at least 10 points to approximate an ellipsoidal fitting.' );
end

W = [ x .* x ...
    y .* y ...
    z .* z, ...
    2 * x .* y, ...
    2 * x .* z, ...
    2 * y .* z, ...
    2 * x, ...
    2 * y, ...
    2 * z, ...
    1 + 0 * x ];  % ndatapoints x 10 ellipsoid parameters

% initialize v
center=[mean(x); mean(y); mean(z)];
radii=[max(abs(x - center(1))); max(abs(y - center(2)));max(abs(z - center(3)))]; 

v=zeros(10,1);
v(1:3) = (1./radii).^2;
v(7:9) = - v(1:3) .* center;
v(10) = v(1:3) .* (center.^2) - 1;

shift = max(W*v);
energyPart = sum(shift + log(exp(-shift)+exp(W*v - S)));
volumetricPart = 1/(v(1) + v(2) + v(3));
functional = alpha * energyPart + beta * volumetricPart;

% form the algebraic form of the ellipsoid
V = [ v(1) v(4) v(5) v(7); ...
      v(4) v(2) v(6) v(8); ...
      v(5) v(6) v(3) v(9); ...
      v(7) v(8) v(9) v(10) ];
% find the center of the ellipsoid
center = -V( 1:3, 1:3 ) \ v( 7:9 );
% form the corresponding translation matrix
T = eye( 4 );
T( 1:3, 4 ) = center;
% translate the center to the origin: vec2 = T * vec1
% [ (x;y;z)-(x_0; y_0; z_0) ]' * M * [ (x;y;z)-(x_0; y_0; z_0) ] 
% [T * [ (x;y;z;1)-(x_0; y_0; z_0; 1) ] ]' * V * [ T * [ (x;y;z;1)-(x_0; y_0; z_0; 1) ] ] 
% (x;y;z;1)' * T' * V * T * (x;y;z;1) 
R = T' * V * T;
% solve the eigenproblem after rescaling R as we only need the 3x3 part
[ evecs, evals ] = eig( R( 1:3, 1:3 ) / -R( 4, 4 ) );
% check that eigenvalues are positiv as required for a M to be pos. def.
% with M as the 3x3 scaled and translated part of V
for index=1:length(evals)
   if evals(index,index) <= 0
       error ('Cannot estimate ellipsoidal fitting (negative eigen values)!');
   end
end
radii = sqrt( 1 ./ diag( evals) ) ;

if abs( v(end) ) > 1e-6
    v = -v / v(end); % normalize to the more conventional form with constant term = -1
else
    v = -sign( v(end) ) * v;
end

end
