%% hessian of energy functional for ellipsoid fitting
function H = hessianOfEnergyFunctional(v, x, y, z)
H_upper = [ hesse11(v, x, y, z), hesse12(v, x, y, z), hesse13(v, x, y, z), ...
    hesse14(v, x, y, z),  hesse15(v, x, y, z), hesse16(v, x, y, z), hesse17(v, x, y, z);...
    0 , hesse22(v, x, y, z), hesse23(v, x, y, z), ...
    hesse24(v, x, y, z),  hesse25(v, x, y, z), hesse26(v, x, y, z), hesse27(v, x, y, z);...
    0, 0, hesse33(v, x, y, z), ...
    hesse34(v, x, y, z),  hesse35(v, x, y, z), hesse36(v, x, y, z), hesse37(v, x, y, z);...
    0, 0, 0, ...
    hesse44(v, x, y, z),  hesse45(v, x, y, z), hesse46(v, x, y, z), hesse47(v, x, y, z);...
    0, 0, 0, ...
    0,  hesse55(v, x, y, z), hesse56(v, x, y, z), hesse57(v, x, y, z);...
    0, 0, 0, ...
    0, 0, hesse66(v, x, y, z), hesse67(v, x, y, z);...
    0, 0, 0, ...
    0, 0, 0, hesse77(v, x, y, z)];

H = H_upper + triu(H_upper, 1)';
end

%% Second derivative of a smeared Heaviside function
function h = smearedHeaviside2ndDerivative (x) 
eps = 100;%e-12;
if ( abs(x) > eps ) 
    h = 0;
else
    h = -pi/(2*eps*eps) * sin(pi*x/eps);
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