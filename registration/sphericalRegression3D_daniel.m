function [pstar, vstar] = sphericalRegression3D_daniel(data, p0, v0, options, visualize)
%SPHERICALREGRESSION3D   This function computes a spherical regression on
%the 3D unit sphere.
%% INPUT %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%   data:       3D spherical data set. If you have 3D points from p1,...,pN
%               with pi = [pi1,pi2,pi3], data should look like
%               data = [p1',...,pN'].
%   p0:         Initial starting point. Column vector. Default: p0 = [0;0;1].
%   v0:         Initial tangetial direction vector on p0. Default:
%               v0 = [0;1;0].
%   options:    The fmincon options. Default:
%               options = optimoptions('fmincon','Display','iter','Algorithm','sqp').
%               For more information visit the documentation of fmincon.
%   visualize:  visualize = 'true', visualizes the resulting regression
%               line. Default: 'false'.
%% OUTPUT %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% pstar:        3D optimal starting point of the regression.
% vstar:        Optimal tangential direction vector at pstar.
% Tstar:        Optimal function values for the great circle.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% INITIALIZATION %%

% Check input
if nargin < 2
    p0 = [1;0;0];
end
if nargin < 3
    v0 = [0;1;0];
end
if nargin < 4
    options = optimoptions('fmincon','Display','off','Algorithm','sqp');
end
if nargin < 5
    visualize = 'true';
end

%% MAIN CODE %%
%T = 0:0.01:2*pi;
%G = geodesicFun(p0,v0);
%rL = G(T);

% visualization for debugging
%figure;
%plot3(rL(1,:),rL(2,:),rL(3,:),'r')

F = testWrapper(data);%geoRegObjFun_new2(data);
%F = specialGeoRegObjFun(data);
nonlcon = @nonlconSR_new2;
pvT = [p0;v0];
% Compute pvstar with fmincon
[pvT2, fval, exitflag, output] = fmincon(F,pvT,[],[],[],[],[],[],nonlcon,options);
pstar = pvT2(1:3);
vstar = pvT2(4:6);
%Tstar = pvT2(7:end)';

% visualization for debugging
visualizeRegression(data', pstar, vstar, p0, v0);

% vstar must look in the same direction as v0!
%[vstar,Tstar] = evaluateDirection(pstar,vstar,Tstar,v0);

% Tstar should be in the interval from [0,2*pi]
%factor = ceil(max(Tstar(:))/(2*pi));
%for i=1:factor
%    Tstar(Tstar>2*pi) = Tstar(Tstar>2*pi)-2*pi;
%end
%factor = abs(floor(min(Tstar(:))/(2*pi)));
%for i=1:factor
%    Tstar(Tstar<0) = Tstar(Tstar<0)+2*pi;
%end
%Tstar = sort(Tstar);

end

