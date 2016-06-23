function [Rp, Rv, pstar, vstar, vAngle] = rotAboutAbiAxis(pstar,vstar,refpstar,refvstar)
%ROTATEGREATCIRCLE: This function rotates a great circle onto another on
% with a given characteristic. Parametrized with a point and a vector.
% Trs characteristic can be the pstar of the regression line or a
% biological motivated characteristic.

%% Math:
% Let $v = a \times b$
% Set $s = \Vert v\Vert$
% Set $c = a\cdot b$
% Then the rotation matrix R is given by:
%$R = I + [v]_x + [v]_x^2\frac{1-c}{s^2}$
%% Input %%
%   pstar, vstar:       pstar and vstar that should be registered
%   refpstar, refvstar: pstar and vstar of the reference regression
% pstar, refpstar could also be considered as the characteristicpoint
%% Output %%
%   Rp:                 rotation matrix for pstar
%   Rv:                 rotation matrix for vstar
%   pstar:              rotated pstar by Rp. Is now on equal to refpstar.
%   vstar:              rotated vstar by Rp and Rv. Points in direction of
%                       refvstar.
%   vAngle:             angle between vstar after rotating by Rv and
%                       refvstar.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Main Code %%

% Map pstar onto refpstar
v = cross(pstar,refpstar);
s = norm(v);
c = pstar'*refpstar;
V = [0,-v(3),v(2);v(3),0,-v(1);-v(2),v(1),0];
% 
Rp = eye(3)+V+V*V*(1-c)/s^2;
%Rp = rotAboutAxis(acos(c),v);

% Rotate pstar and vstar
pstar = Rp*pstar;
vstar = Rp*vstar;

% Rotate vstar onto refvstar
v = cross(vstar,refvstar);
s = norm(v);
c = vstar'*refvstar;
V = [0,-v(3),v(2);v(3),0,-v(1);-v(2),v(1),0];

Rv = eye(3)+V+V*V*(1-c)/s^2;
% Compute angle between the tangential vectors vstar
vAngle = acos(c/(norm(vstar)*norm(refvstar)));

% Dertermine the sign of vAngle

% Rotate refvstar 90 about refpstar(!!!).
Ra = rotAboutAxis(pi/2,refpstar);
vAngle = vAngle*(vstar'*Ra*refvstar)/norm(vstar'*Ra*refvstar);


% Compute the rotated vstar
vstar = Rv*vstar;
end

