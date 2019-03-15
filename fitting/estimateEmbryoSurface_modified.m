function [ ellipsoidEstimation ] = estimateEmbryoSurface_modified( nuclei_coord, resolution, ellipsoidFittingParams, result_path)
X(:,1) = (nuclei_coord(1,:) * resolution(1))';
X(:,2) = (nuclei_coord(2,:) * resolution(2))';
X(:,3) = (nuclei_coord(3,:) * resolution(3))';

%% fit ellipsoid to sharp points in areas in focus
rng(0,'twister');
idx = randperm( size(X,1), ceil(ellipsoidFittingParams.percentage/100*size(X,1)));
X = X(idx,:);

[ ellipsoidEstimation.center, ellipsoidEstimation.radii, ellipsoidEstimation.axes, max_iterations_reached] = ...
    getEllipsoidCharacteristicsEstimation_modified...
    ( X, ellipsoidFittingParams );

%% plot fitted ellipsoid
if (  ellipsoidFittingParams.visualization ) 
   fprintf('Plotting resulting ellipsoid estimation...\n');
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
    axis equal;
    axis off;
    title(['radii: ', num2str(ellipsoidEstimation.radii(1)), ' \mum, \newline', ...
        num2str(ellipsoidEstimation.radii(2)), ' \mum, \newline', ...
        num2str(ellipsoidEstimation.radii(3)), ' \mum'], 'Interpreter', 'tex'); 
    legend('Location', 'southoutside');
   end
   if max_iterations_reached
       result_path = [result_path '_max_iterations'];
   end;
    savefig(result_path)
    close()
end

%% check order of ellipsoids axes
% largest absolute values should be on the diagonal
% reorder radii accordingly
orderedRadii = zeros(3,1);
radii = ellipsoidEstimation.radii;
axes = ellipsoidEstimation.axes;
orderedAxes = zeros(3,3);
reducedColums = 1:3;
reducedRows = 1:3;
% put column with max. element in the column corresponding to the found row
[r1, c1] = find(abs(axes) == max(max(abs(axes))));
orderedAxes(:, r1) = axes(:, c1);
orderedRadii(r1) = radii(c1);
% now only consider the remaining columns
reducedColums( reducedColums == c1 ) = [];
reducedRows( reducedRows == r1 ) = [];
reducedAxes = axes(reducedRows, reducedColums);
[r2, c2] = find(abs(reducedAxes) == max(max(abs(reducedAxes))));
% put column with max. element in the column corresponding to the found row
% considering only the remaining rows
orderedAxes(:, reducedRows(r2)) = axes(:, reducedColums(c2));
orderedRadii(reducedRows(r2)) = radii(reducedColums(c2));
% find out last remaining column and put it in the still empty column
% corresponding to the remaining row element
reducedColums( reducedColums == reducedColums(c2) ) = [];
reducedRows( reducedRows == reducedRows(r2) ) = [];
orderedAxes(:, reducedRows) = axes(:, reducedColums);
orderedRadii(reducedRows) = radii(reducedColums);
for i=1:3
    %% check ellipsoid's axes orientation and flip if necessary
    if (orderedAxes(i,i) < 0 )
        orderedAxes(:, i) = -orderedAxes(:, i);
    end
end
ellipsoidEstimation.axes = orderedAxes;
ellipsoidEstimation.radiiOrderedForPlots = orderedRadii;

end
