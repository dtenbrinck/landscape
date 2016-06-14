function [G] = specialGeodesicFun(p,v)
%GEODESICFUN Gives the geodesic function G(t) that is for t in [0,1]
%always a half great circle in direction v. It can compute the points on
%the spherical line starting at p with direction v.
%% INPUT %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   P:      The 3D spherical data set.
%% OUTPUT %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   F:      The geodesic regression objective function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
G = @(t) p*cos(norm(v)*(pi*t-pi/2))+v/norm(v)*sin(norm(v)*(pi*t-pi/2));

end

