% Main script for registration of confocal microscopy data of small fish
% embryos.
%
% Data: We assume the data to be already converted from *.STK files given
% by the biologists to *.mat files containing a struct with three fields:
% data
%     .Dapi    -> fluorescence of nuclei near the embryo membrane
%     .GFP     -> fluorescence of anatomic structure denoted as 'landmark'
%     .mCherry -> fluorescence of labeled stem cells in embryo
%
% One is interested in the distribution of the cells in the mCherry data.
% We use the information in the Dapi channel to estimate the shape of the
% embryo and the landmark in the GPF channel for registration of different
% specimen.
%
%   Copyright: Daniel Tenbrinck
%   Department of Mathematics and Computer Science
%   University of Muenster, Germany
%   email: daniel.tenbrinck@wwu.de
%   $Date: 2016/02/18 $

%% initialization

% tidy up memory and windows before starting
clear; close all; clc;

% get all subdirectories
addpath(genpath(pwd));

%% load and preprocess data

% load the data
load('1.mat');

% set rescaling factor
scale = 0.5;

% set resolution for data in micrometers (given by biologists)
resolution = [1.29/scale, 1.29/scale, 20];

% rescale data for higher processing speed using trilinear interpolation
for i=1:size(data.Dapi,3)
  dapi_resized(:,:,i) = imresize(data.Dapi(:,:,i), scale);
  gfp_resized(:,:,i) = imresize(data.GFP(:,:,i), scale); % coarse data for segmentation sufficient
  mCherry_resized(:,:,i) = imresize(data.mCherry(:,:,i), scale);
end

% normalize data
dapi_resized = normalizeData(dapi_resized);           % nuclei in embryo membrane
gfp_resized = normalizeData(gfp_resized);             % landmark
mCherry_resized = normalizeData(mCherry_resized);     % labeled cells

%% estimate shape of embryo from DAPI channel

% generate three-dimensional Gaussian filter
g = generate3dGaussian(9, 1.5);

% denoise DAPI channel by blurring
blurred = imfilter(dapi_resized, g, 'same','replicate');

% generate a three-dimensional Laplacian filter
kernelLaplace = generate3dLaplacian(resolution);

% determine sharp areas in DAPI channel by Laplacian filtering
sharp_areas = normalizeData (imfilter(blurred, kernelLaplace, 'same', 'replicate'));

% estimate embryo shape by fitting ellipsoid to sharp areas
[center radii axes v] = fitEllipsoid(sharp_areas, resolution);

%% segment GFP landmark

% segment gfp landmark
landmark = segmentGFP(gfp_resized, resolution);

%% experimental code for rescaling data with different sizes 
% (some channel work with even less resolution)

% % delete old variable
% clear gfp_resized;
% % rescale gfp data and gfp landmark to higher resolution
% for i=1:size(data.Dapi,3)
%  landmark(:,:,i) = imresize(landmark_resized(:,:,i), size(dapi_resized(:,:,1)), 'nearest');
%  gfp_resized(:,:,i) = imresize(data.GFP(:,:,i), scale);
% end

%% segment stem cells in mCherry channel

% segment cells
cells = segmentCells( mCherry_resized, resolution );

%% transform GFP on embryo shape onto unit sphere

% sample original space
mind = [0 0 0]; maxd = size(landmark) .* resolution;

% experimental code for meshgrid with different resolution
%nsteps = maxd*0.2;
%step = ( maxd - mind ) ./ nsteps;
%[ x, y, z ] = meshgrid( linspace( mind(2) - step(2), maxd(2) + step(2), nsteps(2) ), linspace( mind(1) - step(1), maxd(1) + step(1), nsteps(1) ), linspace( mind(3) - step(3), maxd(3) + step(3), nsteps(3) ) );

% create a meshgrid with same resolution as data
[ x, y, z ] = meshgrid( linspace( mind(2), maxd(2), size(landmark,2) ), linspace( mind(1), maxd(1), size(landmark,1) ), linspace( mind(3), maxd(3), size(landmark,3) ) );

% experimental code to transform data using ellipsoid equation
% [ x_coarse, y_coarse, z_coarse] = meshgrid( linspace( mind(2) - step(2), maxd(2) + step(2), size(landmark,2) ), linspace( mind(1) - step(1), maxd(1) + step(1), size(landmark,1) ), linspace( mind(3) - step(3), maxd(3) + step(3), size(landmark,3) ) );
% Ellipsoid = v(1) *x.*x +   v(2) * y.*y + v(3) * z.*z + ...
%     2*v(4) *x.*y + 2*v(5)*x.*z + 2*v(6) * y.*z + ...
%     2*v(7) *x    + 2*v(8)*y    + 2*v(9) * z -1;
% % interpolate data
% landmark_fine = interp3(x_coarse, y_coarse, z_coarse, landmark, x, y, z, 'nearest');  
%validGFP = landmark_fine .* (abs(Ellipsoid) < 0.01);
% visualize and save result in 3D
%renderGFPsurface(Ellipsoid, landmark_fine, [1 1 1],x,y,z)

% specify transformation matrix based on orientation and length of axis
% TODO: Verify that this is correct!
scale_matrix = eye(3);
scale_matrix(1) = 1/radii(1);
scale_matrix(5) = 1/radii(2);
scale_matrix(9) = 1/radii(3);
rotation_matrix = axes';
transform = scale_matrix * rotation_matrix;

% experimental code for sampling unit cube as 3D voxel grid
%mind = [-1 -1 -1]; maxd = [1 1 1];
%nsteps = [64 64 64];
%step = ( maxd - mind ) ./ nsteps;
%[xu yu zu] = meshgrid( linspace( mind(2) - step(2), maxd(2) + step(2), nsteps(2) ), linspace( mind(1) - step(1), maxd(1) + step(1), nsteps(1) ), linspace( mind(3) - step(3), maxd(3) + step(3), nsteps(3) ));

% sample surface of unit sphere by parametrization
samples = 64;
[alpha, beta] = meshgrid(linspace(pi,2*pi,samples/2), linspace(0,2*pi,samples)); % TODO: only one time 2*pi!
x_s = cos(alpha) .* sin(beta);
y_s = sin(alpha) .* sin(beta);
z_s = cos(beta);

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

%% transform segmented cells on new positions within unit sphere

% sample unit cube as 3D voxel grid 
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

% interpolate signal in unit cube transformed to original space
CellsInSphere = interp3(x, y, z, cells, xu_t, yu_t, zu_t,'nearest');

%% visualize results


figure;
renderCellsInSphere(CellsInSphere,xu,yu,zu);
hold on;
scatter3(x_s(:), y_s(:), z_s(:),10,[0 1 0]);
scatter3(x_s(GFPOnSphere == 1 & z_s <= 0), y_s(GFPOnSphere == 1 & z_s <= 0), z_s(GFPOnSphere == 1 & z_s <= 0),50,[1 0 0]); 
hold off;
axis vis3d equal;
view([-37.5, -75])