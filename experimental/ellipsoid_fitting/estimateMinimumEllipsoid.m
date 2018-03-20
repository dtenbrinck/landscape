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
% * v         -  the 10 parameters describing the ellipsoid algebraically: 
%         Ax^2 + By^2 + Cz^2 + 2Dxy + 2Exz + 2Fyz + 2Gx + 2Hy + 2Iz + J = 0
%
% Solving Minimization Problem to find smallest ellipsoid fitting when
% only allowing few data points to lie outside. 
% Find minimizer v of the following energy functional f:
% 
%   argmin f(v) = mu1 * energyPart(v) + mu2 * equidistantRadii(v) + 
%                   mu3 * smallRadii(v)
%
%   with:   equidistantRadii(v) = (1/v_1 - 1/v_2)^2 + (1/v_2 - 1/v_3)^2 + (1/v_1 - 1/v_3)^2 
%           smallRadii(v) = 1 / v_1 + 1 / v_2 + 1 / v_3 
%           energyPart(v) = sum of all data rows in X ( max(0, < v, w > ) )
%            = sum of all data rows in X (log(exp(0) + exp( < v, w > )) )
%            = sum of all data rows in X (log( 1 + exp( < v, w > )) )
%            = sum of all data rows in X (shift + log( exp(-shift) + exp( < v, w > - shift )) )
%           with shift = max<v,w> as a shift to prevent over- and underflow
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
mu1 = 1; mu2 = 0; mu3 = 1;

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

W = [ x .* x, ...
    y .* y, ...
    z .* z, ...
    2 * x .* y, ...
    2 * x .* z, ...
    2 * y .* z, ...
    2 * x, ...
    2 * y, ...
    2 * z, ...
    1 + 0 * x ];  % ndatapoints x 10 ellipsoid parameters

[radii, center, v] = initializeEllipsoidParams(x,y,z);

v = performConjugateGradientSteps(v, W, mu1, mu2, mu3);

[radii, center, evecs, v] = getEllipsoidParams(v);

end

function [radii, center, v] = initializeEllipsoidParams(x,y,z)
    center=[mean(x); mean(y); mean(z)];
    radii=[max(abs(x - center(1))); max(abs(y - center(2)));max(abs(z - center(3)))]; 
    v=zeros(10,1);
    v(1:3) = (1./radii).^2;
    v(7:9) = - v(1:3) .* center;
    v(10) = sum( v(1:3) .* (center.^2) ) - 1;
end

function [radii, center, evecs, v] = getEllipsoidParams(v)
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

function v = performConjugateGradientSteps(v, W, mu1, mu2, mu3)
    %functionValue = getCurrentFunctionValue(v, W, mu1, mu2, mu3)
    gradient = getCurrentGradient(v, W, mu1, mu2, mu3);
    % descent direction p
    p = -gradient; 
    k = 0;
    TOL = 1e-6;
    maxIteration = 10000;
    n = size(W,1);
    while ( k < maxIteration && norm(gradient) > TOL)
        % step length alpha
        alpha = computeSteplength(v, p, W, mu1, mu2, mu3);
        % stopping criteria if relative change of consecutive iterates v is
        % too small (p. 62 / 83)
        if ( norm ( alpha * p ) / norm (v) < TOL )
            fprintf ('Stopping CG iteration due to too small relative change of consecutive iterates!');
            break;
        end
        v = v + alpha * p;
        nextGradient = getCurrentGradient(v, W, mu1, mu2, mu3);
        % restart every n'th cycle (p. 124 / 145)
        if ( mod(k,n) == 0 && k > 0 )
            fprintf('Restarting CG iteration with beta = 0.\n');
            beta = 0;
        else
            % betaFR = beta for Fletcher-Reeves variant
            betaFR = nextGradient' * nextGradient / (gradient' * gradient);
            % betaFR = beta for Polak-Ribiere variant
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
        error ('Conjugate gradients did not converge yet! norm(gradient) = %e', norm(gradient));
    end
end

function alpha_star = computeSteplength(v, descentDirection, W, mu1, mu2, mu3)
    % use a line search algorithm (p.81, Algorithm 3.5)
    c1 = 1e-4;
    c2 = 0.1;
    alpha_current = 0;
    alpha_max = 10; % TODO ?!?! 
    alpha_next = (alpha_max - alpha_current ) / 2; % TODO ?!?!
    i = 1;
    phi_0 = getPhiValue( alpha_current, v, descentDirection, W, mu1, mu2, mu3);
    phi_dash_0 = getPhiDerivative( alpha_current, v, descentDirection, W, mu1, mu2, mu3);
    phi_current = phi_0;
    maxIteration = 100; 
    while i <= maxIteration
        phi_next = getPhiValue( alpha_next, v, descentDirection, W, mu1, mu2, mu3);
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
                v, descentDirection, W, mu1, mu2, mu3, ...
                phi_0, phi_dash_0, c1, c2);
            return;
        end
        
        phi_dash_next = getPhiDerivative( alpha_next, v, descentDirection, W, mu1, mu2, mu3);
        if ( abs(phi_dash_next) <= -c2 * phi_dash_0 )
            alpha_star = alpha_next;
            return;
        end
        
        if (phi_dash_next >= 0 )
            alpha_star = zoom(alpha_next, alpha_current, ...
                v, descentDirection, W, mu1, mu2, mu3, ...
                phi_0, phi_dash_0, c1, c2);
            return;
        end
        
        alpha_current = alpha_next;
        % next trial value with interpolation
        alpha_next =  quadraticInterpolation(alpha_next, alpha_max, ...
                    v, descentDirection, W, mu1, mu2, mu3);
        i = i+1;
    end
    if (i >= maxIteration) 
        fprintf('Could not determine next step length after %d line search iterations!\n', maxIteration);
    end
    alpha_star = alpha_next;
end

function alpha_star = zoom(alpha_lower, alpha_higher, ...
    v, descentDirection, W, mu1, mu2, mu3, ...
    phi_0, phi_dash_0, c1, c2)
    % use algorithm 3.6 to zoom in to appropriate step length
    iteration = 0;
    maxIteration = 100;
    while iteration < maxIteration
        alpha_j = quadraticInterpolation(alpha_lower, alpha_higher, ...
                    v, descentDirection, W, mu1, mu2, mu3);
        phi_alpha_j = getPhiValue( alpha_j, v, descentDirection, W, mu1, mu2, mu3);
        phi_alpha_lower = getPhiValue( alpha_lower, v, descentDirection, W, mu1, mu2, mu3);
        if ( phi_alpha_j > phi_0 + c1 * alpha_j * phi_dash_0 || ...
                phi_alpha_j >= phi_alpha_lower )
            alpha_higher = alpha_j;
        else
            phi_dash_j = getPhiDerivative( alpha_j, v, descentDirection, W, mu1, mu2, mu3);
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
    end
    if (iteration >= maxIteration) 
        error('Steplength not yet found. Zoom in stopped')
    end
    % alpha_star = default_value?!
end

function alpha = quadraticInterpolation(alpha_lower, alpha_higher, ...
                    v, descentDirection, W, mu1, mu2, mu3)
    phi_dash_alpha_lower = getPhiDerivative( alpha_lower, v, descentDirection, W, mu1, mu2, mu3);
    phi_alpha_lower = getPhiValue( alpha_lower, v, descentDirection, W, mu1, mu2, mu3);
    phi_alpha_higher = getPhiValue( alpha_higher, v, descentDirection, W, mu1, mu2, mu3);
    % find trial step length by using quadratic interpolation
    alpha = -phi_dash_alpha_lower * alpha_higher^2 / ...
        ( 2 * ( phi_alpha_higher - phi_alpha_lower - phi_dash_alpha_lower * alpha_higher));
end

function phi = getPhiValue (alpha, v, descentDirection, W, mu1, mu2, mu3)
    evaluationPoint = v + alpha * descentDirection;
    phi = getCurrentFunctionValue( evaluationPoint, W, mu1, mu2, mu3);
end

function phi_dash = getPhiDerivative( alpha, v, descentDirection, W, mu1, mu2, mu3)
    evaluationPoint = v + alpha * descentDirection;
    phi_dash = descentDirection' * getCurrentGradient(evaluationPoint, W, mu1, mu2, mu3);
end

function functionValue = getCurrentFunctionValue(v, W, mu1, mu2, mu3)
    shift = max(W*v); % corresponds with point which lies furtherst outside of ellipsoid
    energyPart = sum(shift + log(exp(-shift)+exp(W*v - shift)));
    equidistantRadii = (1/v(1) - 1/v(2))^2 + (1/v(3) - 1/v(2))^2 + (1/v(1) - 1/v(3))^2;
    smallRadii = 1/v(1) + 1/v(2) + 1/v(3);
    functionValue = mu1 * energyPart + mu2 * equidistantRadii + mu3 * smallRadii;
end

function derivativeValue = getCurrentGradient(v, W, mu1, mu2, mu3)
    shift = max(W*v);
    energyPart = W'* (exp(W*v - shift)./(exp(- shift) + exp(W*v - shift)) );
    
    equidistantRadii = zeros(10,1);
    equidistantRadii(1) = 2/(v(1))^2 *( 1/v(2) + 1/v(3) - 2/v(1));
    equidistantRadii(1) = 2/(v(2))^2 *( 1/v(1) + 1/v(3) - 2/v(2));
    equidistantRadii(1) = 2/(v(3))^2 *( 1/v(2) + 1/v(1) - 2/v(3));
    
    smallRadii = zeros(10,1);
    smallRadii(1:3) = -1./v(1:3).^2;
    derivativeValue = mu1 * energyPart + mu2 * equidistantRadii + mu3 * smallRadii;
end