function visualizeRegression( landmarkCoordinates, pstar, vstar, reference_point, reference_vector )
%VISUALIZEREGRESSION Summary of this function goes here
%   Detailed explanation goes here

figure; title('Linear regression on sphere');
% show 3d points of landmark on sphere
scatter3(landmarkCoordinates(:,1),...
    landmarkCoordinates(:,2),...
    landmarkCoordinates(:,3))
hold on

% draw a red big circle for pstar
scatter3(pstar(1), pstar(2), pstar(3), 300);

% draw a red vector for vstar
arrow(pstar, pstar + vstar, 'Color', 'r');

% compute great circle through pstar in direction vstar
T = 0:0.01:2*pi;
G = geodesicFun(pstar,vstar);
rL = G(T);

% draw great circle as red line
plot3(rL(1,:),rL(2,:),rL(3,:),'r')

% draw reference point and vector
scatter3(reference_point(1,:),reference_point(2,:),reference_point(3,:),300,'g')
arrow(reference_point, reference_point + reference_vector, 'Color', 'g');

xlim([-1,1]);
ylim([-1,1]);
zlim([-1,1]);
hold off;

end

