function [F] = geoRegObjFun(P)
%% INPUT %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   P:      The 3D spherical data set.
%% OUTPUT %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   F:      The geodesic regression objective function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
t = 0:1/(size(P,2)-1):2*pi;
F = @(pv) ...
    1/2*sum((acos(diag(P'*(pv(1:3)*cos(t*sqrt(sum(pv(4:6).^2)))+...
    pv(4:6)/sqrt(sum(pv(4:6).^2))*sin(t*sqrt(sum(pv(4:6).^2)))))).^2));

end

