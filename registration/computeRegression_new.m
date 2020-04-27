function [ pstar, vstar ] = computeRegression_new(regData, visualize)
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
options = optimoptions('fmincon','Display','off','Algorithm','sqp'); % 'StepTolerance',1e-16

% Compute the spherical regression
[pstar,vstar] ...
        = sphericalRegression3D_daniel(regData,[0;0;-1],[1;0;0],options,visualize);

%check if orientation of GC is counter clockwise
%if pstar(3) > 0 %Drosophila
if pstar(3) < 0 %Zebrafish    
    if vstar(1) < 0
    vstar = - vstar;
    end
elseif pstar(3) < 0
    if vstar(1) > 0
    vstar = -vstar;
    end
else
    disp('pstar  of great circle is zero!')
    if pstar(1) < 0
        if vstar(3) > 0
        vstar = -vstar;
        end
    else 
        if vstar(3) < 0
        vstar = -vstar;
        end    
    end      
end
    
    
% Normalize vstar
%vstar = vstar/norm(vstar);
end

