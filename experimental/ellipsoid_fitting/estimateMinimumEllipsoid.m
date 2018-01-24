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

f1 = @(x,y) x.^2 + y.^2 - 6;
f2 = @(x,y) x.^3 - y.^2;
F = @(X) [f1(X(1), X(2)); f2(X(1), X(2))];

% Jacobimatrix DF = 2x2-Matrix-Funktion mit 2d-Argument
f1x = @(x,y) 2*x;
f1y = @(x,y) 2*y;
f2x = @(x,y) 3*x.^2;
f2y = @(x,y) -2*y;
DF = @(X) [f1x(X(1),X(2)), f1y(X(1),X(2));...
           f2x(X(1),X(2)), f2y(X(1),X(2))];

% arbitrary starting vector v:
% take mean values of x, y and z for initial center point of a unit sphere
% with radii equal to 1 and calculate values v=(v_1, ..., v_7) (row vector)
center = [mean(x); mean(y); mean(z)];
radii = ones(1,3);
v0(1:3) = 1./(radii.^2);
v0(4:6) = -2*center./(radii.^2);
v0(7) = sum ( (center.^2) ./ (radii.^2));

tol_rel = 1e-5;
v = newtonIteration( gradf, Jac, v0, tol_rel);

if ( v(1) <= 0 || v(2) <= 0 || v(3) <= 0 )
    error( 'Cannot compute radii of ellipsoid. Newton Iteration results in a negative value for 1/r_i^2 is negativ ' );
end

% calculate output params
radii = 1./sqrt(v(1:3));
center = -v(4:6) ./ (2*v(1:3));

end

%% First and second derivative of a smeared Heaviside function
function h = smearedHeaviside1stDerivative (x) 
eps = 1e-4;
if ( abs(x) > eps ) 
    h = 0;
else
    h = 1/(2*eps) + 1/(2*eps) * cos(pi*x/eps);
end

end

function h = smearedHeaviside2ndDerivative (x) 
eps = 1e-4;
if ( abs(x) > eps ) 
    h = 0;
else
    h = -pi/(2*eps*eps) * sin(pi*x/eps);
end

end

%% components of gradient of energy function
function grad = gradf1(v, x, y, z)
grad = -2/3 * pi * (v(1)^(-3/2)) * 1/sqrt(v(2)) * 1/sqrt(v(3));
for i=1:length(x)
    w=[x(i)^2; y(i)^2; z(i)^2; x(i); y(i); z(i); 1];
    grad = grad + x(i)^2 * smearedHeaviside1stDerivative(v*w);
end
end

function grad = gradf2(v, x, y, z)
grad = -2/3 * pi * 1/sqrt(v(1)) * (v(2)^(-3/2)) * 1/sqrt(v(3));
for i=1:length(x)
    w=[x(i)^2; y(i)^2; z(i)^2; x(i); y(i); z(i); 1];
    grad = grad + y(i)^2 * smearedHeaviside1stDerivative(v*w);
end
end

function grad = gradf3(v, x, y, z)
grad = -2/3 * pi * 1/sqrt(v(1)) * 1/sqrt(v(2)) * (v(3)^(-3/2));
for i=1:length(x)
    w=[x(i)^2; y(i)^2; z(i)^2; x(i); y(i); z(i); 1];
    grad = grad + z(i)^2 * smearedHeaviside1stDerivative(v*w);
end
end

function grad = gradf4(v, x, y, z)
grad = 0;
for i=1:length(x)
    w=[x(i)^2; y(i)^2; z(i)^2; x(i); y(i); z(i); 1];
    grad = grad + x(i) * smearedHeaviside1stDerivative(v*w);
end
end

function grad = gradf5(v, x, y, z)
grad = 0;
for i=1:length(x)
    w=[x(i)^2; y(i)^2; z(i)^2; x(i); y(i); z(i); 1];
    grad = grad + y(i) * smearedHeaviside1stDerivative(v*w);
end
end

function grad = gradf6(v, x, y, z)
grad = 0;
for i=1:length(x)
    w=[x(i)^2; y(i)^2; z(i)^2; x(i); y(i); z(i); 1];
    grad = grad + z(i) * smearedHeaviside1stDerivative(v*w);
end
end

function grad = gradf7(v, x, y, z)
grad = 0;
for i=1:length(x)
    w=[x(i)^2; y(i)^2; z(i)^2; x(i); y(i); z(i); 1];
    grad = grad + smearedHeaviside1stDerivative(v*w);
end
end

%% components of Hessian matrix of energy functional
% (Satz von Schwarz: df/dxdy = df/dydx)
% first components influenced by volumetric part
function h = hesse11( v, x, y, z)
h = pi * (v(1)^(-5/2)) * (v(2)^(-1/2)) * (v(3)^(-1/2));
prefixFactor = (x.^4);
h = h + firstSummandInHesseIJ( v, x, y, z, prefixFactor);
end

function h = hesse22( v, x, y, z)
h = pi * (v(1)^(-1/2)) * (v(2)^(-5/2)) * (v(3)^(-1/2));
prefixFactor = (y.^4);
h = h + firstSummandInHesseIJ( v, x, y, z, prefixFactor);
end

function h = hesse33( v, x, y, z)
h = pi * (v(1)^(-1/2)) * (v(2)^(-1/2)) * (v(3)^(-5/2));
prefixFactor = (z.^4);
h = h + firstSummandInHesseIJ( v, x, y, z, prefixFactor);
end

function h = hesse12( v, x, y, z)
h = 1/3 * pi * (v(1)^(-3/2)) * (v(2)^(-3/2)) * (v(3)^(-1/2));
prefixFactor = (x.^2).*(y.^2);
h = h + firstSummandInHesseIJ( v, x, y, z, prefixFactor);
end

function h = hesse13( v, x, y, z)
h = 1/3 * pi * (v(1)^(-3/2)) * (v(2)^(-1/2)) * (v(3)^(-3/2));
prefixFactor = (x.^2).*(z.^2);
h = h + firstSummandInHesseIJ( v, x, y, z, prefixFactor);
end

function h = hesse23( v, x, y, z)
h = 1/3 * pi * (v(1)^(-1/2)) * (v(2)^(-3/2)) * (v(3)^(-3/2));
prefixFactor = (y.^2).*(z.^2);
h = h + firstSummandInHesseIJ( v, x, y, z, prefixFactor);
end

% components without influence of volumetric part
% missing derivatives with 1st coordinate
function h = hesse14( v, x, y, z)
prefixFactor = (x.^3);
h = firstSummandInHesseIJ( v, x, y, z, prefixFactor);
end

function h = hesse15( v, x, y, z)
prefixFactor = (x.^2).*(y);
h = firstSummandInHesseIJ( v, x, y, z, prefixFactor);
end

function h = hesse16( v, x, y, z)
prefixFactor = (x.^2).*(z);
h = firstSummandInHesseIJ( v, x, y, z, prefixFactor);
end

function h = hesse17( v, x, y, z)
prefixFactor = (x.^2);
h = firstSummandInHesseIJ( v, x, y, z, prefixFactor);
end

% missing derivatives with 2nd coordinate
function h = hesse24( v, x, y, z)
prefixFactor = (y.^2).*(x);
h = firstSummandInHesseIJ( v, x, y, z, prefixFactor);
end

function h = hesse25( v, x, y, z)
prefixFactor = (y.^3);
h = firstSummandInHesseIJ( v, x, y, z, prefixFactor);
end

function h = hesse26( v, x, y, z)
prefixFactor = (y.^2).*(z);
h = firstSummandInHesseIJ( v, x, y, z, prefixFactor);
end

function h = hesse27( v, x, y, z)
prefixFactor = (y.^2);
h = firstSummandInHesseIJ( v, x, y, z, prefixFactor);
end

% missing derivatives with 3rd coordinate
function h = hesse34( v, x, y, z)
prefixFactor = (z.^2).*(x);
h = firstSummandInHesseIJ( v, x, y, z, prefixFactor);
end

function h = hesse35( v, x, y, z)
prefixFactor = (z.^2).*(y);
h = firstSummandInHesseIJ( v, x, y, z, prefixFactor);
end

function h = hesse36( v, x, y, z)
prefixFactor = (z.^3);
h = firstSummandInHesseIJ( v, x, y, z, prefixFactor);
end

function h = hesse37( v, x, y, z)
prefixFactor = (z.^2);
h = firstSummandInHesseIJ( v, x, y, z, prefixFactor);
end
 %%%%%%%%TODO 4th-7th derivates not ready!!%%%%%%%%%%
% missing derivatives with 4th coordinate
function h = hesse44( v, x, y, z)
prefixFactor = (x.^2);
h = firstSummandInHesseIJ( v, x, y, z, prefixFactor);
end

function h = hesse45( v, x, y, z)
prefixFactor = (x).*(y);
h = firstSummandInHesseIJ( v, x, y, z, prefixFactor);
end

function h = hesse46( v, x, y, z)
prefixFactor = (x).*(z);
h = firstSummandInHesseIJ( v, x, y, z, prefixFactor);
end

function h = hesse47( v, x, y, z)
prefixFactor = (x);
h = firstSummandInHesseIJ( v, x, y, z, prefixFactor);
end

% missing derivatives with 5th coordinate
function h = hesse55( v, x, y, z)
prefixFactor = (y.^2);
h = firstSummandInHesseIJ( v, x, y, z, prefixFactor);
end

function h = hesse56( v, x, y, z)
prefixFactor = (y).*(z);
h = firstSummandInHesseIJ( v, x, y, z, prefixFactor);
end

function h = hesse57( v, x, y, z)
prefixFactor = (y);
h = firstSummandInHesseIJ( v, x, y, z, prefixFactor);
end

% missing derivatives with 6th coordinate
function h = hesse66( v, x, y, z)
prefixFactor = (z.^2);
h = firstSummandInHesseIJ( v, x, y, z, prefixFactor);
end

function h = hesse67( v, x, y, z)
prefixFactor = (z);
h = firstSummandInHesseIJ( v, x, y, z, prefixFactor);
end

% missing derivatives with 7th coordinate
function h = hesse77( v, x, y, z)
h = 0;
for i=1:length(x)
    w=[x(i)^2; y(i)^2; z(i)^2; x(i); y(i); z(i); 1];
    h = h + smearedHeaviside2ndDerivative(v*w);
end
end


function h = firstSummandInHesseIJ( v, x, y, z, prefixFactor)
h = 0;
for i=1:length(x)
    w=[x(i)^2; y(i)^2; z(i)^2; x(i); y(i); z(i); 1];
    h = h + prefixFactor(i) * smearedHeaviside2ndDerivative(v*w);
end
end
