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
load('12.mat');
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
fitEllipsoid(sharp_areas, resolution);

% visualize estimation of sharp areas and save results
for i = 1:size(dapi_resized,3)
  
  figure(1); imagesc(dapi_resized(:,:,i)); colormap gray;
  viscircles(center_points(i,2:-1:1), radii(i),'EdgeColor','b');
  %viscircles(center_points(i,2:-1:1), radii_disc(i,1));
  %viscircles(center_points(i,2:-1:1), radii_disc(i,2));
  print(['results/dapi_' sprintf('%02d',i) ],'-dpng');
  pause(0.1);
  
end

% segment gfp landmark
landmark_resized = segmentGFP(gfp_resized);

% delete old variable
clear gfp_resized;

% rescale gfp data and gfp landmark to higher resolution
for i=1:size(dapi,3)
  landmark(:,:,i) = imresize(landmark_resized(:,:,i), size(surface3D(:,:,1)), 'nearest');
  gfp_resized(:,:,i) = imresize(gfp(:,:,i), scale);
end

% restrict to surface area
landmark = landmark .* surface3D;

% segment cells -> TODO: Threshold not good!
%cells = segmentCells( mCherry_resized );

firstSlice = size(surface3D,3);
lastSlice = 1;

for i=1:size(surface3D,3)
  slice = surface3D(:,:,i);
  if sum(slice(:)) > 0
    if firstSlice > lastSlice
      firstSlice = i;      
    end
    lastSlice = i;
  end
end

cutSurface = surface3D(:,:,firstSlice:lastSlice);
cutLandmark = landmark(:,:,firstSlice:lastSlice);

flippedSurface = flipdim(cutSurface,3);
fullSurface = cat(3,cutSurface,flippedSurface); 

embeddedLandmark = zeros(size(cutLandmark,1), size(cutLandmark,2), 2*size(cutLandmark,3));
embeddedLandmark(:,:,1:end/2) = cutLandmark;

% visualize and save result in 3D
renderGFPsurface(fullSurface, embeddedLandmark, resolution)
print('results/rendering','-dpng');

% visualize segmentation contour of gfp landmark and save results
for i=1:size(dapi,3)
  drawSegmentation(gfp_resized(:,:,i),landmark(:,:,i));
  print(['results/gfp_' sprintf('%02d',i) ],'-dpng');
  pause(0.2)
end

close all;