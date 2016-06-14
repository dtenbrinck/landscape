function [x,y,z] = computeSphericalPoints(phi,theta)
%% INPUT %%
%
%   phi:   phi angles of the points
%
%% CODE %%

x = cos(phi).*sin(theta);
y = sin(phi).*sin(theta);
z = cos(theta);

end