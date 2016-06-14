function [x,y,z] = computeSphericalLine(phi1,phi2,theta1,theta2,n)
%% INPUT %%
%
%   phi1:   phi angle of the first point
%   phi2:   phi angle of the second point
%   theta1: theta angle of the first point
%   theta2: theta angle of the second point
%   n:      number of points on the line
%
%% CODE %%

p = 0:1/n:1;
phi = phi1+p.*(phi2-phi1);
theta = theta1+p.*(theta2-theta1);
x = cos(phi).*sin(theta);
y = sin(phi).*sin(theta);
z = cos(theta);

end