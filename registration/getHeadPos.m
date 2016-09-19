function [pnew,vnew] = getHeadPos(p,v,regData)
%GETHEADPOS:    Get head position: This function will compute the point on
%the great circle that is on the boundary of the head. So we can tilt the
%great circles of all embryos to this position and make a more robust
%fitting of the great circles. It will also rotate the vstar onto the top
%of the head.
%% INPUT:  %%
% p:        The original pstar from the regression algorithm. Kind of random.
% v:        The original vstar computed by the regression algorithm.
%           Normalized!
% regData:  The point cloud of the embryo.
%
%% OUTPUT: %%
% p:    The tilted pstar onto the head position
% v:    The tilted vstar onto the head postion
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% MAIN CODE %%

% Compute original regression line
T = 0:0.01:2*pi;
G = geodesicFun(p,v);
regressionLine = G(T);

% Initialize the indices that will give the closest points on the
% regression line to the regData
ind = ones(1,size(regData,2));

% Compute the smallest difference of each regData point to the
% regressionLine
for i=1:size(regData,2)
    diffSum = ...
      abs(regressionLine(1,:)-ones(1,size(regressionLine,2))*regData(1,i))...
    + abs(regressionLine(2,:)-ones(1,size(regressionLine,2))*regData(2,i))...
    + abs(regressionLine(3,:)-ones(1,size(regressionLine,2))*regData(3,i));
    [~,ind(i)] = min(diffSum);
    
end

% Set an interval so they won't pick points from the other side (maybe
% better way)
interval = -pi:0.01:pi;

% Get the last point that is still on the embryo
[~,ind2] = min(abs(interval(ind)));
ind2 = ind(ind2);
pnew = regressionLine(:,ind2);

% Compute the new vstar
% Map pstar onto refpstar
V = cross(p,pnew);
s = norm(V);
c = p'*pnew;
V = [0,-V(3),V(2);V(3),0,-V(1);-V(2),V(1),0];
% Compute the rotation matrix of p
Rp = eye(3)+V+V*V*(1-c)/s^2;

% Rotate vstar
vnew = Rp*v;


end

