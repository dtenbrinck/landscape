%% estimate minimal ellipsoid fitting for data set
function [radii_ref, center_ref ] ...
    = getEllipsoidCharacteristicsReference...
    ( X, fittingParams)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Fit an ellispoid/sphere to a set of xyz data points:
%
%   [radii_ref, center_ref ] = estimateMinimumEllipsoid( X, fittingParams )
%   [radii_ref, center_ref ] = estimateMinimumEllipsoid( [x y z], fittingParams );
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
% * evecs     -  the radii directions as columns of the 3x3 matrix
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
[~, X, pca_transformation] = prepareCoordinateMatrixAndOrientationMatrix(X);
[v_initial] = initializeEllipsoidParams(X);

funct = @(v) fittingParams.regularisationParams.mu0 * ( fittingParams.regularisationParams.gamma*sum(...
    log( 1 + exp( 1/fittingParams.regularisationParams.gamma * (W*v + (v(4)^2/v(1) + v(5)^2/v(2) + v(6)^2/v(3) - 1)) ) ) ) + ...
    ... % volumetric reguliser
    fittingParams.regularisationParams.mu1 * ( 1/v(1) + 1/v(2) + 1/v(3) )  + ...
    fittingParams.regularisationParams.mu2 * sum(( W*v + (v(4)^2/v(1) + v(5)^2/v(2) + v(6)^2/v(3) - 1)).^2) );

[radii_ref, center_ref] = getReferenceEllipsoidApproximation(funct, v_initial);

% invert coordinate transformation caused by PCA back for center vectors
center_ref = pca_transformation \ center_ref;
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
        pca_transformation = (pca(X))';
        X = (pca_transformation * X')';
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


function [radii, center] = getReferenceEllipsoidApproximation(funct, v0)
%     fprintf('Approximate ellipsoid with MATLAB reference method...\n');
    options = optimset('TolX', 1e-8, 'TolFun', 1e-8);
    tic;
    [v, ~,~,output] = fminsearch(funct, v0, options);
    time = toc;
    fprintf ('Matlab reference stopped after %d iteration(s) in %f seconds. \n', output.iterations, time);
%     fprintf('########## ref. energy \t %e \t \t\n', funct(v));
    [radii, center] = getEllipsoidParams(v);
end