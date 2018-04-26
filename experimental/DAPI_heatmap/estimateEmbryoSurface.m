function [ ellipsoid ] = estimateEmbryoSurface( nuclei_coord, resolution )
X = (nuclei_coord(1,:) * resolution(1))';
Y = (nuclei_coord(2,:) * resolution(2))';
Z = (nuclei_coord(3,:) * resolution(3))';

% fit ellipsoid to sharp points in areas in focus
[ellipsoid.center, ellipsoid.radii, ellipsoid.axes] = findMinimumEllipsoid([ X Y Z ]);
% [ ellipsoid.center, ellipsoid.radii, ellipsoid.axes, ellipsoid.v, ~] = estimateEllipsoid( [ X Y Z ], '' );

% check axes orientation and flip if necessary
orientation = diag(ellipsoid.axes);
for i=1:3
    if orientation(i) < 0
        ellipsoid.axes(:,i) = -ellipsoid.axes(:,i);
    end
end

end

function [center, radii, axes] = findMinimumEllipsoid(X)
    if size( X, 2 ) ~= 3
		error( 'Input data must have three columns!' );
    end
	% PCA: transform data points to an ellipsoid with axes along the coordinate axes
	pca_transformation = (pca(X))';
	X = (pca_transformation * X')';
	[W] = prepareCoordinateMatrix(X);
	
	[v] = initializeEllipsoidParams(X);
    regularisationParams.mu0 = 10^-8;
    regularisationParams.mu1 = 0; 
    regularisationParams.mu2 = 0.02; 
    regularisationParams.mu3 = 1;
    regularisationParams.gamma = 1; 
	[ funct ] = initializeEnergyFunction(W, regularisationParams);
	[radii, center] = estimatedMinimumEllipsoid(v, funct);
	% invert coordinate transformation caused by PCA back for center vectors
	center = pca_transformation \ center;
	axes = pca_transformation';
end

function [W] = prepareCoordinateMatrix(X)
    % need 6 or more data points
    if size( X, 1 ) < 6 
       error( 'Must have at least 6 points to approximate an ellipsoidal fitting.' );
    end

    W = [ X( :, 1 ) .* X( :, 1 ), ...
        X( :, 2 ) .* X( :, 2 ), ...
        X( :, 3 ) .* X( :, 3 ), ...
        2 * X( :, 1 ), ...
        2 * X( :, 2 ), ...
        2 * X( :, 3 )];  % ndatapoints x 6 ellipsoid parameters
end

function [v] = initializeEllipsoidParams(X)
    if size( X, 2 ) ~= 3
		error( 'Input data must have three columns!' );
    end
	center=[mean(X( :, 1 )); mean(X( :, 2 )); min(X( :, 3 )) + range(X( :, 3 )) * 50/60];
	radiiComponent = max(sqrt(sum((X-center') .* (X-center'), 2)));
	radii=[radiiComponent; radiiComponent; radiiComponent];
	v=zeros(6,1);
	v(1:3) = (1./radii).^2;
	v(4:6) = - center .* v(1:3);
end

function [radii, center] = estimatedMinimumEllipsoid(v, funct)
	fprintf('Approximate ellipsoid with MATLAB reference method...\n');
	%     options = optimset('OutputFcn', @outfun);
	%     other input params: 'PlotFcns', @optimplotfval, options, 'Display','notify', 
		options = optimset('TolX', 1e-8, 'TolFun', 1e-8);
	[v] = fminsearch(funct, v, options);
	radii = sqrt( 1 ./ v(1:3) ) ;
	center = - v(4:6) ./ v(1:3);
end


function [ funct ] = initializeEnergyFunction(W, regularisationParams)
funct = @(v) regularisationParams.mu0 * ( regularisationParams.gamma*sum(...
    log( 1 + exp( 1/regularisationParams.gamma * (W*v + (v(4)^2/v(1) + v(5)^2/v(2) + v(6)^2/v(3) - 1)) ) ) ) + ...
    regularisationParams.mu1 * ( (v(1) - v(2))^2 + (v(3) - v(2))^2 + (v(1) - v(3))^2 )+ ...
    regularisationParams.mu2 * ( 1/v(1) + 1/v(2) + 1/v(3) )  + ...
    regularisationParams.mu3 * sum(( W*v + (v(4)^2/v(1) + v(5)^2/v(2) + v(6)^2/v(3) - 1)).^2));
end