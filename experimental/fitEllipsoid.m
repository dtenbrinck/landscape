function [center radii axes v] = fitEllipsoid( sharp_areas, resolution )
%FITELLIPSOID Summary of this function goes here
%   Detailed explanation goes here

% use visualization for debugging
visualize = true;

% determine global threshold to detect sharp areas
threshold = kittler_thresholding(sharp_areas);

% embed data points in bigger domain
%sharp_areas = padarray(sharp_areas, [150 150 5], 0);
%large_domain = zeros(size(sharp_areas) .* [1 1 2]);
%large_domain(:,:,1:end/2) = sharp_areas;
large_domain = sharp_areas;
%sharp_areas = tmp;

% determine sharp points
sharp_points = find(large_domain > threshold);

% convert indices to coordinates
[Y, X, Z] = ind2sub(size(large_domain),sharp_points);

% Q = [X.^2 Y.^2 Z.^2 X.*Y Y.* X.*Z X Y Z];
% R= [ones(size(sharp_points))];
% %b=[A;B;C;D;E;F;G;H;I];
%
% b = Q \ R;

Y = Y * resolution(1);
X = X * resolution(2);
Z = Z * resolution(3);

% fit ellipsoid to sharp points in areas in focus
[ center, radii, axes, v, chi2 ] = ellipsoid_fit( [ X Y Z ], '' );

%v = v*2;

% visualize fitted ellipsoid if needed
if visualize
  figure;
  
  %draw fit
  %mind = min( [ x y z ] );
  %maxd = max( [ x y z ] );
  mind = [1 1 1]; maxd = size(large_domain) .* resolution;
  nsteps = maxd * 0.15;
  step = ( maxd - mind ) ./ nsteps;
  [ x, y, z ] = meshgrid( linspace( mind(1) - step(1), maxd(1) + step(1), nsteps(1) ), linspace( mind(2) - step(2), maxd(2) + step(2), nsteps(2) ), linspace( mind(3) - step(3), maxd(3) + step(3), nsteps(3) ) );
  %[x, y, z] = meshgrid(1:maxd(1), 1:maxd(2), 1:maxd(3));
  
  Ellipsoid = v(1) *x.*x +   v(2) * y.*y + v(3) * z.*z + ...
    2*v(4) *x.*y + 2*v(5)*x.*z + 2*v(6) * y.*z + ...
    2*v(7) *x    + 2*v(8)*y    + 2*v(9) * z;
  p = patch( isosurface( x, y, z, Ellipsoid, -1*v(10) ) );
  set( p, 'FaceColor', 'g', 'EdgeColor', 'none' );
  view( -70, 40 );
  axis vis3d equal;
  %resolution = [1.720000000000000   1.720000000000000  20];
  %daspect(resolution(3)./resolution)
  camlight;
  lighting phong;
  
  hold on
  plot3( X, Y, Z, '.r' );
  hold off
  %pause;
  
  % visualize slice by slice
  mind = [1 1 1]; maxd = size(sharp_areas) .* resolution;
  nsteps = size(sharp_areas);
  step = ( maxd - mind ) ./ nsteps;
  [ x, y, z ] = meshgrid( linspace( mind(2) - step(2), maxd(2) + step(2), nsteps(2) ), linspace( mind(1) - step(1), maxd(1) + step(1), nsteps(1) ), linspace( mind(3) - step(3), maxd(3) + step(3), nsteps(3) ) );
  Ellipsoid = v(1) *x.*x +   v(2) * y.*y + v(3) * z.*z + ...
    2*v(4) *x.*y + 2*v(5)*x.*z + 2*v(6) * y.*z + ...
    2*v(7) *x    + 2*v(8)*y    + 2*v(9) * z;
  
  for i=1:size(sharp_areas,3)
    figure(2); imagesc(sharp_areas(:,:,i), [min(sharp_areas(:)) max(sharp_areas(:))]); colormap gray;
    hold on
    [contourMatrix, handle] = contour(Ellipsoid(:,:,i), [0.98 0.98], 'r');
    set(handle, 'LineWidth', 2);
    set(gca,'YDir','reverse');
    drawnow;
    hold off
    print(['results/dapi_' sprintf('%02d',i) ],'-dpng');
    %pause;
  end
end

%%% DOESN'T WORK YET
% % guess initial center
% initialCenter = center;
% initialA = eye(3);
% initialA(1) = initialCenter(1);
% initialA(5) = initialCenter(2);
% initialA(9) = initialCenter(3);
%
% % fit best ellipsoid using Gauss-Newton approach
% [center A] = gaussNewtonEllipsoid(cat(1,y',x',z'), initialCenter, initialA);

end

