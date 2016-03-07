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
load('11.mat');
dapi = normalizeData(data.Dapi);           % embryo membrane
gfp = normalizeData(data.GFP);             % landmark
mCherry = normalizeData(data.mCherry);     % labeled cells

% set rescaling factor for dapi channel
scale = 0.75;

% set resolution for data in micrometers
resolution = [1.29/scale, 1.29/scale, 20];

% rescale image size using trilinear interpolation for higher speed
for i=1:size(dapi,3)
  dapi_resized(:,:,i) = imresize(dapi(:,:,i), scale);
  gfp_resized(:,:,i) = imresize(gfp(:,:,i), 0.25); % coarse data for segmentation sufficient
  %mCherry_resized(:,:,i) = imresize(mCherry(:,:,i), 0.25);
end

% generate three-dimensional Gaussian filter
g = generate3dGaussian(9, 1.5);

% denoise image by blurring
blurred = imfilter(dapi_resized, g, 'same','replicate');

% generate a three-dimensional Laplacian filter
kernelLaplace = generate3dLaplacian(resolution);

% determine sharp areas by Laplacian filtering
sharp_areas = normalizeData (imfilter(blurred, kernelLaplace, 'same', 'replicate'));

% estimate focus of images by fitting circles
%[center_points, radii, radii_disc, surface3D] = fitCircles(sharp_areas);
[center radii axes v] = fitEllipsoid(sharp_areas, resolution);

%%% visualize estimation of sharp areas and save results
% for i = 1:size(dapi_resized,3)
%   
%   figure(1); imagesc(dapi_resized(:,:,i)); colormap gray;
%   viscircles(center_points(i,2:-1:1), radii(i),'EdgeColor','b');
%   viscircles(center_points(i,2:-1:1), radii_disc(i,1));
%   viscircles(center_points(i,2:-1:1), radii_disc(i,2));
%   print(['results/dapi_' sprintf('%02d',i) ],'-dpng');
%   pause(0.1);
%   
% end

% segment gfp landmark
landmark_resized = segmentGFP(gfp_resized);

% delete old variable
clear gfp_resized;

% rescale gfp data and gfp landmark to higher resolution
for i=1:size(dapi,3)
  landmark(:,:,i) = imresize(landmark_resized(:,:,i), size(dapi_resized(:,:,1)), 'nearest');
  gfp_resized(:,:,i) = imresize(gfp(:,:,i), scale);
end

% project to surface area
%landmark = landmark .* surface3D;

% segment cells -> TODO: Threshold not good!
%cells = segmentCells( mCherry_resized );

% firstSlice = size(dapi_resized,3);
% lastSlice = 1;
% 
% for i=1:size(surface3D,3)
%   slice = surface3D(:,:,i);
%   if sum(slice(:)) > 0
%     if firstSlice > lastSlice
%       firstSlice = i;      
%     end
%     lastSlice = i;
%   end
% end
% 
% cutSurface = surface3D(:,:,firstSlice:lastSlice);
% cutLandmark = landmark(:,:,firstSlice:lastSlice);
% 
% flippedSurface = flipdim(cutSurface,3);
% fullSurface = cat(3,cutSurface,flippedSurface); 

mind = [1 1 1]; maxd = size(landmark) .* resolution;
nsteps = maxd*0.15;%size(landmark) .* [1 1 10];
step = ( maxd - mind ) ./ nsteps;
[ x_coarse, y_coarse, z_coarse] = meshgrid( linspace( mind(2) - step(2), maxd(2) + step(2), size(landmark,2) ), linspace( mind(1) - step(1), maxd(1) + step(1), size(landmark,1) ), linspace( mind(3) - step(3), maxd(3) + step(3), size(landmark,3) ) );
[ x, y, z ] = meshgrid( linspace( mind(2) - step(2), maxd(2) + step(2), nsteps(2) ), linspace( mind(1) - step(1), maxd(1) + step(1), nsteps(1) ), linspace( mind(3) - step(3), maxd(3) + step(3), nsteps(3) ) );
Ellipsoid = v(1) *x.*x +   v(2) * y.*y + v(3) * z.*z + ...
    2*v(4) *x.*y + 2*v(5)*x.*z + 2*v(6) * y.*z + ...
    2*v(7) *x    + 2*v(8)*y    + 2*v(9) * z -1;

landmark_fine = interp3(x_coarse, y_coarse, z_coarse, landmark, x, y, z, 'nearest');
  
%validGFP = landmark_fine .* (abs(Ellipsoid) < 0.01);

% visualize and save result in 3D
renderGFPsurface(Ellipsoid, landmark_fine, [1 1 1],x,y,z)


% transform back to unit sphere
mind = [-1 -1 -1]; maxd = [1 1 1];
nsteps = [64 64 64];
step = ( maxd - mind ) ./ nsteps;
scale_matrix = eye(3);
scale_matrix(1) = 1/radii(1);
scale_matrix(5) = 1/radii(2);
scale_matrix(9) = 1/radii(3);
rotation_matrix = axes';
transform = scale_matrix * rotation_matrix;

%[xu yu zu] = meshgrid( linspace( mind(2) - step(2), maxd(2) + step(2), nsteps(2) ), linspace( mind(1) - step(1), maxd(1) + step(1), nsteps(1) ), linspace( mind(3) - step(3), maxd(3) + step(3), nsteps(3) ));

% generate angles according to specified distribution
samples = 64;

[alpha, beta] = meshgrid(linspace(0,2*pi,samples), linspace(0,pi,samples));
xu= cos(alpha) .* cos(beta);
yu = sin(alpha) .* cos(beta);
zu = sin(beta);

%scatter3(x_new(:), y_new(:), z_new(:));
%[xu, yu, zu] = meshgrid(linspace(-1.5,1.5,samples), linspace(-1.5,1.5,samples), linspace(-1.5,1.5,samples));
x_new = xu;
y_new = yu;
z_new = zu;
for i = 1:numel(x_new)
  
  new_coordinate = transform^-1 * [x_new(i), y_new(i), z_new(i)]';
  x_new(i) = new_coordinate(1);
  y_new(i) = new_coordinate(2);
  z_new(i) = new_coordinate(3);
  
  x_new(i) =  x_new(i) + center(1);
  y_new(i) =  y_new(i) + center(2);
  z_new(i) =  z_new(i) + center(3);
  
end
GFPOnSphere = interp3(x, y, z, landmark_fine, x_new, y_new, z_new,'nearest');

scatter3(xu(GFPOnSphere == 1 & zu <= 0), yu(GFPOnSphere == 1 & zu <= 0), zu(GFPOnSphere == 1 & zu <= 0),50,[1 0 0]); 
hold on;
scatter3(xu(:), yu(:), zu(:),10,[0 1 0]);
hold off;
axis vis3d equal;
%view([-37.5, -75])

%  figure;
%   p = patch( isosurface( xu, yu, zu, Sphere, 0 ) );
%   hold on
%   %p2 = patch( isosurface( x, y, z, landmark .* (surface3D + 1) .* (surface3D <= 0.05), 1)); 
%   %p2 = patch( isosurface( x, y, z, landmark .* (surface3D + 1), 1)); 
%   set( p, 'FaceColor', 'g', 'EdgeColor', 'none' );
%   %set( p2, 'FaceColor', 'r', 'EdgeColor', 'none' );
%   %view( -70, 40 );
%   hold off
%   axis vis3d equal;
%   %daspect(resolution(3)./resolution)
%   camlight;



%embeddedLandmark = zeros(size(cutLandmark,1), size(cutLandmark,2), 2*size(cutLandmark,3));
%embeddedLandmark(:,:,1:end/2) = cutLandmark;

% visualize and save result in 3D
%renderGFPsurface(fullSurface, embeddedLandmark, resolution)
%print('results/rendering','-dpng');

% visualize segmentation contour of gfp landmark and save results
%for i=1:size(dapi,3)
%  drawSegmentation(gfp_resized(:,:,i),landmark(:,:,i));
%  print(['results/gfp_' sprintf('%02d',i) ],'-dpng');
%  pause(0.2)
%end
