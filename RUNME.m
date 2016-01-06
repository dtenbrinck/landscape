% Script for registration of confocal microscopy data of small fish
% embryos.
%
%   Copyright: Daniel Tenbrinck 
%   Department of Mathematics and Computer Science
%   University of Muenster, Germany
%   email: daniel.tenbrinck@wwu.de
%   $Date: 2016/01/06 $

% tidy up memory and windows before starting
clear; close all; clc;

% get all subdirectories
addpath(genpath(pwd));

% load the data
load('1.mat');
dapi = data.Dapi;           % embryo membrane
gfp = data.GFP;             % fluorescent landmark on membrane
mCherry = data.mCherry;     % fluorescent cells within embryo

% rescale image size using trilinear interpolation for higher speed
scale = 0.25;
for i=1:size(dapi,3)
  dapi_resized(:,:,i) = double(imresize(dapi(:,:,i), scale));
  gfp_resized(:,:,i) = double(imresize(gfp(:,:,i), scale));
  mCherry_resized(:,:,i) = double(imresize(mCherry(:,:,i), scale));
end
 
% segment embryo membrane
dapi_segmented = segmentData(dapi_resized,1100);

% segment fluorescent landmark
gfp_segmented = segmentData(gfp_resized, 1150);

% segment cells
mCherry_segmented = segmentData(mCherry_resized,600);