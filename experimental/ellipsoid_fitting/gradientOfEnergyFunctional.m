%% gradient of energy functional for ellipsoid fitting
function g = gradientOfEnergyFunctional(v, x, y, z) 
g = [ gradf1(v, x, y, z); ...
    gradf2(v, x, y, z);...
    gradf3(v, x, y, z);...
    gradf4(v, x, y, z);...
    gradf5(v, x, y, z);...
    gradf6(v, x, y, z);...
    gradf7(v, x, y, z)];
end


%% First derivative of a smeared Heaviside function
function h = smearedHeaviside1stDerivative (x) 
eps = 1;%1e-12;
if ( abs(x) > eps ) 
    h = 0;
else
    h = 1/(2*eps) + 1/(2*eps) * cos(pi*x/eps);
end

end

%% components of gradient of energy function
function grad = gradf1(v, x, y, z)
grad = -2/3 * pi * (v(1)^(-3/2)) * 1/sqrt(v(2)) * 1/sqrt(v(3));
prefixFactor = (x.^2);
grad = grad + firstSummandInGradI( v, x, y, z, prefixFactor);
end

function grad = gradf2(v, x, y, z)
grad = -2/3 * pi * 1/sqrt(v(1)) * (v(2)^(-3/2)) * 1/sqrt(v(3));
prefixFactor = (y.^2);
grad = grad + firstSummandInGradI( v, x, y, z, prefixFactor);
end

function grad = gradf3(v, x, y, z)
grad = -2/3 * pi * 1/sqrt(v(1)) * 1/sqrt(v(2)) * (v(3)^(-3/2));
prefixFactor = (z.^2);
grad = grad + firstSummandInGradI( v, x, y, z, prefixFactor);
end

function grad = gradf4(v, x, y, z)
prefixFactor = (x);
grad = firstSummandInGradI( v, x, y, z, prefixFactor);
end

function grad = gradf5(v, x, y, z)
prefixFactor = (y);
grad = firstSummandInGradI( v, x, y, z, prefixFactor);
end

function grad = gradf6(v, x, y, z)
prefixFactor = (z);
grad = firstSummandInGradI( v, x, y, z, prefixFactor);
end

function grad = gradf7(v, x, y, z)
grad = 0;
for i=1:length(x)
    w=[x(i)^2; y(i)^2; z(i)^2; x(i); y(i); z(i); 1];
    grad = grad + smearedHeaviside1stDerivative(v*w);
end
end

function g = firstSummandInGradI( v, x, y, z, prefixFactor)
g = 0;
for i=1:length(x)
    w=[x(i)^2; y(i)^2; z(i)^2; x(i); y(i); z(i); 1];
    g = g + prefixFactor(i) * smearedHeaviside1stDerivative(v*w);
end
end
