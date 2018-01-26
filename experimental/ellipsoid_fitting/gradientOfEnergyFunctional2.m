%% gradient of energy functional for ellipsoid fitting
function g = gradientOfEnergyFunctional(v, x, y, z, lambda, kappa) 
g = grad_constraints(v, lambda);

tmp_grad = zeros(1, length(v) + length(lambda);
end

%% components of gradient of volumetric part of energy function
function grad = grad_volumetric_1(v, mu1, mu2)
    grad = v(1)^-2 * 2 * ( mu_1 * ( 1/v(2) + 1/v(3) - 2/v(1) - mu_2));
end

function grad = grad_volumetric_2(v, mu1, mu2)
    grad = v(2)^-2 * 2 * ( mu_1 * ( 1/v(1) + 1/v(3) - 2/v(2) - mu_2));
end

function grad = grad_volumetric_3(v, mu1, mu2)
    grad = v(3)^-2 * 2 * ( mu_1 * ( 1/v(2) + 1/v(1) - 2/v(3) - mu_2));
end

function grad = grad_volumetric(v, mu1, mu2)
    grad = zeros(1, length(v));
    grad(1) = grad_volumetric_1(v, mu1, mu2);
    grad(2) = grad_volumetric_2(v, mu1, mu2);
    grad(3) = grad_volumetric_3(v, mu1, mu2);
end

%% components of gradient for constraints v_i > 0 with langrangian multiplier
function grad = grad_constraints(v, lambda)
    grad = zeros(1, length(v) + length(lambda));
    grad(1, 1:length(lambda)) = lambda; % TODO evtl. lambda'
    grad(1, length(v)+1:end) = v(1:length(lambda));
end

%% components of gradient for constraints based on algebraic ellipsoid equation
function grad = grad_ellipsoid_equation(x,y,z, kappa)
    grad
end