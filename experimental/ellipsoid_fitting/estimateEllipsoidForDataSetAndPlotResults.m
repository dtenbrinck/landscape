function estimateEllipsoidForDataSetAndPlotResults(X, descentMethod, regularisationParams, outputPath, isPCAactive, title)
    %fprintf('\n');
    [center, radii, axis, radii_ref, center_ref, radii_initial, center_initial] = getEllipsoidCharacteristicsInitialReferenceEstimation( X, descentMethod, regularisationParams, isPCAactive );
    table( radii_initial, radii, radii_ref)
    table( center_initial, center, center_ref )
%       return;
    % plot ellipsoid fittings
    fprintf('Plotting results...\n');

    figure;
    titletext = title;
    hold on;
    plotSeveralEllipsoidEstimations(X, center_initial, radii_initial,...
        center, radii, center_ref, radii_ref, titletext, isPCAactive, axis);
    plotOrientationVectors( center, axis);
    descr = {['PCA = ' num2str(isPCAactive)]; 
        ['mu_1 = ' num2str(regularisationParams.mu1)]; 
        ['mu_2 = ' num2str(regularisationParams.mu2)]; 
        ['mu_3 = ' num2str(regularisationParams.mu3)]};
    yl = ylim; zl = zlim; zt = zticks;
    text(0,yl(1),zl(1)-2*(zt(2)-zt(1)),descr);
    print("results/" + outputPath + ".png",'-dpng');
end

function plotOrientationVectors( center, axis)
    axis= 100*axis;
    quiver3( center(1), center(2), center(3), axis(1,1), axis(2,1), axis(3,1), 'k', 'LineWidth', 2, 'Displayname','first axis');
    quiver3( center(1), center(2), center(3), axis(1,2), axis(2,2), axis(3,2), 'r', 'LineWidth', 2, 'Displayname','second axis');
    quiver3( center(1), center(2), center(3), axis(1,3), axis(2,3), axis(3,3), 'b', 'LineWidth', 2, 'Displayname','third axis');
end

function plotSeveralEllipsoidEstimations(X, center_initial, radii_initial,...
        center, radii, center_ref, radii_ref, titletext, isPCAactive, axis)
    scatter3(X(:,1),X(:,2), X(:,3),'b','.', 'DisplayName', 'input data', 'MarkerFaceAlpha',0.1);
    plotOneEllipsoidEstimation( center, radii, 'm', 'ellipsoid estimation', isPCAactive, axis);
    plotOneEllipsoidEstimation( center_ref, radii_ref, 'c','reference estimation', isPCAactive, axis);
%     plotOneEllipsoidEstimation( center_initial, radii_initial, [0.9100    0.4100    0.1700] , 'initialization ellipsoid', isPCAactive, axis);
    plotOldEllipsoidEstimation(X, 'g', 'old estimation');
    legend('Location', 'southoutside');
    title(titletext, 'Interpreter', 'none');
    view(90, 0);%(3);%
end

function plotOldEllipsoidEstimation(X, color, displayname)
    %fprintf('Using least squares approximation to estimate another reference ellipsoid...\n');
    [ center, radii, axes, ~, ~] = estimateEllipsoid( X, '' );
    plotOneEllipsoidEstimation( center, radii, color, displayname, 1, axes);
    fprintf('old radii: \n');
    table(radii)
end

function plotOneEllipsoidEstimation( center, radii, color, displayname, isPCAactive, axis)
    if isreal(center) && isreal(radii)
        n = 20;
        [x,y,z] = ellipsoid(0, 0, 0, radii(1), radii(2), radii(3), n-1);
        if ( isPCAactive )
            rotatedCoordinates = axis' * [reshape(x,1,n*n); reshape(y,1,n*n); reshape(z,1,n*n)];
            x = reshape(rotatedCoordinates(1, : ), [n, n]);
            y = reshape(rotatedCoordinates(2, : ), [n, n]);
            z = reshape(rotatedCoordinates(3, : ), [n, n]);
        end
        x = x + center(1);
        y = y + center(2);
        z = z + center(3);
        surf(x,y,z, 'FaceAlpha',0.15, 'FaceColor', color, 'EdgeColor', 'none', 'DisplayName', displayname);
    end
end

