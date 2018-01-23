function [ ellipsoid ] = estimateEmbryoSurface( nuclei_coord, resolution )
Y = (nuclei_coord(1,:) * resolution(1))';
X = (nuclei_coord(2,:) * resolution(2))';
Z = (nuclei_coord(3,:) * resolution(3))';

% fit ellipsoid to sharp points in areas in focus
[ ellipsoid.center, ellipsoid.radii, ellipsoid.axes, ellipsoid.v, ~] = estimateEllipsoid( [ X Y Z ], '' );


% check axes orientation and flip if necessary
orientation = diag(ellipsoid.axes);
for i=1:3
    if orientation(i) < 0
        ellipsoid.axes(:,i) = -ellipsoid.axes(:,i);
    end
end

% % show nuclei
% figure; scatter3(nucleiCoordinates(:,1), nucleiCoordinates(:,2), nucleiCoordinates(:,3));
% 
% % render ellipsoid
% mind = [1 1 1]; maxd = size(sharp_areas) .* resolution;
% nsteps = maxd * 0.15;
% step = ( maxd - mind ) ./ nsteps;
% [ x, y, z ] = meshgrid( linspace( mind(2) - step(2), maxd(2) + step(2), nsteps(2) ), linspace( mind(1) - step(1), maxd(1) + step(1), nsteps(1) ), linspace( mind(3) - step(3), maxd(3) + step(3), nsteps(3) ) );
% %[x, y, z] = meshgrid(1:maxd(1), 1:maxd(2), 1:maxd(3));
% 
% Ellipsoid = v(1) *x.*x +   v(2) * y.*y + v(3) * z.*z + ...
%     2*v(4) *x.*y + 2*v(5)*x.*z + 2*v(6) * y.*z + ...
%     2*v(7) *x    + 2*v(8)*y    + 2*v(9) * z;
% figure;
% p = patch( isosurface( x, y, z, Ellipsoid, -1*v(10) ) );
% set( p, 'FaceColor', 'g', 'EdgeColor', 'none' );
% view( -70, 40 );
% axis vis3d equal;
% %resolution = [1.720000000000000   1.720000000000000  20];
% %daspect(resolution(3)./resolution)
% camlight;
% lighting phong;
% 
% 
% 
% %DEBUG
% transformedCoordinates = (transform_normalization * (nucleiCoordinates - repmat(center', size(nucleiCoordinates,1), 1))')';
% 
% % estimate embryo shape by fitting ellipsoid to sharp areas
% [center, radii, axes, v, ~] = fitEllipsoid(transformedCoordinates, [1/32 1/32 1/32]);
% 
% scatter3(transformedCoordinates(:,1), transformedCoordinates(:,2), transformedCoordinates(:,3));
% 
% 
% % render ellipsoid
% 
% %[x, y, z] = meshgrid(1:maxd(1), 1:maxd(2), 1:maxd(3));
% 
% Ellipsoid = v(1) *x.*x +   v(2) * y.*y + v(3) * z.*z + ...
%     2*v(4) *x.*y + 2*v(5)*x.*z + 2*v(6) * y.*z + ...
%     2*v(7) *x    + 2*v(8)*y    + 2*v(9) * z;
% figure;
% p = patch( isosurface( x, y, z, Ellipsoid, -1*v(10) ) );
% set( p, 'FaceColor', 'g', 'EdgeColor', 'none' );
% view( -70, 40 );
% axis vis3d equal;
% %resolution = [1.720000000000000   1.720000000000000  20];
% %daspect(resolution(3)./resolution)
% camlight;
% lighting phong;

end

