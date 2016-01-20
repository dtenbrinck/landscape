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
load('2.mat');
dapi = data.Dapi;           % embryo membrane

% generate a two-dimensional laplacian filter
l = fspecial('laplacian');

% set rescaling factor
scale = 0.7;

% set threshold for sharp objects
threshold = 100;

% set threshold for indicator functions
threshold_indicator = 0.2;

% treat slices separately
for i=1:size(dapi,3)
    
  % rescale image size using trilinear interpolation for higher speed  
  dapi_resized(:,:,i) = double(imresize(dapi(:,:,i), scale));
  
  % smooth image slices
  dapi_filtered(:,:,i) = imgaussfilt(dapi_resized(:,:,i),1);
  
  % use Laplacian filter to find sharp objects
  dapi_filtered(:,:,i) = convn(dapi_filtered(:,:,i),l,'same');
  
  % set borders to zero manually
  tmp = dapi_filtered(3:end-3, 3:end-3, i);
  dapi_filtered(:,:,i) = zeros(size(dapi_filtered,1), size(dapi_filtered,2));
  dapi_filtered(3:end-3, 3:end-3, i) = tmp;
  
  % compute indicator function using threshold of absolute value
  indicator(:,:,i) = double(abs(dapi_filtered(:,:,i)) > threshold);
  
  % smooth indicator function
  indicator_smoothed(:,:,i) = imgaussfilt( indicator(:,:,i),5);
  
  % compute center-of-mass for each slice
  CoM(i,:) = computeCoM(indicator_smoothed(:,:,i)>threshold_indicator); % TODO determine threshold automatically
  
end

% determine center axes
valid_entries = CoM(~isnan(CoM(:,1)),:);
valid_entries = valid_entries(2:end-1,:);
center_axes = mean(valid_entries);

% determine radii of outer circles
radiigit st = computeRadii(indicator_smoothed>threshold_indicator,center_axes);

%figure; imagesc(abs(dapi_resized(3:end-3,3:end-3,8))) 

% visualize results
slideShow(indicator_smoothed, indicator_smoothed>0.08, 2);
