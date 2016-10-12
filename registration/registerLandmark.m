function transformation = registerLandmark( landmarkCoordinates, reference_point, reference_vector, landmarkCharacteristic)
%REGISTERLANDMARK Summary of this function goes here
%   Detailed explanation goes here

% Compute regression
[pstar,vstar] = computeRegression(landmarkCoordinates','false');

%%%%% DEBUG TUT NOCH NICHT!
scatter3(landmarkCoordinates(:,1),...
    landmarkCoordinates(:,2),...
    landmarkCoordinates(:,3))
hold on
scatter3(pstar(1), pstar(2), pstar(3), 300);
title('Drawing regression line.');
T = 0:0.01:2*pi;
G = geodesicFun(pstar,vstar);
rL = G(T);
plot3(rL(1,:),rL(2,:),rL(3,:),'r')
%%%%%

% Tilt refpstar onto the specified position
[refpstar,refvstar] = getCharPos(reference_point,reference_vector,landmarkCoordinates',landmarkCharacteristic);

% Rotationmatrix: Rotate the great circle s.t. pstar is on refpstar
[Rp,Rv,pstar_r,vstar_r,vAngle]...
    = rotateGreatCircle(pstar,vstar,refpstar,refvstar);

% Rotationmatrix: Rotates the regression line onto the reference line
Ra = rotAboutAxis(vAngle,refpstar);

% Rotate data set and cell coordinates
%regData_r = Ra*Rp*regData;
%handles.SegData.(fieldname).centCoords ...
%    = Ra*Rp*handles.SegData.(fieldname).centCoords;

transformation = Ra * Rp;

end

