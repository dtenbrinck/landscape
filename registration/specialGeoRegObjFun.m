function [F] = specialGeoRegObjFun(P)
%The same as in specialGeodesicFun.
%% INPUT %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   P:      The 3D spherical data set.
%% OUTPUT %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   F:      The geodesic regression objective function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
t = 0:1/(size(P,2)-1):1;
F = @(pv) ...
    1/2*sum((acos(diag(P'*(pv(1:3)*cos(norm(pv(4:6))*(pi*t-pi/2))+...
    pv(4:6)/sqrt(sum(pv(4:6).^2))*sin(norm(pv(4:6))*(pi*t-pi/2))))).^2));

end

