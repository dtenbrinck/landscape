function [ ellipsoidEstimation ] = estimateEmbryoSurface( nuclei_coord, resolution, ellipsoidFittingParams)
X(:,1) = (nuclei_coord(1,:) * resolution(1))';
X(:,2) = (nuclei_coord(2,:) * resolution(2))';
X(:,3) = (nuclei_coord(3,:) * resolution(3))';

% fit ellipsoid to sharp points in areas in focus
% TODO add params to parameter file?!
idx = randperm( size(X,1), ceil(ellipsoidFittingParams.percentage/100*size(X,1)));
X = X(idx,:);
[ ellipsoidEstimation.center, ellipsoidEstimation.radii, ellipsoidEstimation.axes, ~,~] = ...
    getEllipsoidCharacteristicsInitialReferenceEstimation...
    ( X, ellipsoidFittingParams, 10^-10 );

% check axes orientation and flip if necessary
orientation = diag(ellipsoidEstimation.axes);
for i=1:3
    if orientation(i) < 0
        ellipsoidEstimation.axes(:,i) = -ellipsoidEstimation.axes(:,i);
    end
end

if (  ellipsoidFittingParams.visualization ) 
   fprintf("Plotting resulting ellipsoid estimation...\n");
   if isreal(ellipsoidEstimation.center) && isreal(ellipsoidEstimation.radii)
    figure;
    hold on;
    scatter3(X(:,1),X(:,2), X(:,3),'b','.', 'DisplayName', 'input data', 'MarkerFaceAlpha',0.1);
    n = 20;
    [x,y,z] = ellipsoid(0, 0, 0, ellipsoidEstimation.radii(1), ellipsoidEstimation.radii(2), ellipsoidEstimation.radii(3), n-1);
    rotatedCoordinates = ellipsoidEstimation.axes' * [reshape(x,1,n*n); reshape(y,1,n*n); reshape(z,1,n*n)];
    x = reshape(rotatedCoordinates(1, : ), [n, n]);
    y = reshape(rotatedCoordinates(2, : ), [n, n]);
    z = reshape(rotatedCoordinates(3, : ), [n, n]);
    x = x + ellipsoidEstimation.center(1);
    y = y + ellipsoidEstimation.center(2);
    z = z + ellipsoidEstimation.center(3);
    surf(x,y,z, 'FaceAlpha',0.15, 'FaceColor', 'm', 'EdgeColor', 'none', 'DisplayName', 'estimated ellipsoid');
    view(90, 0);
    legend('Location', 'southoutside');
    end
end
end

