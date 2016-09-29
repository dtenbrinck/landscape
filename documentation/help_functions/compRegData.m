function [regData] = compRegData(landmark,samples,resolution,radii,center,axes)
%COMPUTEREGDATA

[alpha, beta] = meshgrid(linspace(pi,2*pi,samples/2), linspace(0,2*pi,samples));
Zs = cos(alpha) .* sin(beta);
Xs = sin(alpha) .* sin(beta);
Ys = cos(beta);

scale_matrix = diag(1./radii);
rotation_matrix = axes';
[Xs_t,Ys_t,Zs_t,axes] ...
    = transformUnitSphere3D(Xs,Ys,Zs,scale_matrix,rotation_matrix,center);

% Sample original space
mind = [0 0 0]; maxd = size(landmark) .* resolution;
%Create meshgrid with same resolution as data
[ X, Y, Z ] = meshgrid( linspace( mind(2), maxd(2), size(landmark,2) ),...
    linspace( mind(1), maxd(1), size(landmark,1) ),...
    linspace( mind(3), maxd(3), size(landmark,3) ) );

% Project segmented landmark onto unit sphere...
GFPOnSphere ...
    = interp3(X, Y, Z, landmark,Xs_t,Ys_t,Zs_t,'nearest');

% Compute the regression data from GFP
regData = [(round(Xs(GFPOnSphere == 1 & Zs <= 0)*10^10)/10^10)';...
        (round(Ys(GFPOnSphere == 1 & Zs <= 0)*10^10)/10^10)';...
        (round(Zs(GFPOnSphere == 1 & Zs <= 0)*10^10)/10^10)'];
% Delete all multiple points
regData = unique(regData','rows')';

end

