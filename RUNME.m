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
load('19.mat');
dapi = data.Dapi;           % embryo membrane
gfp = data.GFP;             % fluorescent landmark on membrane
mCherry = data.mCherry;     % fluorescent cells within embryo

% rescale image size using trilinear interpolation for higher speed
scale = 0.1;
for i=1:size(dapi,3)
  dapi_resized(:,:,i) = double(imresize(dapi(:,:,i), scale));
  gfp_resized(:,:,i) = double(imresize(gfp(:,:,i), scale));
  mCherry_resized(:,:,i) = double(imresize(mCherry(:,:,i), scale));
end
 
% segment fluorescent landmark
[embryo, landmark] = segmentGFP(gfp_resized);

% compose segmentation results
ensemble = embryo;
ensemble(landmark == 1) = 2;

% visualize results
slideShow(gfp_resized, ensemble, 2);
