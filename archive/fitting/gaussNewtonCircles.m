function [center_x, center_y, radius] = gaussNewton( sharp_points )
%GAUSSNEWTON Summary of this function goes here
%   Detailed explanation goes here

% determine number of sharp points
m = size(sharp_points,1);

% compute center-of-mass
CoM = mean(sharp_points);

% initialization with center-of-mass
cy_old = CoM(1);
cx_old = CoM(2);

radius_old = mean(norm(sharp_points-repmat(CoM,m,1)));

J = zeros(m,3);
t = 0;
rel_error = 1;

while rel_error > 1e-05
  
  distance = sqrt((cy_old - sharp_points(:,1)).^2 + (cx_old - sharp_points(:,2)).^2);
  
  J(:,1) = (cy_old - sharp_points(:,1)) ./ distance;
  J(:,2) = (cx_old - sharp_points(:,2)) ./ distance;
  J(:,3) = -ones(m,1);
  
  f = distance - radius_old;
  h = J \ -f;
  
  cy_new = cy_old + h(1);
  cx_new = cx_old + h(2);
  radius_new = radius_old + h(3);
  
  rel_error = norm([cy_new, cx_new, radius_new] - [cy_old, cx_old, radius_old]) / norm([cy_old, cx_old, radius_old]);
  
  cy_old = cy_new;
  cx_old = cx_new;
  radius_old = radius_new;
  
end


center_x = cx_old;
center_y = cy_old;
radius = radius_old;

end

