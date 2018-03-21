%% estimate minimal ellipsoid fitting for data set
function [ center, radii, evecs, v ] = estimateMinimumEllipsoid( X )
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
% * v         -  the 7 parameters describing the ellipsoid algebraically: 
%         Ax^2 + By^2 + Cz^2 + 2Dx + 2Ey + 2Fz + G = 0
%
% Solving Minimization Problem to find smallest ellipsoid fitting when
% only allowing few data points to lie outside. 
% Find minimizer v of the following energy functional f:
% 
%   argmin f(v) = mu1 * energyPart(v) + mu2 * equidistantRadii(v) + 
%                   mu3 * smallRadii(v)
%
%   with:   equidistantRadii(v) = (v_1 - v_2)^2 + (v_2 - v_3)^2 + (v_1 - v_3)^2 
%           smallRadii(v) = 1 / v_1 + 1 / v_2 + 1 / v_3 
%           energyPart(v) = sum of all data rows in X ( max(0, < v, w > ) )
%            = sum of all data rows in X eps*(log(exp(0) + exp( 1/eps * < v, w > )) )
%            = sum of all data rows in X eps*(log( 1 + exp( 1/eps * < v, w > )) )
%            = sum of all data rows in X eps*(shift + log( exp(-shift) + exp( 1/eps * < v, w > - shift )) )
%           with shift = max<v,w> as a shift to prevent over- and underflow
%
% with w = (x^2, y^2, z^2, 2*x, 2*y, 2*z, 1)
% and v initially derived from the implicit function describing 
% an ellipsoid centered at center = (x_0; y_0; z_0)
% and oriented along the coordinate axis 
% TODO: it is important to to find with PCA of the data points the first 
% axis (1. Hauptachse) of the ellipsoid and rotate the data set accordingly
%
%       [(x-x_0)/a]^2 + [(y-y_0)/a]^2 + [(z-z_0)/a]^2 -1 = 0
% <=>   Ax^2 + By^2 + Cz^2 + 2Dx + 2Ey + 2Fz + G = 0
%
% with:   
%   v_1     = A     = 1/a^2
%   v_2     = B     = 1/b^2
%   v_3     = C     = 1/c^2
%
%   v_4     = D     = -x_0/a
%   v_5     = E     = -y_0/b
%   v_6     = F     = -z_0/c
%
%   v_7     = G     =  (x_0/a)^2 + (y_0/b)^2 + (z_0/c)^2 - 1
%
%   Determine output parameter:
% * center:     x_0 = - D * a = -D*v_4
%               y_0 = - E * b = -E*v_5
%               z_0 = - F * c = -F*v_6
% * radii:      a = 1/sqrt(A) = 1/sqrt(v_1)
%               b = 1/sqrt(B) = 1/sqrt(v_2)
%               c = 1/sqrt(C) = 1/sqrt(v_3)
% Author:
% Ramona Sasse
% Date:
% February, 2018
%

% initialze weights for energy part and volumetric penalty part
inputParams.mu1 = 1;
inputParams.mu2 = 1;
inputParams.mu3 = 1;
inputParams.eps = 1;

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

[radii, center, v0] = initializeEllipsoidParams(x,y,z);

[funct, grad_funct] = initializeFunctionalAndGradient(v0, W, inputParams);
[phi, phi_dash] = initializePhiAndPhiDash (funct, grad_funct);

v = performConjugateGradientSteps(v0, W, funct, grad_funct, phi, phi_dash);

[radii, center] = getEllipsoidParams(v);

options = optimset('Display','iter','PlotFcns',@optimplotfval);
v2 = fminsearch(funct, v0, options);
% v2 = fminsearch(funct, v0);

[radii2, center2] = getEllipsoidParams(v2);
radii
radii2
center
center2
v
v2
evecs=0;
end

function [funct, grad_funct] = initializeFunctionalAndGradient(v0, W, inputParams)
shift = max(W*v0); % corresponds with point which lies furtherst outside of ellipsoid
funct = @(v) inputParams.mu1 * inputParams.eps*sum(shift + log(exp(-shift)+exp(1/inputParams.eps * (W*v + (v(4)^2 + v(5)^2 + v(6)^2 - 1)) - shift))) + ...
    inputParams.mu2 * ((v(1) - v(2))^2 + (v(3) - v(2))^2 + (v(1) - v(3))^2)+ ...
    inputParams.mu3 * (1/v(1) + 1/v(2) + 1/v(3));
% TODO improve function and gradient 
%W' + [0; 0; 0; 2 * v(4); + 2*v(5) + 2*v(6)]
grad_funct = @(v) inputParams.mu1 * W'* (exp(1/inputParams.eps .* (W*v + (v(4)^2 + v(5)^2 + v(6)^2 - 1)) - shift)./(exp(- shift) + exp(1/inputParams.eps .* (W*v + (v(4)^2 + v(5)^2 + v(6)^2 - 1)) - shift)) ) + ...
    inputParams.mu2 * [2*(2*v(1) - v(2) - v(3));  2*(2*v(2) - v(1) - v(3)); 2*(2*v(3) - v(1) - v(2)); 0; 0; 0] + ...
    inputParams.mu3 * [-1./v(1:3).^2; 0; 0 ; 0];
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
    v(4:6) = - (1./radii) .* center;
end

% function [radii, center, evecs, v] = getEllipsoidParams(v)
function [radii, center] = getEllipsoidParams(v)
    radii = sqrt( 1 ./ v(1:3) ) ;
    center = -radii .* v(4:6);
    % TODO transform v 
    % set eigenvectors evecs
end

function v = performConjugateGradientSteps(v, W, funct, grad_funct, phi, phi_dash)
    gradient = grad_funct(v);
    % descent direction p
    p = -gradient; 
    k = 0;
    TOL = 1e-6;
    maxIteration = 10000;
    n = size(W,1);
%     figure(1);
%     clf;
%     hold on;
    while ( k < maxIteration && norm(gradient) > TOL)
        % step length alpha
        alpha = computeSteplength(v, p, phi, phi_dash);
        % stopping criteria if relative change of consecutive iterates v is
        % too small (p. 62 / 83)
        if ( norm ( alpha * p ) / norm (v) < TOL )
            fprintf ('Stopping CG iteration due to too small relative change of consecutive iterates after %d iterations!\n', k);
            break;
        end
        funct(v)
        v = v + alpha * p;
        nextGradient = grad_funct(v);
        % restart every n'th cycle (p. 124 / 145)
%         if ( mod(k,n) == 0 && k > 0 )
            fprintf('Using currently gradient descent method\n');
            beta = 0;
%         else
%             fprintf('norm of next gradient: %e \n', norm(nextGradient));
%             fprintf('norm of current gradient: %e \n',norm(gradient));
%             % betaFR := beta for Fletcher-Reeves variant
%             betaFR = nextGradient' * nextGradient / (gradient' * gradient);
%             % betaFR := beta for Polak-Ribiere variant
%             betaPR = nextGradient' * ( nextGradient-gradient) / (gradient' * gradient);
%             if ( betaPR < -betaFR ) 
%                 beta = -betaFR;
%             elseif ( abs(betaPR) <= betaFR )
%                 beta = betaPR;
%             elseif (betaPR > betaFR )
%                 beta = betaFR;
%             end
%             if( k>1)
%                 plot(k, norm(nextGradient), 'r*');
%                 plot(k, norm(gradient), 'b*');
%             end
%         end
        p = -nextGradient + beta * p;
        gradient = nextGradient;
        k = k+1;
    end
    if ( k >= maxIteration ) 
        error ('Conjugate gradients did not converge yet! norm(gradient) = %e', norm(gradient));
    end
    funct(v)
end

function alpha_star = computeSteplength(v, descentDirection, phi, phi_dash)
    % use a line search algorithm (p.81, Algorithm 3.5)
    c1 = 1e-4;
    c2 = 0.1;
    alpha_current = 0;
    alpha_max = 1e10;
    if (descentDirection(1) < 0 ) 
        alpha_max = min(alpha_max, -v(1)/descentDirection(1));
    end
    if (descentDirection(2) < 0 ) 
        alpha_max = min(alpha_max, -v(2)/descentDirection(2));
    end
    if (descentDirection(3) < 0 ) 
        alpha_max = min(alpha_max, -v(3)/descentDirection(3));
    end
    if (alpha_max == 1e10)
       error('to do problem with alpha_max'); 
    end
    alpha_next = (alpha_max - alpha_current ) / 2; % TODO ?!?!
    i = 1;
    phi_0 = phi( alpha_current, v, descentDirection);
    phi_dash_0 = phi_dash( alpha_current, v, descentDirection);
    phi_current = phi_0;
    maxIteration = 100; 
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
        alpha_next =  quadraticInterpolation(alpha_next, alpha_max, ...
                    v, descentDirection, phi, phi_dash);
        %%%%%%%%%%%%%%%%%%%% TODO safeguard strategy %%%%%%%%%%%%%
        % implement safeguard procedure (p.58, 79): if alpha_next (alpha_i)
        % is not too close to alpha_current (alpha_i-1) or too much smaller
        % than alpha_current (alpha_i-1), reset alpha_next:
%         if ( alpha_current - alpha_next < TOL || ...
%                 ( alpha_current - alpha_next ) / alpha_current < TOL ) 
%            alpha_next = alpha_current / 2; 
%         end
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
    maxIteration = 100;
    TOL = 1e-4;
    while iteration < maxIteration
        alpha_j = quadraticInterpolation(alpha_lower, alpha_higher, ...
                    v, descentDirection, phi, phi_dash);
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

function alpha = quadraticInterpolation(alpha_lower, alpha_higher, ...
                    v, descentDirection, phi, phi_dash)
    phi_dash_alpha_lower = phi_dash( alpha_lower, v, descentDirection);
    phi_alpha_lower = phi( alpha_lower, v, descentDirection);
    phi_alpha_higher = phi( alpha_higher, v, descentDirection);
    % find trial step length by using quadratic interpolation
    alpha = -phi_dash_alpha_lower * alpha_higher^2 / ...
        ( 2 * ( phi_alpha_higher - phi_alpha_lower - phi_dash_alpha_lower * alpha_higher));
end