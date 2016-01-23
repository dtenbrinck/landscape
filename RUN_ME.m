% Script for registration of confocal microscopy data of small fish
% embryos.
%
%   Copyright: Daniel Tenbrinck 
%   Department of Mathematics and Computer Science
%   University of Muenster, Germany
%   email: daniel.tenbrinck@wwu.de
%   $Date: 2016/01/20 $

% tidy up memory and windows before starting
clear; close all; clc;

% get all subdirectories
addpath(genpath(pwd));

% load the data
load('1.mat');
dapi = data.Dapi;           % embryo membrane

% generate a two-dimensional laplacian filter
l = fspecial('laplacian');

% set rescaling factor
scale = 0.5;

% set threshold for sharp objects
threshold = 100;

% set threshold for indicator functions
threshold_indicator = 0.005;

% rescale data
for i=1:size(dapi,3)
    
  % rescale image size using trilinear interpolation for higher speed  
  dapi_resized(:,:,i) = double(imresize(dapi(:,:,i), scale));
  
end

% segment embryo area from maximum intensity projection
MIP = computeMIP(dapi_resized);
embryo_area = segmentEmbryo(MIP);

% compute center-of-mass
CoM = computeCoM(embryo_area);

% estimate circumference of embryo
radius_embryo = estimateSurface(embryo_area,CoM);

% visualize result
figure(1); imagesc(embryo_area);
viscircles(CoM(2:-1:1), radius_embryo(2));

% treat slices separately
for i = size(dapi,3)
  
  % smooth image slices
  g = fspecial('gaussian', [9 9], 1);
  dapi_filtered(:,:,i) = convn(dapi_resized(:,:,i),g,'same');
  
  % use Laplacian filter to find sharp objects
  dapi_filtered(:,:,i) = convn(dapi_filtered(:,:,i),l,'same');
  
  % set borders to zero manually
  tmp = dapi_filtered(3:end-3, 3:end-3, i);
  dapi_filtered(:,:,i) = zeros(size(dapi_filtered,1), size(dapi_filtered,2));
  dapi_filtered(3:end-3, 3:end-3, i) = tmp;
  
  % compute indicator function using threshold of absolute value
  indicator(:,:,i) = double(abs(dapi_filtered(:,:,i)) > threshold); % TODO: determine threshold automatically
  
  % smooth indicator function
  g = fspecial('gaussian', [29 29], 3.2);
  indicator_smoothed(:,:,i) = convn( indicator(:,:,i),g,'same');
  
  % compute region-of-interest according to sharpness
  ROI = indicator_smoothed(:,:,i) > threshold_indicator; % TODO determine threshold automatically
  
  % try regionprops function
  %stats = regionprops('table',ROI,'Centroid','MajorAxisLength','MinorAxisLength')

  % compute center by searching for a bounding box
  bBox = computeBoundingBox(ROI);
  center(i,:) = [mean(bBox(1:2)), mean(bBox(3:4))];
  
  % compute center-of-mass for each slice -> DOESNT WORK!
  %center(i,:) = computeCoM(ROI); 
  
  % visualize centers of mass inside indicator
  %figure(1); imagesc(indicator_smoothed(:,:,i)>threshold_indicator);
  %viscircles(center(i,2:-1:1), 1);
  %pause;
  
end

% determine center axes
%valid_entries = center(~isnan(center(:,1)),:);
%valid_entries = valid_entries(2:end-1,:);
%center_axes = mean(center);

% determine radii of outer circles
[radii surface3D] = estimateSurface(indicator_smoothed>threshold_indicator,center);

% visualize results
for i=1:size(dapi,3)
    figure(1); imagesc(dapi_resized(:,:,i));
    viscircles(cat(1,center(i,2:-1:1),center(i,2:-1:1)), radii(i,:)');
    %print(['results/result_' num2str(i) ],'-dpng'); 
    pause(0.3)
end

%slideShow(dapi_resized, indicator_smoothed>threshold_indicator, 2);
