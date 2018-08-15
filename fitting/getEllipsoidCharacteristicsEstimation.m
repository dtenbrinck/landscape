%% estimate minimal ellipsoid fitting for data set
function [ center, radii, axis ] ...
    = getEllipsoidCharacteristicsEstimation...
    ( X, fittingParams)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Fit an ellispoid/sphere to a set of xyz data points:
%
%   [center, radii, evecs, v ] = estimateMinimumEllipsoid( X )
%   [center, radii, evecs, v ] = estimateMinimumEllipsoid( [x y z] );
%
% Parameters:
% * X, [x y z]      - Cartesian data, n x 3 matrix or three n x 1 vectors
% * ellipsoidFitting.descentMethod = 'cg' or 'grad';
% * fittingParams.regularisationParams:
%   mu1,mu2     - weights for volumetric terms
% 	gamma           - parameter for smooth approximation with logarithm of 
%                     kink in max(0,...) 
%   mu0             - global scaling parameter
%
% Output:
% * center    -  ellispoid center coordinates [x_0; y_0; z_0]
% * radii     -  ellipsoid or other conic radii [a; b; c]
% * axis     -  the radii directions as columns of the 3x3 matrix
%
% Solving Minimization Problem to find smallest ellipsoid fitting when
% only allowing few data points to lie outside. 
% Find minimizer v of the following energy functional f:
% 
%   argmin f(v) = argmin mu0 * [ energyPart(v) + 
%                 mu1 * smallRadii(v) + mu2 * surfaceDistances(v) ]
%       s.t. v_1, v_2, v_3 > 0
%
%   with:   v describing describing the ellipsoid algebraically ellipsoid(v) = 0: 
%      ellipsoid(v) = v_1*x^2 + v_2*y^2 + v_3*z^2 + 2*v_4*x + 2*v_5*y + 2*v_6*z 
%                             + v_4^2 / v_1 + v_5^2 / v_2 + v_6^2 / v_3 - 1 
%                   = < v, w> + v_4^2 / v_1 + v_5^2 / v_2 + v_6^2 / v_3 - 1 
%               with w = (x^2, y^2, z^2, 2*x, 2*y, 2*z)
%      
%           smallRadii(v) = 1 / v_1 + 1 / v_2 + 1 / v_3 
%           surfaceDistances(v) = sum of all data rows in X  of ( ellipsoid(v)^2 )
%           energyPart(v) = sum of all data rows in X  of 
%               ( max(0, ellipsoid(v)) )
%
%       differentiable approximation for energyPart(v):
%            = sum of all data rows in X gamma*(log(exp(0) + exp( 1/gamma * ellipsoid(v))) )
%            = sum of all data rows in X gamma*(log( 1 + exp( 1/gamma * ellipsoid(v) )) )
%
%       regularisation parameter: mu1, mu2
%            
% and v initially derived from the implicit function describing 
% an ellipsoid centered at center = (x_0; y_0; z_0)
% and oriented along the coordinate axis 
%
%       [(x-x_0)/a]^2 + [(y-y_0)/a]^2 + [(z-z_0)/a]^2 -1 = 0
% <=>   ellipsoid(v) = 0
%
% with:   
%   v_1     = 1/a^2
%   v_2     = 1/b^2
%   v_3     = 1/c^2
%
%   v_4     = -x_0/a^2  = -x_0 * v_1
%   v_5     = -y_0/b^2  = -y_0 * v_2
%   v_6     = -z_0/c^2  = -z_0 * v_3
%
%   Determine output parameter:
% * radii:      a = 1/sqrt(v_1)
%               b = 1/sqrt(v_2)
%               c = 1/sqrt(v_3)
% * center:     x_0 = -v_4*v_1
%               y_0 = -v_5*v_2
%               z_0 = -v_6*v_3
% Author:
% Ramona Sasse
% Date:
% April, 2018
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% idx = randperm( size(X,1), ceil(0.1*size(X,1)));
% X = X(idx,:); 
[W, X, pca_transformation] = prepareCoordinateMatrixAndOrientationMatrix(X);
[v_initial] = initializeEllipsoidParams(X);
Wtransposed = W';

[funct, grad_funct] = initializeFunctionalAndGradientWithLogApprox (W, fittingParams.regularisationParams, Wtransposed);
[radii, center] = approximateEllipsoidParamsWithDescentMethod(v_initial, W, funct, grad_funct, fittingParams.descentMethod);

% invert coordinate transformation caused by PCA back for center vectors
center = pca_transformation' \ center;

axis=pca_transformation; % column-wise coeff. of principal components
end

function [v] = initializeEllipsoidParams(X)
    if size( X, 2 ) ~= 3
    error( 'Input data must have three columns!' );
    else
        x = X( :, 1 );
        y = X( :, 2 );
        z = X( :, 3 );
        center=[mean(x); mean(y); min(z) + range(z) * 50/60];
        radiiComponent = max(sqrt(sum((X-center') .* (X-center'), 2)));
        radii=[radiiComponent; radiiComponent; radiiComponent];
        v=zeros(6,1);
        v(1:3) = (1./radii).^2;
        v(4:6) = - center .* v(1:3);
    end
end

function [radii, center] = getEllipsoidParams(v)
    radii = sqrt( 1 ./ v(1:3) ) ;
    center = - v(4:6) ./ v(1:3);
end

function [W, X, pca_transformation] = prepareCoordinateMatrixAndOrientationMatrix(X)
    if size( X, 2 ) ~= 3
        error( 'Input data must have three columns!' );
    else
%         pca_transformation = (pca(X))'; % row-wise coeff. of principal components
%         X = (pca_transformation * X')';
        pca_transformation = pca(X); % column-wise coeff. of principal components
        X = X * pca_transformation;
        x = X( :, 1 );
        y = X( :, 2 );
        z = X( :, 3 );
    end

    % need 10 or more data points
    if length( x ) < 6 
       error( 'Must have at least 6 points to approximate an ellipsoidal fitting.' );
    end

    W = [ x .* x, ...
        y .* y, ...
        z .* z, ...
        2 * x, ...
        2 * y, ...
        2 * z];  % ndatapoints x 6 ellipsoid parameters
end

function [radii, center] = approximateEllipsoidParamsWithDescentMethod(v0, W, funct, grad_funct, method)
    try
        v = performGradientSteps(v0, W, funct, grad_funct, method);
        [radii, center] = getEllipsoidParams(v);
%         Wv = W*v;
%         fprintf('########## est. energy \t %e \t \t norm(grad(f(v))): %e\n', funct(v, Wv), norm(grad_funct(v, Wv)));
    catch ERROR_MSG
        disp(ERROR_MSG);
        fprintf('Setting default output parameter.\n');
        radii = ones(3,1);
        center = ones(3,1);
    end
end

function v = performGradientSteps(v, W, funct, grad_funct, method)    
    tic;
    Wv = W*v;    
    gradient = grad_funct(v, Wv);
    % descent direction p
    p = -gradient;
    k = 0;
    TOL = 1e-5;
    TOL_consecutiveIterates = 1e-8;
    maxIteration = 8000;
    n = size(W,1);
    while ( k < maxIteration && norm(gradient) > TOL )
        % step length alpha
        alpha = computeSteplength(v, p, funct, grad_funct, W);
        % stopping criteria if relative change of consecutive iterates v is
        % too small (p. 62 / 83)
        if ( norm ( alpha * p ) / norm (v) < TOL_consecutiveIterates )
            if ( k < 1 && alpha == 0)
               error('Line Search did not give a descent step length in first iteration step.\n')
            end
%             fprintf ('Stopping gradient due to too small relative change of consecutive iterates!\n');
            break;
        end
        v = v + alpha * p;
        Wv = W*v;  
        nextGradient = grad_funct(v, Wv);
        % restart every n'th cycle (p. 124 / 145)
        if ( strcmp(method, 'grad') || (mod(k,n) == 0 && k > 0) )
            beta = 0;
        else
            % betaFR := beta for Fletcher-Reeves variant
            betaFR = nextGradient' * nextGradient / (gradient' * gradient);
            % betaFR := beta for Polak-Ribiere variant
            betaPR = nextGradient' * ( nextGradient-gradient) / (gradient' * gradient);
            if ( betaPR < -betaFR ) 
                beta = -betaFR;
            elseif ( abs(betaPR) <= betaFR )
                beta = betaPR;
            elseif (betaPR > betaFR )
                beta = betaFR;
            end
        end
        p = -nextGradient + beta * p;
        gradient = nextGradient;
        k = k+1;
    end
    time = toc;
    if ( k >= maxIteration ) 
        fprintf ('Gradient descent method did not converge yet (max. iterations %d)! norm(gradient) = %e \n', maxIteration, norm(gradient));
    else 
        fprintf ('Stopped gradient after %d iteration(s) in %f seconds. norm(gradient) = %e \n', k, time, norm(gradient));
    end
end

function alpha_star = computeSteplength(v, descentDirection, funct, grad_funct, W)
    % use a line search algorithm (p.81, Algorithm 3.5)   
    c1 = 1e-4;
    c2 = 0.1; % TODO vary c1, c2?!
    alpha_current = 0;
    alpha_limit = 10;    

    % Make sure that the constraints for v(1), v(2), v(3) > 0 are met
    if (descentDirection(1) < 0 ) 
        alpha_limit = min(alpha_limit, -v(1)/descentDirection(1));
    end
    if (descentDirection(2) < 0 ) 
        alpha_limit = min(alpha_limit, -v(2)/descentDirection(2));
    end
    if (descentDirection(3) < 0 ) 
        alpha_limit = min(alpha_limit, -v(3)/descentDirection(3));
    end
    TOL = 1e-8;
    if ( alpha_limit < TOL)
        fprintf('Stopping line search since maximal steplength smaller than %e.\n', TOL);
        alpha_star = 0;
        return;
    end
    v_temp = v + alpha_current * descentDirection;
    Wv = W * v_temp;
    phi_0 = funct( v_temp, Wv);
    phi_dash_0 = descentDirection' * grad_funct(v_temp, Wv);
    phi_current = phi_0;
    i = 1;
    maxIteration = 30;
    increase_steplength = (alpha_limit - alpha_current ) / maxIteration;
    alpha_next = alpha_current +  increase_steplength; % initialize next alpha
    while i <= maxIteration
        v_temp = v + alpha_next * descentDirection;
        Wv = W * ( v_temp);
        phi_next = funct( v_temp, Wv);
        % stopping criteria if we cannot attain lower function value after ten
        % trial step lengths (p. 62 / 83)
        if ( mod(i,10) == 0 && phi_0 <= phi_next )
            fprintf('Stopping line search because after ten iterations we could not find a lower function value.\n');
            alpha_star = 0;
            return;
        end
        if ( (phi_next > phi_0 + c1 * alpha_next * phi_dash_0) || ...
                (phi_next >= phi_current && i > 1) )
            alpha_star = zoom(alpha_current, alpha_next, ...
                v, descentDirection, funct, grad_funct, ...
                phi_0, phi_dash_0, c1, c2, W); 
            return;
        end
        
        phi_dash_next = descentDirection' * grad_funct(v_temp, Wv);
        if ( abs(phi_dash_next) <= -c2 * phi_dash_0 )
            alpha_star = alpha_next;
            return;
        end
        
        if (phi_dash_next >= 0 )
            alpha_star = zoom(alpha_next, alpha_current, ...
                v, descentDirection, funct, grad_funct, ...
                phi_0, phi_dash_0, c1, c2, W);
            return;
        end
        alpha_current = alpha_next;
        % next trial value
        alpha_next = alpha_current +  increase_steplength;
        i = i+1;
    end
    if (i >= maxIteration) 
        fprintf('Could not determine next step length after %d line search iterations!\n', maxIteration);
    end
    alpha_star = alpha_next;
end

function alpha_star = zoom(alpha_lower, alpha_higher, ...
    v, descentDirection, funct, grad_funct, phi_0, phi_dash_0, c1, c2, W)
    % use algorithm 3.6 to zoom in to appropriate step length
    iteration = 0;
    maxIteration = 30;
    TOL = 1e-8;
    while iteration < maxIteration
        if ( abs(alpha_lower-alpha_higher) < TOL)
           fprintf('Zoom interval after %d zoom iterations too small to zoom in further.\n', iteration);
           alpha_star=alpha_higher;
           return;
        end
        % use a bisection step
        alpha_j = (alpha_lower + alpha_higher) / 2;
        if ( iteration > 0 )
            % safeguard procedure (p.58, 79): if alpha_j (alpha_i)
            % is too close to alpha_last (alpha_i-1) or too much smaller
            % than alpha_last (alpha_i-1), reset alpha_j:
            if ( abs(alpha_last - alpha_j) < TOL || ...
                    abs(alpha_last - alpha_j ) / alpha_last < TOL || ...
                    abs(alpha_j ) < TOL )  % alpha_j shouldn't be too small
               alpha_star = alpha_last / 2; 
               return;
            end
        end
        v_temp_j = v + alpha_j * descentDirection;
        Wvj = W*v_temp_j;
        phi_alpha_j = funct( v_temp_j, Wvj);
        v_temp_lower = v + alpha_lower * descentDirection;
        Wvl = W*v_temp_lower;
        phi_alpha_lower = funct( v_temp_lower, Wvl);
        if ( phi_alpha_j > phi_0 + c1 * alpha_j * phi_dash_0 || ...
                phi_alpha_j >= phi_alpha_lower )
            alpha_higher = alpha_j;
        else
            phi_dash_j = descentDirection' * grad_funct(v_temp_j, Wvj);
            if ( abs(phi_dash_j) <= -c2 * phi_dash_0 ) 
                alpha_star = alpha_j;
                return;
            end
            if ( phi_dash_j * ( alpha_higher - alpha_lower) >= 0 )
                alpha_higher = alpha_lower;
            end
            alpha_lower = alpha_j;
        end
            
        iteration = iteration + 1;
        alpha_last = alpha_j;
    end
    if (iteration >= maxIteration) 
        fprintf('Steplength not yet found. Zoom in stopped\n');
        alpha_star = 0;
    end
end

function [funct, grad_funct] = initializeFunctionalAndGradientWithLogApprox( W, regularisationParams, Wtransposed)
funct = @(v, Wv) regularisationParams.mu0 * ( regularisationParams.gamma*sum(...
    log( 1 + exp( 1/regularisationParams.gamma * (Wv + (v(4)^2/v(1) + v(5)^2/v(2) + v(6)^2/v(3) - 1)) ) ) ) + ...
    ... % volumetric reguliser
    regularisationParams.mu1 * ( 1/v(1) + 1/v(2) + 1/v(3) )  + ...
    regularisationParams.mu2 * sum(( Wv + (v(4)^2/v(1) + v(5)^2/v(2) + v(6)^2/v(3) - 1)).^2) );

grad_funct = @(v, Wv) regularisationParams.mu0 * ( ( Wtransposed + ...
    [-(v(4)/v(1))^2; -(v(5)/v(2))^2; -(v(6)/v(3))^2; 2*v(4)/v(1); 2*v(5)/v(2); 2*v(6)/v(3)] ) * ...
    ( exp((1/regularisationParams.gamma) * (Wv + (v(4)^2/v(1) + v(5)^2/v(2) + v(6)^2/v(3) - 1)) ) ./ ...
    ( 1 + exp((1/regularisationParams.gamma) * (Wv + (v(4)^2/v(1) + v(5)^2/v(2) + v(6)^2/v(3) - 1)) )) ) + ...
    ... % volumetric reguliser
    regularisationParams.mu1 * [-1./v(1:3).^2; 0; 0 ; 0] + ...
    regularisationParams.mu2 * (( Wtransposed + ...
    [-(v(4)/v(1))^2; -(v(5)/v(2))^2; -(v(6)/v(3))^2; 2*v(4)/v(1); 2*v(5)/v(2); 2*v(6)/v(3)] ) * ...
    2 * ( Wv + (v(4)^2/v(1) + v(5)^2/v(2) + v(6)^2/v(3) - 1))));
end
