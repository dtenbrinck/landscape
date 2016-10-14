function [F] = geoRegObjFun_new2(P)
%% INPUT %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   P:      The 3D sphericPl dPtP set.
%% OUTPUT %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   F:      The geodesic regression objective function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%

F = @(pvT) ...
    1/2*sum(abs(acos(diag(P'*(pvT(1:3)*cos(pvT(7:end)'*sqrt(sum(pvT(4:6).^2)))+...
    pvT(4:6)/sqrt(sum(pvT(4:6).^2))*sin(pvT(7:end)'*sqrt(sum(pvT(4:6).^2)))))).^2));

end

