function plotEllipsoidAndNucleiAfterRotation (nucleiOrigCoord, ellipsoidEstimation, expNumber, rotationMatrix)
   nuclei = (rotationMatrix' * nucleiOrigCoord)';
   fprintf("Plotting resulting ellipsoid estimation...\n");
   if isreal(ellipsoidEstimation.center) && isreal(ellipsoidEstimation.radii)
    figure;
    hold on;
    scatter3(nuclei(:,1),nuclei(:,2), nuclei(:,3),'b','.', 'DisplayName', 'input data', 'MarkerFaceAlpha',0.1);
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
    axis equal;
    axis off;
    title(['radii: ', num2str(ellipsoidEstimation.radii(1)), ' \mum, \newline', ...
        num2str(ellipsoidEstimation.radii(2)), ' \mum, \newline', ...
        num2str(ellipsoidEstimation.radii(3)), ' \mum'], 'Interpreter', 'tex'); 
    legend('Location', 'southoutside');
   end
    savefig(gcf, ['_' num2str(expNumber) '_rotated_ellipsoid.fig']);

end