function [pstar, vstar, Tstar] = sphericalRegression3D_new(data, p0, v0, options, visualize)
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
% pstar:        3D optimal startin point of the regression.
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
T = 0:1/(size(data,2)-1):1;
G = geodesicFun(p0,v0);
rL = G(T);
F = geoRegObjFun_new2(data);
%F = specialGeoRegObjFun(data);
nonlcon = @nonlconSR_new2;
pvT = [p0;v0;T'];
% Compute pvstar with fmincon
pvT2 = fmincon(F,pvT,[],[],[],[],[],[],nonlcon,options);
pstar = pvT2(1:3);
vstar = pvT2(4:6);
Tstar = pvT2(7:end)';
G2 = geodesicFun(pstar,vstar);
rL2 = G2(Tstar);

% Visualize

if strcmp(visualize,'true')
    T = 0:0.01:2*pi;
    G = geodesicFun(pstar,vstar);
    regressionLine = G(T);
    figure, title('Regression line through the data set.');
    scatter3(pstar(1),pstar(2),pstar(3));
    hold on
    quiver3(pstar(1),pstar(2),pstar(3),vstar(1)/norm(vstar),vstar(2)/norm(vstar),vstar(3)/norm(vstar));
    plot3(regressionLine(1,:),regressionLine(2,:),regressionLine(3,:),'r');
    %plot3(data(1,1),data(2,1),data(3,1),'o')
    %plot3(data(1,end),data(2,end),data(3,end),'o')
    xlim([-1,1]);
    ylim([-1,1]);
    zlim([-1,1]);
    %plot3(x,y,z);
    scatter3(data(1,:),data(2,:),data(3,:),'*')
    hold off
end
end

