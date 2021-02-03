function [ pstar, vstar ] = computeRegression_new(regData)
% COMPUTEREGRESSION computes the regression and will output pstar and vstar of the data regression.
%% Input:
%   regData:        3xn matrix containing the coordinates on the sphere
%% Output:
%   pstar:          p* of the regression. Sets the Point where the geodesic
%                   starts.
%   vstar:          v* of the regression. Points in the direction of
%                   geodesic line.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Main Code:

% Set options for fmincon
options = optimoptions('fmincon','Display','off','Algorithm','sqp'); % 'StepTolerance',1e-16

% Compute the spherical regression
[pstar,vstar] ...
        = sphericalRegression3D_daniel(regData,[0;0;-1],[1;0;0],options);
    
% Check if orientation of Great Circle is counter clockwise and change direction if needed. (For consistency) 
if pstar(3) < 0 
    if vstar(1) < 0 
        vstar = -vstar;
    end
elseif pstar(3) > 0
    if vstar(1) > 0
    vstar = -vstar;
    end
end

end
