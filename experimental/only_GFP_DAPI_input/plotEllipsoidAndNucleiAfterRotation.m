function plotEllipsoidAndNucleiAfterRotation (nucleiOrigCoord, ellipsoidEstimation, expNumber, resolution, rotationMatrix, transformationMatrix)
    X(:,1) = (nucleiOrigCoord(1,:) * resolution(1))';
    X(:,2) = (nucleiOrigCoord(2,:) * resolution(2))';
    X(:,3) = (nucleiOrigCoord(3,:) * resolution(3))';
    center = ellipsoidEstimation.center;
    axes = ellipsoidEstimation.axes;

    fprintf("Plotting resulting ellipsoid estimation...\n");
    figure('Units', 'normalized', 'Position', [0.1 0.1 0.75 0.6]);
    subplot(1,3,1);
    hold on;
    scatter3(X(:,1),X(:,2), X(:,3),'b','.', 'DisplayName', 'input data', 'MarkerFaceAlpha',0.1);
    n = 20;
    [x,y,z] = ellipsoid(0, 0, 0, ellipsoidEstimation.radii(1), ellipsoidEstimation.radii(2), ellipsoidEstimation.radii(3), n-1);
    rotatedCoordinates = axes' * [reshape(x,1,n*n); reshape(y,1,n*n); reshape(z,1,n*n)];
    x = reshape(rotatedCoordinates(1, : ), [n, n]);
    y = reshape(rotatedCoordinates(2, : ), [n, n]);
    z = reshape(rotatedCoordinates(3, : ), [n, n]);
    x = x + center(1);
    y = y + center(2);
    z = z + center(3);
    surf(x,y,z, 'FaceAlpha',0.15, 'FaceColor', 'm', 'EdgeColor', 'none', 'DisplayName', 'estimated ellipsoid');
    view(90, 0);
    axis equal;
    %axis off;
    title(['radii: ', num2str(ellipsoidEstimation.radii(1)), ' \mum, \newline', ...
        num2str(ellipsoidEstimation.radii(2)), ' \mum, \newline', ...
        num2str(ellipsoidEstimation.radii(3)), ' \mum'], 'Interpreter', 'tex'); 
    legend('Location', 'southoutside');

    fprintf("Plotting resulting rotated ellipsoid estimation...\n");
    X = (rotationMatrix' * X')';
    center = rotationMatrix' * ellipsoidEstimation.center;
    
    subplot(1,3,2);
    hold on;
    scatter3(X(:,1),X(:,2), X(:,3),'b','.', 'DisplayName', 'input data', 'MarkerFaceAlpha',0.1);
    n = 20;
    [x,y,z] = ellipsoid(0, 0, 0, ellipsoidEstimation.radii(1), ellipsoidEstimation.radii(2), ellipsoidEstimation.radii(3), n-1);
    rotatedCoordinates = rotationMatrix' * axes' * [reshape(x,1,n*n); reshape(y,1,n*n); reshape(z,1,n*n)];
    x = reshape(rotatedCoordinates(1, : ), [n, n]);
    y = reshape(rotatedCoordinates(2, : ), [n, n]);
    z = reshape(rotatedCoordinates(3, : ), [n, n]);
    x = x + center(1);
    y = y + center(2);
    z = z + center(3);
    surf(x,y,z, 'FaceAlpha',0.15, 'FaceColor', 'm', 'EdgeColor', 'none', 'DisplayName', 'estimated ellipsoid');
    view(90, 0);
    axis equal;
    %axis off;
    title(['rotated ellipsoid estimation'], 'Interpreter', 'tex'); 
    legend('Location', 'southoutside');
    
    fprintf("Plotting resulting ellipsoid estimation after registration...\n");    
    X(:,1) = ((nucleiOrigCoord(1,:) * resolution(1))' - ellipsoidEstimation.center(1) );
    X(:,2) = ((nucleiOrigCoord(2,:) * resolution(2))' - ellipsoidEstimation.center(2) );
    X(:,3) = ((nucleiOrigCoord(3,:) * resolution(3))' - ellipsoidEstimation.center(3) );
    X = ((transformationMatrix * rotationMatrix')\  X')';
    subplot(1,3,3);
    hold on;
    scatter3(X(:,1),X(:,2), X(:,3),'b','.', 'DisplayName', 'input data', 'MarkerFaceAlpha',0.1);
    n = 20;
    [x,y,z] = ellipsoid(0, 0, 0, ellipsoidEstimation.radii(1), ellipsoidEstimation.radii(2), ellipsoidEstimation.radii(3), n-1);
    rotatedCoordinates = (transformationMatrix * rotationMatrix' )\ ( axes' * [reshape(x,1,n*n); reshape(y,1,n*n); reshape(z,1,n*n)]);
    x = reshape(rotatedCoordinates(1, : ), [n, n]);
    y = reshape(rotatedCoordinates(2, : ), [n, n]);
    z = reshape(rotatedCoordinates(3, : ), [n, n]);
    surf(x,y,z, 'FaceAlpha',0.15, 'FaceColor', 'm', 'EdgeColor', 'none', 'DisplayName', 'estimated ellipsoid');
    view(90, 0);
    axis equal;
    %axis off;
    title(['scaled and rotated ellipsoid estimation'], 'Interpreter', 'tex'); 
    legend('Location', 'southoutside');

    savefig(gcf, ['_' num2str(expNumber) '_rotated_ellipsoid.fig']);
    close(gcf);
end
