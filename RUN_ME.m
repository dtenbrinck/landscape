% Script for registration of confocal microscopy data of small fish
% embryos.
%
%   Copyright: Daniel Tenbrinck
%   Department of Mathematics and Computer Science
%   University of Muenster, Germany
%   email: daniel.tenbrinck@wwu.de
%   $Date: 2016/02/18 $

% tidy up memory and windows before starting
clear; close all; clc;

% get all subdirectories
addpath(genpath(pwd));

% load the data
load('1a3.mat');

% set rescaling factor for dapi channel
scale = 0.5;

% set resolution for data in micrometers
resolution = [1.29/scale, 1.29/scale, 20];

% rescale image size using trilinear interpolation for higher speed
for i=1:size(data.Dapi,3)
  dapi_resized(:,:,i) = imresize(data.Dapi(:,:,i), scale);
  gfp_resized(:,:,i) = imresize(data.GFP(:,:,i), scale); % coarse data for segmentation sufficient
  mCherry_resized(:,:,i) = imresize(data.mCherry(:,:,i), scale);
end

% normalize data
dapi_resized = normalizeData(dapi_resized);           % embryo membrane
gfp_resized = normalizeData(gfp_resized);             % landmark
mCherry_resized = normalizeData(mCherry_resized);     % labeled cells

% generate three-dimensional Gaussian filter
g = generate3dGaussian(9, 1.5);

% denoise image by blurring
blurred = imfilter(dapi_resized, g, 'same','replicate');

% generate a three-dimensional Laplacian filter
kernelLaplace = generate3dLaplacian(resolution);

% determine sharp areas by Laplacian filtering
sharp_areas = normalizeData (imfilter(blurred, kernelLaplace, 'same', 'replicate'));

% estimate focus of images by fitting circles
[center radii axes v] = fitEllipsoid(sharp_areas, resolution);

% segment gfp landmark
landmark_resized = segmentGFP(gfp_resized, resolution);

% delete old variable
clear gfp_resized;

% rescale gfp data and gfp landmark to higher resolution
for i=1:size(data.Dapi,3)
 landmark(:,:,i) = imresize(landmark_resized(:,:,i), size(dapi_resized(:,:,1)), 'nearest');
 gfp_resized(:,:,i) = imresize(data.GFP(:,:,i), scale);
end

% segment cells -> TODO: Blur due to PSF
cells = segmentCells( mCherry_resized, resolution );

% sample original space
mind = [0 0 0]; maxd = size(landmark) .* resolution;
%nsteps = maxd*0.2;
%step = ( maxd - mind ) ./ nsteps;
%[ x, y, z ] = meshgrid( linspace( mind(2) - step(2), maxd(2) + step(2), nsteps(2) ), linspace( mind(1) - step(1), maxd(1) + step(1), nsteps(1) ), linspace( mind(3) - step(3), maxd(3) + step(3), nsteps(3) ) );
[ x, y, z ] = meshgrid( linspace( mind(2), maxd(2), size(landmark,2) ), linspace( mind(1), maxd(1), size(landmark,1) ), linspace( mind(3), maxd(3), size(landmark,3) ) );

% [ x_coarse, y_coarse, z_coarse] = meshgrid( linspace( mind(2) - step(2), maxd(2) + step(2), size(landmark,2) ), linspace( mind(1) - step(1), maxd(1) + step(1), size(landmark,1) ), linspace( mind(3) - step(3), maxd(3) + step(3), size(landmark,3) ) );
% Ellipsoid = v(1) *x.*x +   v(2) * y.*y + v(3) * z.*z + ...
%     2*v(4) *x.*y + 2*v(5)*x.*z + 2*v(6) * y.*z + ...
%     2*v(7) *x    + 2*v(8)*y    + 2*v(9) * z -1;
% 
% landmark_fine = interp3(x_coarse, y_coarse, z_coarse, landmark, x, y, z, 'nearest');
  
%validGFP = landmark_fine .* (abs(Ellipsoid) < 0.01);

% visualize and save result in 3D
%renderGFPsurface(Ellipsoid, landmark_fine, [1 1 1],x,y,z)


% determine the transformation
scale_matrix = eye(3);
scale_matrix(1) = 1/radii(1);
scale_matrix(5) = 1/radii(2);
scale_matrix(9) = 1/radii(3);
rotation_matrix = axes';
transform = scale_matrix * rotation_matrix;


% transform back to unit sphere
%mind = [-1 -1 -1]; maxd = [1 1 1];
%nsteps = [64 64 64];
%step = ( maxd - mind ) ./ nsteps;


%[xu yu zu] = meshgrid( linspace( mind(2) - step(2), maxd(2) + step(2), nsteps(2) ), linspace( mind(1) - step(1), maxd(1) + step(1), nsteps(1) ), linspace( mind(3) - step(3), maxd(3) + step(3), nsteps(3) ));

% sample surface of unit sphere
samples = 64;
[alpha, beta] = meshgrid(linspace(0,2*pi,samples), linspace(0,2*pi,samples));
x_s=  cos(alpha) .* cos(beta);
y_s = sin(alpha) .* cos(beta);
z_s = sin(beta);

% determine position of spherical points in original space
xs_t = x_s;
ys_t = y_s;
zs_t = z_s;
for i = 1:numel(xs_t)  
  new_coordinate = transform^-1 * [xs_t(i), ys_t(i), zs_t(i)]';
  xs_t(i) = new_coordinate(1) + center(1);
  ys_t(i) = new_coordinate(2) + center(2);
  zs_t(i) = new_coordinate(3) + center(3);
end

% interpolate signal on unit sphere transformed to original space
GFPOnSphere = interp3(x, y, z, landmark, xs_t, ys_t, zs_t,'nearest');


% sample unit cube
[xu, yu, zu] = meshgrid(linspace(-1,1,samples), linspace(-1,1,samples), linspace(-1,1,samples));

% determine position of points in unit cube in original space
xu_t = xu;
yu_t = yu;
zu_t = zu;
for i = 1:numel(xu_t)  
  new_coordinate = transform^-1 * [xu_t(i), yu_t(i), zu_t(i)]';
  xu_t(i) = new_coordinate(1) + center(1);
  yu_t(i) = new_coordinate(2) + center(2);
  zu_t(i) = new_coordinate(3) + center(3);
end

% interpolate signal on unit sphere transformed to original space
CellsInSphere = interp3(x, y, z, cells, xu_t, yu_t, zu_t,'nearest');

figure;
renderCellsInSphere(CellsInSphere,xu,yu,zu);
hold on;
scatter3(x_s(:), y_s(:), z_s(:),10,[0 1 0]);
scatter3(x_s(GFPOnSphere == 1 & z_s <= 0), y_s(GFPOnSphere == 1 & z_s <= 0), z_s(GFPOnSphere == 1 & z_s <= 0),50,[1 0 0]); 
hold off;
axis vis3d equal;
view([-37.5, -75])