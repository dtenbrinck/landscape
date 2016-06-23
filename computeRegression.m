function [ pstar, vstar, regData ] = computeRegression(GFPOnSphere, Xs, Ys, Zs, visualize)
% INITREFDATA: This function initializes the reference data set. It will
% compute the regression and will output the new structure S and the pstar
% and vstar of the reference data regression.

%% Input:
%   GFPOnSphere:    the matrix given by the function segmentGFP.m.
%   Xs, Ys, Zs:     meshgrid with the information of the given sphere.
%% Output:
%   pstar:          p* of the regression. Sets the Point where the geodesic
%                   starts.
%   vstar:          v* of the regression. Points in the direction of
%                   geodesic line.
%   regData:        the data set of points for the computation of the
%                   regression.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Main Code:

% Initialize
if nargin < 5
    visualize = 'false';
end

% Compute the regression data from GFP
regData = [(round(Xs(GFPOnSphere == 1 & Zs <= 0)*10^10)/10^10)';...
        (round(Ys(GFPOnSphere == 1 & Zs <= 0)*10^10)/10^10)';...
        (round(Zs(GFPOnSphere == 1 & Zs <= 0)*10^10)/10^10)'];
% Delete all multiple points
regData = unique(regData','rows')';

% Set options for fmincon
options = optimoptions('fmincon','Display','off','Algorithm','sqp');

% Compute the spherical regression
[pstar,vstar] ...
        = sphericalRegression3D(regData,[1;0;0],[0;0;-1],options,visualize);
end

