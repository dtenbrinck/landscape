function [G] = geodesicFun(p,v)
%GEODESICFUN Gives the geodesic function G(t). It can compute the points on
%the spherical line starting at p with direction v.

G = @(t) p*cos(t.*norm(v))+v./norm(v)*sin(t.*norm(v));

end
