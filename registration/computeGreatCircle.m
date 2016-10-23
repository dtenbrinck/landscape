function [greatCircle, tangential] = computeGreatCircle( point1, point2 )
%COMPUTEGREATCIRCLE Summary of this function goes here
%   Detailed explanation goes here

normal = cross(point1, point2);
normal = normal / norm(normal);

tangential = cross(point1, normal);
tangential = tangential / norm(tangential);

greatCircle = geodesicFun(point1, tangential);

% debugging only
%dc = greatCircle(0:0.01:2*pi);
%figure(1); scatter3(point1(1), point1(2), point1(3)); hold on; scatter3(point2(1), point2(2), point2(3)); plot3(dc(1,:), dc(2,:), dc(3,:)); hold off

end

