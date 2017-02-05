function [ pstar, vstar ] = computeRegression(regData, visualize)
% INITREFDATA: This function initializes the reference data set. It will
% compute the regression and will output the new structure S and the pstar
% and vstar of the reference data regression.

%% Input:
%   regData:        Contains the coordinates of the embryo on the sphere
%   visualize:      Visualize the regression. 'true', 'false'
%% Output:
%   pstar:          p* of the regression. Sets the Point where the geodesic
%                   starts.
%   vstar:          v* of the regression. Points in the direction of
%                   geodesic line.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Main Code:

% Initialize
if nargin < 5
    visualize = 'false';
end

% Set options for fmincon
options = optimoptions('fmincon','Display','iter','Algorithm','sqp');

% Compute the spherical regression
[pstar,vstar] ...
        = sphericalRegression3D(regData,[0;0;-1],[1;0;0],options,visualize);
% Normalize vstar
vstar = vstar/norm(vstar);
end

