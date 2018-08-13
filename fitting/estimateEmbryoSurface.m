function [ ellipsoidEstimation ] = estimateEmbryoSurface( nuclei_coord, resolution, ellipsoidFittingParams)
X(:,1) = (nuclei_coord(1,:) * resolution(1))';
X(:,2) = (nuclei_coord(2,:) * resolution(2))';
X(:,3) = (nuclei_coord(3,:) * resolution(3))';

%% fit ellipsoid to sharp points in areas in focus
idx = randperm( size(X,1), ceil(ellipsoidFittingParams.percentage/100*size(X,1)));
X = X(idx,:);
[ ellipsoidEstimation.center, ellipsoidEstimation.radii, ellipsoidEstimation.axes] = ...
    getEllipsoidCharacteristicsEstimation...
    ( X, ellipsoidFittingParams );


figure;
center = ellipsoidEstimation.center; axis = ellipsoidEstimation.axes;
quiver3( center(1), center(2), center(3), axis(1,1), axis(2,1), axis(3,1), 'k:', 'LineWidth', 2, 'Displayname','first axis before flipping'); hold on;
quiver3( center(1), center(2), center(3), axis(1,2), axis(2,2), axis(3,2), 'r:', 'LineWidth', 2, 'Displayname','second axis before flipping');hold on;
quiver3( center(1), center(2), center(3), axis(1,3), axis(2,3), axis(3,3), 'b:', 'LineWidth', 2, 'Displayname','third axis before flipping');
hold on;

%% check order of ellipsoids axes
% largest absolute values should be on the diagonal
orderedAxes = zeros(3,3);
axes = ellipsoidEstimation.axes;
axes
for i=1:3
    posLargestColumnElement = find(abs(axes(:,i)) == max(abs(axes(:,i))));
    fprintf('Column %d should be in column %d\n', i, posLargestColumnElement);
    orderedAxes(:, posLargestColumnElement) = axes(:,i);
    %% check ellipsoid's axes orientation and flip if necessary
    if (orderedAxes(posLargestColumnElement,posLargestColumnElement) < 0 )
        orderedAxes(:, posLargestColumnElement) = -orderedAxes(:, posLargestColumnElement);
    end
    orderedAxes
end
ellipsoidEstimation.axes = orderedAxes;
% %% check ellipsoid's axes orientation and flip if necessary
% orientation = diag(ellipsoidEstimation.axes);
% for i=1:3
%     if orientation(i) < 0
%         fprintf('flip ellipsoid orientation along axis %d',i);
%         ellipsoidEstimation.axes(:,i) = -ellipsoidEstimation.axes(:,i);
%     end
% end

%% ceck if axes form right system
cross_prod = cross(ellipsoidEstimation.axes(:,1), ellipsoidEstimation.axes(:,2));
rankAxis= rank([ ellipsoidEstimation.axes(:,3)'; cross_prod']);
if (rankAxis == 1)
   fprintf('We have now have a valid right system!\n'); 
end

center = ellipsoidEstimation.center; axis = ellipsoidEstimation.axes;
quiver3( center(1), center(2), center(3), axis(1,1), axis(2,1), axis(3,1), 'k--', 'LineWidth', 2, 'Displayname','first axis after flipping'); hold on;
quiver3( center(1), center(2), center(3), axis(1,2), axis(2,2), axis(3,2), 'r--', 'LineWidth', 2, 'Displayname','second axis after flipping');hold on;
quiver3( center(1), center(2), center(3), axis(1,3), axis(2,3), axis(3,3), 'b--', 'LineWidth', 2, 'Displayname','third axis after flipping');
title('Flipping axis with neg. diag. element'); legend

%% plot fitted ellipsoid
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

