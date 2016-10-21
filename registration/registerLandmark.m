function transformation = registerLandmark( landmarkCoordinates, reference_point, reference_vector, landmarkCharacteristic)
%REGISTERLANDMARK Summary of this function goes here
%   Detailed explanation goes here

% Compute regression
[pstar,vstar] = computeRegression_new(landmarkCoordinates','false');

% Tilt refpstar onto the specified position
[pstar,vstar] = getCharPos(pstar,vstar,landmarkCoordinates',landmarkCharacteristic);

%%%%% DEBUG TUT NOCH NICHT!
% figure,
% scatter3(landmarkCoordinates(:,1),...
%     landmarkCoordinates(:,2),...
%     landmarkCoordinates(:,3))
% hold on
% scatter3(pstar(1), pstar(2), pstar(3), 300);
% arrow(pstar, pstar + vstar, 'Color', 'r');
% title('Drawing regression line.');
% T = 0:0.01:2*pi;
% G = geodesicFun(pstar,vstar);
% rL = G(T);
% plot3(rL(1,:),rL(2,:),rL(3,:),'r')
% scatter3(reference_point(1,:),reference_point(2,:),reference_point(3,:),300,'g')
% arrow(reference_point, reference_point + reference_vector, 'Color', 'g');
% xlim([-1,1]);
% ylim([-1,1]);
% zlim([-1,1]);
% hold off;
%%%%%



% Rotationmatrix: Rotate the great circle s.t. pstar is on refpstar
[Rp,Rv,pstar_r,vstar_r,vAngle]...
    = rotateGreatCircle(pstar,vstar,reference_point,reference_vector);

% Rotationmatrix: Rotates the regression line onto the reference line
Ra = rotAboutAxis(vAngle,reference_point);

transformation = Ra * Rp;


% transformed_Coordinates = transformation * landmarkCoordinates';
% 
% % Compute regression
% [pstar,vstar] = computeRegression_new(transformed_Coordinates,'false');
% 
% % Tilt refpstar onto the specified position
% [pstar,vstar] = getCharPos(pstar,vstar,transformed_Coordinates',landmarkCharacteristic);
% 
% %%%%% DEBUG TUT NOCH NICHT!
% figure,
% scatter3(transformed_Coordinates(1,:),...
%     transformed_Coordinates(2,:),...
%     transformed_Coordinates(3,:))
% hold on
% scatter3(pstar(1), pstar(2), pstar(3), 300);
% arrow(pstar, pstar + vstar, 'Color', 'r');
% title('Drawing regression line.');
% T = 0:0.01:2*pi;
% G = geodesicFun(pstar,vstar);
% rL = G(T);
% plot3(rL(1,:),rL(2,:),rL(3,:),'r')
% scatter3(reference_point(1,:),reference_point(2,:),reference_point(3,:),300,'g')
% arrow(reference_point, reference_point + reference_vector, 'Color', 'g');
% xlim([-1,1]);
% ylim([-1,1]);
% zlim([-1,1]);
% hold off;

end
