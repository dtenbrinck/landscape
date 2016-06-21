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
%% Little excurse to the dimensions
% The image is always set in [row, column, z] dimensionsen. When we are
% working with axis [x,y,z] x = column, y = row and z = z. fitEllipsoid is
% working on the axis. So we get a center and a radii that depends on the
% axis and not on the image itself. So if we compute a sphere in the axis
% we can just use center and radii as it is. but if we want to visualize it
% in the image we need to permute the dimensions. So we can just work with
% the the output of fitEllipsoid on our sphere etc. But we need to be
% carefull when we use interp3 with landmark. landmark is the segmentation
% of the gfp channel. So it is in the same dimensions as the other images.
% We dont need to care about the resolution now because it is the same for
% x and y. 
% centCoords gives us the centroids of the cells in the image. It is
% computed with regionprops. This gives us the right centroids with the
% right order. So we can just use it for our axial representation.
%% Estimate embryo shape by fitting ellipsoid to sharp areas

[center radii axes v] = fitEllipsoid(sharp_areas, resolution);

%% Segment GFP landmark

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
[cells,centCoords] = segmentCells( mCherry_resized, resolution );

output = LACSfun(data,resolution,scale);
%% transform GFP on embryo shape onto unit sphere

% sample original space
mind = [0 0 0]; maxd = size(landmark) .* resolution;

%% experimental code for meshgrid with different resolution
%nsteps = maxd*0.2;
%step = ( maxd - mind ) ./ nsteps;
%[ X, Y, Z ] = meshgrid( linspace( mind(2) - step(2), maxd(2) + step(2), nsteps(2) ), linspace( mind(1) - step(1), maxd(1) + step(1), nsteps(1) ), linspace( mind(3) - step(3), maxd(3) + step(3), nsteps(3) ) );

%% create a meshgrid with same resolution as data
[ X, Y, Z ] = meshgrid( linspace( mind(2), maxd(2), size(landmark,2) ), linspace( mind(1), maxd(1), size(landmark,1) ), linspace( mind(3), maxd(3), size(landmark,3) ) );

%% experimental code to transform data using ellipsoid equation
% [ x_coarse, y_coarse, z_coarse] = meshgrid( linspace( mind(2) - step(2), maxd(2) + step(2), size(landmark,2) ), linspace( mind(1) - step(1), maxd(1) + step(1), size(landmark,1) ), linspace( mind(3) - step(3), maxd(3) + step(3), size(landmark,3) ) );
% Ellipsoid = v(1) *X.*X +   v(2) * Y.*Y + v(3) * Z.*Z + ...
%     2*v(4) *X.*Y + 2*v(5)*X.*Z + 2*v(6) * Y.*Z + ...
%     2*v(7) *X    + 2*v(8)*Y    + 2*v(9) * Z -1;
% % interpolate data
% landmark_fine = interp3(x_coarse, y_coarse, z_coarse, landmark, X, Y, Z, 'nearest');  
%validGFP = landmark_fine .* (abs(Ellipsoid) < 0.01);
% visualize and save result in 3D
%renderGFPsurface(Ellipsoid, landmark_fine, [1 1 1],X,Y,Z)

%% specify transformation matrix based on orientation and length of axis

scale_matrix = eye(3);
scale_matrix(1) = 1/radii(1);
scale_matrix(5) = 1/radii(2);
scale_matrix(9) = 1/radii(3);
rotation_matrix = axes';
transform = scale_matrix * rotation_matrix;

%% experimental code for sampling unit cube as 3D voxel grid
%mind = [-1 -1 -1]; maxd = [1 1 1];
%nsteps = [64 64 64];
%step = ( maxd - mind ) ./ nsteps;
%[Xc Yc Zc] = meshgrid( linspace( mind(2) - step(2), maxd(2) + step(2), nsteps(2) ), linspace( mind(1) - step(1), maxd(1) + step(1), nsteps(1) ), linspace( mind(3) - step(3), maxd(3) + step(3), nsteps(3) ));

%% sample surface of unit sphere by parametrization
samples = 64;
[alpha, beta] = meshgrid(linspace(pi,2*pi,samples/2), linspace(0,2*pi,samples)); % TODO: only one time 2*pi!
Zs = cos(alpha) .* sin(beta);
Xs = sin(alpha) .* sin(beta);
Ys = cos(beta);

% determine position of spherical points in original space

[Xs_t,Ys_t,Zs_t] = transformUnitSphere3D(Xs,Ys,Zs,scale_matrix,rotation_matrix,center);

% interpolate signal on unit sphere transformed to original space
GFPOnSphere = interp3(X, Y, Z, landmark, Xs_t, Ys_t, Zs_t,'nearest');

%% transform segmented cells on new positions within unit sphere

% sample unit cube as 3D voxel grid 
[Xc, Yc, Zc] = meshgrid(linspace(-1,1,samples), linspace(-1,1,samples), linspace(-1,1,samples));

% determine position of points in unit cube in original space

[Xc_t,Yc_t,Zc_t] = transformUnitCube3D(Xc,Yc,Zc,scale_matrix,rotation_matrix,center);

% interpolate signal in unit cube transformed to original space

CellsInSphere = interp3(X, Y, Z, cells, Xc_t, Yc_t, Zc_t,'nearest');
CellsInSphere(isnan(CellsInSphere)) = 0;

%% Registration

% Get coordinates of the cells

% Fit Coordinates to real resolution

centCoords = diag(resolution)*centCoords;

% Transform the coordinates into the sphere. With scaling and rotating.
centCoords(1,:) = centCoords(1,:)-center(1);
centCoords(2,:) = centCoords(2,:)-center(2);
centCoords(3,:) = centCoords(3,:)-center(3);
centCoords = transform*centCoords;

% Regression

data = [(round(Xs(GFPOnSphere == 1 & Zs <= 0)*10^10)/10^10)';...
    (round(Ys(GFPOnSphere == 1 & Zs <= 0)*10^10)/10^10)';...
    (round(Zs(GFPOnSphere == 1 & Zs <= 0)*10^10)/10^10)'];
data = unique(data','rows')';
[pstar,vstar] = sphericalRegression3D(data,[1;0;0],[0;0;-1]);

% Registration and transformation



%% visualize results


figure;f = figure; 
set(f, 'Position', [0, 0, 1920, 1680]);
renderCellsInSphere(CellsInSphere,Xc,Yc,Zc);
hold on;
T = 0:0.01:1;
G = geodesicFun(pstar,vstar);
regressionLine = G(T);
scatter3(pstar(1),pstar(2),pstar(3));

quiver3(pstar(1),pstar(2),pstar(3),vstar(1)/norm(vstar),vstar(2)/norm(vstar),vstar(3)/norm(vstar));
plot3(regressionLine(1,:),regressionLine(2,:),regressionLine(3,:),'r');
plot3(data(1,1),data(2,1),data(3,1),'o')
plot3(data(1,end),data(2,end),data(3,end),'o')
xlim([-1,1]);
ylim([-1,1]);
zlim([-1,1]);
%plot3(x,y,z);
scatter3(data(1,:),data(2,:),data(3,:),'*')

grid on;
scatter3(centCoords(1,:),centCoords(2,:),centCoords(3,:));
scatter3(Xs(:), Ys(:), Zs(:),10,[0 1 0]);
scatter3(Xs(GFPOnSphere == 1 & Zs <= 0), Ys(GFPOnSphere == 1 & Zs <= 0), Zs(GFPOnSphere == 1 & Zs <= 0),50,[1 0 0]); 
hold off;
axis vis3d equal;
view([-37.5, -75])

%% MOVIE

ViewZ = [-20,10;-110,10;-190,80;-290,10;-380,10];
OptionZ.FrameRate = 40; OptionZ.Duration = 10; OptionZ.Periodic=true;
CaptureFigVid(ViewZ,'RotatingBall',OptionZ)
