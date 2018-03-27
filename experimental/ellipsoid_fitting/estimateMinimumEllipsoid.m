%% estimate minimal ellipsoid fitting for data set
function [ center, radii, evecs, v ] = estimateMinimumEllipsoid( X , picfilename, method, mu1, mu2, eps)
%
% Fit an ellispoid/sphere to a set of xyz data points:
%
%   [center, radii, evecs, v ] = estimateMinimumEllipsoid( X )
%   [center, radii, evecs, v ] = estimateMinimumEllipsoid( [x y z] );
%
% Parameters:
% * X, [x y z]      - Cartesian data, n x 3 matrix or three n x 1 vectors
% * picfilename     - name to save png with estimated ellipsoids
% * method          - 'cg' : conjugate gradient method
%                     'grad' : gradient descent method
% * mu1, mu2        - regularisation parameter, weights for volumetric
%                     terms, 0<=mu2<=1
% * eps             - parameter for smooth approximation with logarithm of 
%                     kink in max(0,...) 
%
% Output:
% * center    -  ellispoid center coordinates [x_0; y_0; z_0]
% * radii     -  ellipsoid or other conic radii [a; b; c]
% * evecs     -  the radii directions as columns of the 3x3 matrix
% * v         -  the 7 parameters describing the ellipsoid algebraically: 
%         v_1*x^2 + v_2*y^2 + v_3*z^2 + 2*v_4*x + 2*v_5*y + 2*v_6*z + v_7 = 0
%
% Solving Minimization Problem to find smallest ellipsoid fitting when
% only allowing few data points to lie outside. 
% Find minimizer v of the following energy functional f:
% 
%   argmin f(v) = argmin [ energyPart(v) + 
%               mu1 * ( mu2 * equidistantRadii(v) 
%                       + (1 - mu2) * smallRadii(v) ) ]
%       s.t. v_1, v_2, v_3 > 0
%
%   with:   equidistantRadii(v) = (v_1 - v_2)^2 + (v_2 - v_3)^2 + (v_1 - v_3)^2 
%           smallRadii(v) = 1 / v_1 + 1 / v_2 + 1 / v_3 
%           energyPart(v) = sum of all data rows in X ( max(0, < v, w > ) )
%       differentiable approximation for energyPart(v):
%            = sum of all data rows in X eps*(log(exp(0) + exp( 1/eps * < v, w > )) )
%            = sum of all data rows in X eps*(log( 1 + exp( 1/eps * < v, w > )) )
%       alternative differentiable approximation for energyPart(v):
%            = sum of all data rows in X ( max(0, < v, w > ) )^2
%       regularisation parameter: mu1, mu2 with 0 <= mu2 <= 1
%            
% with w = (x^2, y^2, z^2, 2*x, 2*y, 2*z, 1)
% and v initially derived from the implicit function describing 
% an ellipsoid centered at center = (x_0; y_0; z_0)
% and oriented along the coordinate axis 
% TODO: it is important to to find with PCA of the data points the first 
% axis (1. Hauptachse) of the ellipsoid and rotate the data set accordingly
%
%       [(x-x_0)/a]^2 + [(y-y_0)/a]^2 + [(z-z_0)/a]^2 -1 = 0
% <=>   v_1*x^2 + v_2*y^2 + v_3*z^2 + 2*v_4*x + 2*v_5*y + 2*v_6*z + v_7 = 0
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
%   v_7     =  (x_0/a)^2 + (y_0/b)^2 + (z_0/c)^2 - 1
%           =  v_4^2/v_1 + v_5^2/v_2 + v_6^2/v_3 - 1
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
% February, 2018
%

inputParams.mu1 = mu1; 
%inputParams.mu1 = 10; %results in really good approximation compared to reference ellipsoids
inputParams.mu2 = mu2; % equal weights for volumetric parts
inputParams.eps = eps;

if size( X, 2 ) ~= 3
    error( 'Input data must have three columns!' );
else
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

fprintf('Initialize ellipsoid parameter so that ellipsoid contains all data points.\n\n');
[radii_initial, center_initial, v_initial] = initializeEllipsoidParams(x,y,z);


[funct, grad_funct] = initializeFunctionalAndGradientWithQuadraticMaxApprox( W, inputParams);
[phi, phi_dash] = initializePhiAndPhiDash (funct, grad_funct);
fprintf('Use quadratic approximation of non-diff. term.\n');
[radii, center, v] = tryToApproximateEllipsoidParamsWithDescentMethod(v_initial, W, grad_funct, phi, phi_dash, method);
[radii_ref, center_ref, v_ref] = getReferenceEllipsoidApproximation(funct, v_initial);
fprintf('\n');
[funct, grad_funct] = initializeFunctionalAndGradientWithLogApprox (W, inputParams);
[phi, phi_dash] = initializePhiAndPhiDash (funct, grad_funct);
fprintf('Use logarithmic approximation of non-diff. term.\n');
[radii1, center1, v1] = tryToApproximateEllipsoidParamsWithDescentMethod(v_initial, W, grad_funct, phi, phi_dash, method);
[radii_ref1, center_ref1, v_ref1] = getReferenceEllipsoidApproximation(funct, v_initial);

table( radii_initial, radii, radii_ref, radii1, radii_ref1)
table( center_initial, center, center_ref, center1, center_ref1 )
%table( v_initial, v, v_ref, v1, v_ref1)

evecs=0; % TODO

% plot ellipsoid fittings
figure('Name', 'Scatter plot and resulting ellipsoid fittings','units','normalized','outerposition',[0 0 1 1]);
sp = subplot(1,2,1);
titletext = 'Approximation of non differentiable term with (max(0,...))^2';
plotSeveralEllipsoidEstimations(sp, X, center_initial, radii_initial, center, radii,  center_ref, radii_ref, titletext);
sp = subplot(1,2,2);
titletext = 'Approximation of non differentiable term with log(1+eps(...))';
plotSeveralEllipsoidEstimations(sp, X, center_initial, radii_initial, center1, radii1, center_ref1, radii_ref1, titletext);
print(['results/ellipsoid_estimation_' picfilename '.png'],'-dpng')
end

function [radii, center, v] = tryToApproximateEllipsoidParamsWithDescentMethod(v0, W, grad_funct, phi, phi_dash, method)
    try
        v = performGradientSteps(v0, W, grad_funct, phi, phi_dash, method);
        [radii, center] = getEllipsoidParams(v);
    catch ERROR_MSG
        disp(ERROR_MSG);
        fprintf('Setting default output parameter.\n');
        radii = 1i*(ones(3,1));
        center = 1i*(ones(3,1));
        v=zeros(6,1);
    end
end

function [radii, center, v] = getReferenceEllipsoidApproximation(funct, v0)
    fprintf('Approximate ellipsoid with MATLAB reference method...\n');
    v = fminsearch(funct, v0);
    [radii, center] = getEllipsoidParams(v);
end

function plotSeveralEllipsoidEstimations(sp, X, center_initial, radii_initial, center, radii, center_ref, radii_ref, titletext)
    hold(sp, 'on');
    scatter3(X(:,1),X(:,2), X(:,3),'b','.', 'DisplayName', 'input data');
    plotOneEllipsoidEstimation( center_initial, radii_initial, 'g', 'initialization ellipsoid');
    plotOneEllipsoidEstimation( center, radii, 'm', 'ellipsoid estimation');
    plotOneEllipsoidEstimation( center_ref, radii_ref, 'c','reference estimation');
    legend('Location', 'northeast');
    title(titletext);
    view(3);
    hold(sp, 'off');
end

function plotOneEllipsoidEstimation( center, radii, color, displayname)
if isreal(center) && isreal(radii)
    [x,y,z] = ellipsoid(center(1), center(2), center(3), radii(1), radii(2), radii(3), 20);
    surf(x,y,z, 'FaceAlpha',0.15, 'FaceColor', color, 'EdgeColor', 'none', 'DisplayName', displayname);
end
    
end

function [funct, grad_funct] = initializeFunctionalAndGradientWithLogApprox( W, inputParams)
funct = @(v) inputParams.eps*sum(...
    log( 1 + exp( 1/inputParams.eps * (W*v + (v(4)^2/v(1) + v(5)^2/v(2) + v(6)^2/v(3) - 1)) ) ) ) + ...
    inputParams.mu1 * ( inputParams.mu2 * ( (v(1) - v(2))^2 + (v(3) - v(2))^2 + (v(1) - v(3))^2 )+ ...
    (1 - inputParams.mu2) * ( 1/v(1) + 1/v(2) + 1/v(3) ) );

n = size(W,1);
grad_funct = @(v) ( W' + ...
    [-(v(4)/v(1))^2; -(v(5)/v(2))^2; -(v(6)/v(3))^2; 2*v(4)/v(1); 2*v(5)/v(2); 2*v(6)/v(3)] * ones(1,n) ) * ...
    ( exp(1/inputParams.eps .* (W*v + (v(4)^2/v(1) + v(5)^2/v(2) + v(6)^2/v(3) - 1)) ) ./ ...
    ( 1 + exp(1/inputParams.eps .* (W*v + (v(4)^2/v(1) + v(5)^2/v(2) + v(6)^2/v(3) - 1)) )) ) + ...
    inputParams.mu1 * ( inputParams.mu2 * [2*(2*v(1) - v(2) - v(3));  2*(2*v(2) - v(1) - v(3)); 2*(2*v(3) - v(1) - v(2)); 0; 0; 0] + ...
    (1 - inputParams.mu2) * [-1./v(1:3).^2; 0; 0 ; 0]);
end

function [funct, grad_funct] = initializeFunctionalAndGradientWithQuadraticMaxApprox(W, inputParams)
funct = @(v) sum( (max(0, W*v + (v(4)^2/v(1) + v(5)^2/v(2) + v(6)^2/v(3) - 1) ) ).^2 ) + ...
    inputParams.mu1 * ( inputParams.mu2 * ((v(1) - v(2))^2 + (v(3) - v(2))^2 + (v(1) - v(3))^2)+ ...
    ( 1 - inputParams.mu2 ) * ( 1/v(1) + 1/v(2) + 1/v(3) ) );

n = size(W,1);
grad_funct = @(v) ( ( W' + ...
    [-(v(4)/v(1))^2; -(v(5)/v(2))^2; -(v(6)/v(3))^2; 2*v(4)/v(1); 2*v(5)/v(2); 2*v(6)/v(3)] * ones(1,n) ) ...
    * 2 * (max(0, W*v + (v(4)^2/v(1) + v(5)^2/v(2) + v(6)^2/v(3) - 1) ) ) ) + ...
    inputParams.mu1 * ( inputParams.mu2 * [2*(2*v(1) - v(2) - v(3));  2*(2*v(2) - v(1) - v(3)); 2*(2*v(3) - v(1) - v(2)); 0; 0; 0] + ...
    ( 1 - inputParams.mu2 ) * [-1./v(1:3).^2; 0; 0 ; 0]);
end

function [phi, phi_dash] = initializePhiAndPhiDash (funct, grad_funct)
    phi = @(alpha, v, descentDirection) funct( v + alpha * descentDirection);
    phi_dash = @(alpha, v, descentDirection) descentDirection' * grad_funct(v + alpha * descentDirection);
end

function [radii, center, v] = initializeEllipsoidParams(x,y,z)
    center=[mean(x); mean(y); mean(z)];
    radii=[max(abs(x - center(1))); max(abs(y - center(2)));max(abs(z - center(3)))]; 
    v=zeros(6,1);
    v(1:3) = (1./radii).^2;
    v(4:6) = - center .* v(1:3);
end

% function [radii, center, evecs, v] = getEllipsoidParams(v)
function [radii, center] = getEllipsoidParams(v)
    radii = sqrt( 1 ./ v(1:3) ) ;
    center = - v(4:6) ./ v(1:3);
    % TODO transform v 
    % set eigenvectors evecs
end

function v = performGradientSteps(v, W, grad_funct, phi, phi_dash, method)
    gradient = grad_funct(v);
    % descent direction p
    p = -gradient; 
    k = 0;
    TOL = 1e-6;
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
        % next trial value with interpolation
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
    TOL = 1e-6;
    while iteration < maxIteration
        if ( abs(alpha_lower-alpha_higher) < 1e-10)
           fprintf('Zoom interval too small to zoom in further.\n');
           alpha_star=alpha_higher;
           return;
        end
        % use a bisection step
        alpha_j = (alpha_lower + alpha_higher) / 2;
        if ( iteration > 0 )
            %%%%%%%%%%%%%%%%%%%% TODO safeguard strategy %%%%%%%%%%%%%
            % implement safeguard procedure (p.58, 79): if alpha_next (alpha_i)
            % is not too close to alpha_current (alpha_i-1) or too much smaller
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
    if (iteration >= maxIteration) 
        fprintf('Steplength not yet found. Zoom in stopped\n');
    end
    alpha_star = alpha_j; % use last iterate as default return value
end