% Segmentation test script for segmenting data via a minimal surface problem 
% using thresholding and exact convex relaxation techniques.
%
%   Copyright: Daniel Tenbrinck 
%   Department of Mathematics and Computer Science
%   University of Muenster, Germany
%   email: daniel.tenbrinck@wwu.de
%   $Date: 2016/01/04 $

% tidy up memory and windows before starting
clear; close all; clc;

% get all subdirectories
addpath(genpath(pwd));

% load the standard cameraman image
dataP.f = double(imread('cameraman.tif'));

% rescale image size using nearest neighbour for higher speed
% dataP.f = double(imresize(dataP.f, 0.5, 'nearest'));

% initialize image parameters
[dataP.nx, dataP.ny, dataP.nz] = size(dataP.f);
dataP.dim = ndims(dataP.f);
dataP.hx = 1; dataP.hy = 1; dataP.hz = 1;

% initialize algorithm parameters
algP.maxIts = 200;%5000;
algP.alpha = 50;
algP.regAccur = 1e-7;
algP.mu_grad_u = 1;
algP.TV = 'aniso';

% decide if plotting is enabled
algP.showSegmentation = true;
algP.showInterval = 50;
algP.plotError = true;

% obtain global threshold
dataP.t = kittler_thresholding(dataP.f);
fprintf('Optimal threshold for data computed as t=%i.', dataP.t);

% perform image segmentation using modified Arrow-Hurrowitz algorithm
[u, rel_change] = wL2_TV_AHMOD(dataP, algP, dataP.f, ones(size(dataP.f)), false);
    
% determine segmentation contour by thresholding
Xi = zeros(size(dataP.f));
Xi(u >= dataP.t+1) = 1;

% visualize segmentation result
if ndims(dataP.f) == 2
  drawSegmentation(dataP.f, Xi);
elseif ndims(dataP.f) == 3
  renderSurface(Xi);
end
