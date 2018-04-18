%% estimate minimal ellipsoid fitting for data set
function [ center, radii, axis, radii_ref, center_ref, radii_initial, center_initial ] ...
    = getEllipsoidCharacteristicsInitialReferenceEstimation...
    ( X, descentMethod, maxDifferentiableApprox, regularisationParams, includePCA)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Fit an ellispoid/sphere to a set of xyz data points:
%
%   [center, radii, evecs, v ] = estimateMinimumEllipsoid( X )
%   [center, radii, evecs, v ] = estimateMinimumEllipsoid( [x y z] );
%
% Parameters:
% * X, [x y z]      - Cartesian data, n x 3 matrix or three n x 1 vectors
% * picfilename     - name to save png with estimated ellipsoids
% * descentMethod   - 'cg' : conjugate gradient method
%                     'grad' : gradient descent method
% * maxDifferentiableApprox - 'sqr' : approximate kink with (max(...))^2
%                           - 'log' : approximate kink with log(...) 
%                           (see below)
% * regularisationParams:
%   mu1,mu2,mu3,mu4 - weights for volumetric terms
% 	gamma           - parameter for smooth approximation with logarithm of 
%                     kink in max(0,...) 
%
% Output:
% * center    -  ellispoid center coordinates [x_0; y_0; z_0]
% * radii     -  ellipsoid or other conic radii [a; b; c]
% * evecs     -  the radii directions as columns of the 3x3 matrix
%
% Solving Minimization Problem to find smallest ellipsoid fitting when
% only allowing few data points to lie outside. 
% Find minimizer v of the following energy functional f:
% 
%   argmin f(v) = argmin [ energyPart(v) +  mu1 * equidistantRadii(v) 
%                 + mu2 * smallRadii(v) + mu3 * surfaceDistances(v) ]
%       s.t. v_1, v_2, v_3 > 0
%
%   with:   v describing describing the ellipsoid algebraically ellipsoid(v) = 0: 
%      ellipsoid(v) = v_1*x^2 + v_2*y^2 + v_3*z^2 + 2*v_4*x + 2*v_5*y + 2*v_6*z 
%                             + v_4^2 / v_1 + v_5^2 / v_2 + v_6^2 / v_3 - 1 
%                   = < v, w> + v_4^2 / v_1 + v_5^2 / v_2 + v_6^2 / v_3 - 1 
%               with w = (x^2, y^2, z^2, 2*x, 2*y, 2*z)
%      
%           equidistantRadii(v) = (v_1 - v_2)^2 + (v_2 - v_3)^2 + (v_1 - v_3)^2 
%           smallRadii(v) = 1 / v_1 + 1 / v_2 + 1 / v_3 
%           surfaceDistances(v) = sum of all data rows in X  of ( ellipsoid(v)^2 )
%           energyPart(v) = sum of all data rows in X  of 
%               ( max(0, ellipsoid(v)) )

%       differentiable approximation for energyPart(v):
%       (maxDifferentiableApprox = 'log')
%            = sum of all data rows in X gamma*(log(exp(0) + exp( 1/gamma * ellipsoid(v))) )
%            = sum of all data rows in X gamma*(log( 1 + exp( 1/gamma * ellipsoid(v) )) )
%       alternative differentiable approximation for energyPart(v):
%       (maxDifferentiableApprox = 'sgr')
%            = sum of all data rows in X ( max(0, ellipsoid(v) ) )^2
%       regularisation parameter: mu1, mu2 with 0 <= mu2 <= 1
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

% [W, X, ~] = prepareCoordinateMatrixAndOrientationMatrix(X, includePCA);
% [~, ~, v_initial] = initializeEllipsoidParams(X, 'pre');
% 
% X = removeFirstOutliers(W,v_initial, X);
% do initialization again with improved data set
[W, X, pca_transformation] = prepareCoordinateMatrixAndOrientationMatrix(X, includePCA);
[radii_initial, center_initial, v_initial] = initializeEllipsoidParams(X, '');

[volumetricregulariser, grad_volumetricRegulariser] = initializeVolumetricRegulariserFunctionalAndGradient(W, regularisationParams);
if ( strcmpi(maxDifferentiableApprox, 'sqr'))
    fprintf('Use quadratic approximation of non-diff. term.\n');
    [funct, grad_funct] = initializeFunctionalAndGradientWithQuadraticMaxApprox( W, volumetricregulariser, grad_volumetricRegulariser); 
elseif ( strcmpi(maxDifferentiableApprox, 'log'))
    fprintf('Use logarithmic approximation of non-diff. term.\n');
    [funct, grad_funct] = initializeFunctionalAndGradientWithLogApprox (W, regularisationParams, volumetricregulariser, grad_volumetricRegulariser);
else
   error('No or unknown type for approximation of max with differentiable function!') 
end

[phi, phi_dash] = initializePhiAndPhiDash (funct, grad_funct);
[radii, center] = approximateEllipsoidParamsWithDescentMethod(v_initial, W, grad_funct, phi, phi_dash, descentMethod, funct);
[radii_ref, center_ref] = getReferenceEllipsoidApproximation(funct, v_initial, grad_funct);

% invert coordinate transformation caused by PCA back for center vectors
center = pca_transformation \ center;
center_ref = pca_transformation \ center_ref;
center_initial = pca_transformation \ center_initial;

axis=pca_transformation';
end

function [W, X, pca_transformation] = prepareCoordinateMatrixAndOrientationMatrix(X, includePCA)
    pca_transformation = eye(3);
    if size( X, 2 ) ~= 3
        error( 'Input data must have three columns!' );
    else
        if ( includePCA )
            pca_transformation = (pca(X))';
            X = (pca_transformation * X')';
        end
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

function X = removeFirstOutliers(W, v, X)
    X = X( W*v + (v(4)^2/v(1) + v(5)^2/v(2) + v(6)^2/v(3)) - 1 <= 0, :);
end

function [radii, center] = approximateEllipsoidParamsWithDescentMethod(v0, W, grad_funct, phi, phi_dash, method, funct)
    try
        v = performGradientSteps(v0, W, grad_funct, phi, phi_dash, method, funct);
        [radii, center] = getEllipsoidParams(v);
        fprintf('########## est. energy \t %f \t \t norm(grad(f(v))): %f\n', funct(v), norm(grad_funct(v)));
    catch ERROR_MSG
        disp(ERROR_MSG);
        fprintf('Setting default output parameter.\n');
        radii = ones(3,1);
        center = ones(3,1);
    end
end

function [radii, center] = getReferenceEllipsoidApproximation(funct, v0, grad_funct)
    fprintf('Approximate ellipsoid with MATLAB reference method...\n');
    [v] = fminsearch(funct, v0);
    fprintf('########## ref. energy \t %f \t \t norm(grad(f(v))): %f\n', funct(v), norm(grad_funct(v)));
    [radii, center] = getEllipsoidParams(v);
end

function [radii, center, v] = initializeEllipsoidParams(X, radiiSelection)
    if size( X, 2 ) ~= 3
    error( 'Input data must have three columns!' );
    else
        x = X( :, 1 );
        y = X( :, 2 );
        z = X( :, 3 );
        center=[mean(x); mean(y); min(z) + range(z) * 50/60];
        if ( strcmpi(radiiSelection, 'pre'))
            % prestep initialization for outlier removal
            radiiComponent = mean(sqrt(sum((X-center') .* (X-center'), 2)));
            % add additionally 10% 
            radiiComponent = radiiComponent + 0.1*radiiComponent;
        else
            radiiComponent = max(sqrt(sum((X-center') .* (X-center'), 2)));
        end
        radii=[radiiComponent; radiiComponent; radiiComponent];
        v=zeros(6,1);
        v(1:3) = (1./radii).^2;
        v(4:6) = - center .* v(1:3);
    end
end

function [radiiMax] = getMaximalRadiiLimits(X)
    % half of diameter in x and y direction
    radiiMax(1) = ( max(X(:,1)) - min(X(:,1)) )/ 2; 
    radiiMax(2) = ( max(X(:,2)) - min(X(:,2)) )/ 2;
    % assume that only half of ellipsoid in z direction is microscopied 
    radiiMax(3) = ( max(X(:,3)) - min(X(:,3)) )/ 2 * 100/55;
    radiiMax=radiiMax';
end

function [funct, grad_funct] = initializeFunctionalAndGradientWithLogApprox( W, regularisationParams, volumetricregulariser, grad_volumetricRegulariser)
funct = @(v) regularisationParams.gamma*sum(...
    log( 1 + exp( 1/regularisationParams.gamma * (W*v + (v(4)^2/v(1) + v(5)^2/v(2) + v(6)^2/v(3) - 1)) ) ) ) + ...
    volumetricregulariser(v);

n = size(W,1);
grad_funct = @(v) ( W' + ...
    [-(v(4)/v(1))^2; -(v(5)/v(2))^2; -(v(6)/v(3))^2; 2*v(4)/v(1); 2*v(5)/v(2); 2*v(6)/v(3)] * ones(1,n) ) * ...
    ( exp((1/regularisationParams.gamma) * (W*v + (v(4)^2/v(1) + v(5)^2/v(2) + v(6)^2/v(3) - 1)) ) ./ ...
    ( 1 + exp((1/regularisationParams.gamma) * (W*v + (v(4)^2/v(1) + v(5)^2/v(2) + v(6)^2/v(3) - 1)) )) ) + ...
    grad_volumetricRegulariser(v);
end

function [funct, grad_funct] = initializeFunctionalAndGradientWithQuadraticMaxApprox...
    (W, volumetricregulariser, grad_volumetricRegulariser)

funct = @(v) sum( (max(0, W*v + (v(4)^2/v(1) + v(5)^2/v(2) + v(6)^2/v(3) - 1) ) ).^2 ) + ...
    volumetricregulariser(v);

n = size(W,1);
grad_funct = @(v) ( ( W' + ...
    [-(v(4)/v(1))^2; -(v(5)/v(2))^2; -(v(6)/v(3))^2; 2*v(4)/v(1); 2*v(5)/v(2); 2*v(6)/v(3)] * ones(1,n) ) ...
    * 2 * (max(0, W*v + (v(4)^2/v(1) + v(5)^2/v(2) + v(6)^2/v(3) - 1) ) ) ) + ...
    grad_volumetricRegulariser(v);
end

function [volumetricregulariser, grad_volumetricRegulariser] = initializeVolumetricRegulariserFunctionalAndGradient...
    (W, regularisationParams)
    volumetricregulariser = @(v) ...
    regularisationParams.mu1 * ( (v(1) - v(2))^2 + (v(3) - v(2))^2 + (v(1) - v(3))^2 )+ ...
    regularisationParams.mu2 * ( 1/v(1) + 1/v(2) + 1/v(3) )  + ...
    regularisationParams.mu3 * sum(( W*v + (v(4)^2/v(1) + v(5)^2/v(2) + v(6)^2/v(3) - 1)).^2);

n = size(W,1);
grad_volumetricRegulariser = @(v) ...
    regularisationParams.mu1 * [2*(2*v(1) - v(2) - v(3));  2*(2*v(2) - v(1) - v(3)); 2*(2*v(3) - v(1) - v(2)); 0; 0; 0] + ...
    regularisationParams.mu2 * [-1./v(1:3).^2; 0; 0 ; 0] + ...
    regularisationParams.mu3 * (( W' + ...
    [-(v(4)/v(1))^2; -(v(5)/v(2))^2; -(v(6)/v(3))^2; 2*v(4)/v(1); 2*v(5)/v(2); 2*v(6)/v(3)] * ones(1,n) ) * ...
    2 * ( W*v + (v(4)^2/v(1) + v(5)^2/v(2) + v(6)^2/v(3) - 1)));
end

function [phi, phi_dash] = initializePhiAndPhiDash (funct, grad_funct)
    phi = @(alpha, v, descentDirection) funct( v + alpha * descentDirection);
    phi_dash = @(alpha, v, descentDirection) descentDirection' * grad_funct(v + alpha * descentDirection);
end

% function [radii, center, evecs, v] = getEllipsoidParams(v)
function [radii, center] = getEllipsoidParams(v)
    radii = sqrt( 1 ./ v(1:3) ) ;
    center = - v(4:6) ./ v(1:3);
end

function v = performGradientSteps(v, W, grad_funct, phi, phi_dash, method, funct)
    gradient = grad_funct(v);
    % descent direction p
    p = -gradient; 
    k = 0;
    TOL = 1e-15;
    maxIteration = 1000;
    n = size(W,1);
    if ( strcmpi(method, 'cg') )
        fprintf('Using conjugate gradient method...\n');
    else
        fprintf('Using gradient descent method...\n');
    end
    while ( k < maxIteration && norm(gradient) > TOL)
        % step length alpha
        alpha = computeSteplength(v, p, phi, phi_dash);
        % stopping criteria if relative change of consecutive iterates v is
        % too small (p. 62 / 83)
        if ( norm ( alpha * p ) / norm (v) < TOL )
            if ( k < 1 && alpha == 0)
               error('Line Search did not give a descent step length in first iteration step.\n')
            end
            fprintf ('Stopping gradient after %d iteration(s) due to too small relative change of consecutive iterates!\n', k);
            break;
        end
        v = v + alpha * p;
%         fprintf('#####current energy: %f \n',funct(v));
        nextGradient = grad_funct(v);
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
    if ( k >= maxIteration ) 
        fprintf ('Gradient descent method did not converge yet (max. iterations %d)! norm(gradient) = %e \n', maxIteration, norm(gradient));
    end
end

function alpha_star = computeSteplength(v, descentDirection, phi, phi_dash)
    % use a line search algorithm (p.81, Algorithm 3.5)   
    c1 = 1e-4;
    c2 = 0.1;
    alpha_current = 0;
    alpha_limit = 1000;    

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
    TOL = 1e-15;
    if ( alpha_limit < TOL)
        fprintf('Stopping line search since maximal steplength smaller than %e.\n', TOL);
        alpha_star = 0;
        return;
    end
        
    phi_0 = phi( alpha_current, v, descentDirection);
    phi_dash_0 = phi_dash( alpha_current, v, descentDirection);
    phi_current = phi_0;
    i = 1;
    maxIteration = 30;
    increase_steplength = (alpha_limit - alpha_current ) / maxIteration;
    alpha_next = alpha_current +  increase_steplength; % initialize next alpha
    while i <= maxIteration
        phi_next = phi( alpha_next, v, descentDirection);
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
                v, descentDirection, phi, phi_dash, ...
                phi_0, phi_dash_0, c1, c2); 
            return;
        end
        
        phi_dash_next = phi_dash( alpha_next, v, descentDirection);
        if ( abs(phi_dash_next) <= -c2 * phi_dash_0 )
            alpha_star = alpha_next;
            return;
        end
        
        if (phi_dash_next >= 0 )
            alpha_star = zoom(alpha_next, alpha_current, ...
                v, descentDirection, phi, phi_dash, ...
                phi_0, phi_dash_0, c1, c2);
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
    v, descentDirection, phi, phi_dash, phi_0, phi_dash_0, c1, c2)
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
            % safeguard procedure (p.58, 79): if alpha_next (alpha_i)
            % is too close to alpha_current (alpha_i-1) or too much smaller
            % than alpha_current (alpha_i-1), reset alpha_next:
            if ( alpha_last - alpha_j < TOL || ...
                    ( alpha_last - alpha_j ) / alpha_last < TOL || ...
                    abs(alpha_j ) < TOL )  % alpha_j shouldn't be too small
               alpha_star = alpha_last / 2; 
               return;
            end
        end
        
        phi_alpha_j = phi( alpha_j, v, descentDirection);
        phi_alpha_lower = phi( alpha_lower, v, descentDirection);
        if ( phi_alpha_j > phi_0 + c1 * alpha_j * phi_dash_0 || ...
                phi_alpha_j >= phi_alpha_lower )
            alpha_higher = alpha_j;
        else
            phi_dash_j = phi_dash( alpha_j, v, descentDirection);
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
    alpha_star = alpha_j; % use last iterate as default return value
    if (iteration >= maxIteration) 
        fprintf('Steplength not yet found. Zoom in stopped\n');
        alpha_star = 0;
    end
end