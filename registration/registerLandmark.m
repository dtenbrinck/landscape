function transformation = registerLandmark( landmarkCoordinates, reference_point, reference_vector, landmarkCharacteristic)
%REGISTERLANDMARK Summary of this function goes here
%   Detailed explanation goes here

% Compute regression
[pstar,vstar] = computeRegression_new(landmarkCoordinates','false');

%%%%% DEBUG TUT NOCH NICHT!
figure,
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
xlim([-1,1]);
ylim([-1,1]);
zlim([-1,1]);
%%%%%

% Tilt refpstar onto the specified position
[pstar,vstar] = getCharPos(pstar,vstar,landmarkCoordinates',landmarkCharacteristic);

% Rotationmatrix: Rotate the great circle s.t. pstar is on refpstar
[Rp,Rv,pstar_r,vstar_r,vAngle]...
    = rotateGreatCircle(pstar,vstar,reference_point,reference_vector);

% Rotationmatrix: Rotates the regression line onto the reference line
Ra = rotAboutAxis(vAngle,reference_point);

transformation = Ra * Rp;

end

