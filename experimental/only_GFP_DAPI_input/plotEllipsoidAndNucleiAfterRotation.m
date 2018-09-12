function plotEllipsoidAndNucleiAfterRotation (nucleiOrigCoord, ellipsoidEstimation, expNumber, resolution, rotationMatrix, transformationMatrix)
    X(:,1) = (nucleiOrigCoord(1,:) * resolution(1))';
    X(:,2) = (nucleiOrigCoord(2,:) * resolution(2))';
    X(:,3) = (nucleiOrigCoord(3,:) * resolution(3))';
    rng(0,'twister');
    idx = randperm( size(X,1), ceil(10/100*size(X,1)));
    X = X(idx,:);

    center = ellipsoidEstimation.center;
    axes = ellipsoidEstimation.axes;
    n = 20;
    [x_ellipsoid,y_ellipsoid,z_ellipsoid] = ellipsoid(0, 0, 0, ellipsoidEstimation.radii(1), ellipsoidEstimation.radii(2), ellipsoidEstimation.radii(3), n-1);
    
    fprintf("Plotting resulting ellipsoid estimation...\n");
    rotatedCoordinates = axes' * [reshape(x_ellipsoid,1,n*n); reshape(y_ellipsoid,1,n*n); reshape(z_ellipsoid,1,n*n)];
    [x,y,z] = reshapeXYZ(rotatedCoordinates, center, n);
    
    figure('Units', 'normalized', 'Position', [0.1 0.1 0.75 0.6]);
    subplot(1,3,1);
    hold on;
    plotEllipsoids(X, x,y,z);
    plotOrientationVectors( center, axes, ellipsoidEstimation.radiiOrderedForPlots);
    title(['radii: ', num2str(ellipsoidEstimation.radiiOrderedForPlots(1)), ' \mum, \newline', ...
        num2str(ellipsoidEstimation.radiiOrderedForPlots(2)), ' \mum, \newline', ...
        num2str(ellipsoidEstimation.radiiOrderedForPlots(3)), ' \mum'], 'Interpreter', 'tex'); 

    fprintf("Plotting resulting rotated ellipsoid estimation...\n");
    X = (rotationMatrix' * X')';
    center = rotationMatrix' * ellipsoidEstimation.center;
    rotatedCoordinates = rotationMatrix' * axes' * [reshape(x_ellipsoid,1,n*n); reshape(y_ellipsoid,1,n*n); reshape(z_ellipsoid,1,n*n)];
    [x,y,z] = reshapeXYZ(rotatedCoordinates, center, n);
    subplot(1,3,2);
    hold on;
    plotEllipsoids(X, x,y,z);
    plotOrientationVectors( center, (rotationMatrix' * axes')', ellipsoidEstimation.radiiOrderedForPlots);
    title(['rotated ellipsoid estimation'], 'Interpreter', 'tex'); 
    
    fprintf("Plotting resulting ellipsoid estimation after registration...\n");    
    X(:,1) = ((nucleiOrigCoord(1,:) * resolution(1))' - ellipsoidEstimation.center(1) );
    X(:,2) = ((nucleiOrigCoord(2,:) * resolution(2))' - ellipsoidEstimation.center(2) );
    X(:,3) = ((nucleiOrigCoord(3,:) * resolution(3))' - ellipsoidEstimation.center(3) );
    X = ((transformationMatrix * rotationMatrix')\  X')';
    rotatedCoordinates = (transformationMatrix * rotationMatrix' )\ ( axes' * [reshape(x_ellipsoid,1,n*n); reshape(y_ellipsoid,1,n*n); reshape(z_ellipsoid,1,n*n)]);
    [x,y,z] = reshapeXYZ(rotatedCoordinates, [0,0,0], n);
    
    subplot(1,3,3);
    hold on;
    plotEllipsoids(X, x,y,z);
    plotOrientationVectors( [0,0,0], ((transformationMatrix * rotationMatrix' )\ axes')',  ellipsoidEstimation.radiiOrderedForPlots);
    title(['scaled and rotated ellipsoid estimation'], 'Interpreter', 'tex'); 
    

    savefig(gcf, ['_' num2str(expNumber) '_rotated_ellipsoid.fig']);
    close(gcf);
end

function plotEllipsoids(X, x,y,z)
    scatter3(X(:,1),X(:,2), X(:,3),'b','.', 'DisplayName', 'input data', 'MarkerFaceAlpha',0.1);     
    surf(x,y,z, 'FaceAlpha',0.15, 'FaceColor', 'm', 'EdgeColor', 'none', 'DisplayName', 'estimated ellipsoid');
    view(90, 0);
    axis equal;
    legend('Location', 'southoutside');
end

function [x,y,z] = reshapeXYZ(rotatedCoordinates, center, n)
    x = reshape(rotatedCoordinates(1, : ), [n, n]);
    y = reshape(rotatedCoordinates(2, : ), [n, n]);
    z = reshape(rotatedCoordinates(3, : ), [n, n]);
    x = x + center(1);
    y = y + center(2);
    z = z + center(3); 
end

function plotOrientationVectors( center, axis, radii)
    quiver3( center(1), center(2), center(3), radii(1)*axis(1,1), radii(1)*axis(2,1), radii(1)*axis(3,1), 'k', 'LineWidth', 2, 'Displayname','first axis'); hold on;
    quiver3( center(1), center(2), center(3), radii(2)*axis(1,2), radii(2)*axis(2,2), radii(2)*axis(3,2), 'r', 'LineWidth', 2, 'Displayname','second axis');hold on;
    quiver3( center(1), center(2), center(3), radii(3)*axis(1,3), radii(3)*axis(2,3), radii(3)*axis(3,3), 'g', 'LineWidth', 2, 'Displayname','third axis');
end