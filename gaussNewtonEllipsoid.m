function [center A] = gaussNewtonEllipsoid( sharp_points, initialCenter )
%GAUSSNEWTON Summary of this function goes here
%   Detailed explanation goes here

% determine number of sharp points
m = size(sharp_points,2);

% initialization with user input
center_old = initialCenter;

% initialize matrix as identity
A_old = eye(3);

% initialize container for Jacobi matrix
J = zeros(m,12);

% initialize termination criterion
rel_error = 1;

% iterate Gauss-Newton algorithm until convergence
while rel_error > 1e-05
  
  %compute f
  translated_points = sharp_points - repmat(center_old,1,m);
  f = sum((translated_points' * A_old) .* translated_points',2) - ones(m,1);
  
  % fill in Jacobian matrix pointwise
  for i=1:m
    
    % compute y_1
    J(i,1:3) = (center_old'-sharp_points(:,i)')*(A_old + A_old');
    
    % compute y_0
    %J(i,4:12) = reshape( sharp_points(:,i)*(sharp_points(:,i)' - center_old') + center_old*(center_old' - sharp_points(:,i)'), 1, 9);
    J(i,4:12) = reshape( sharp_points(:,i)*sharp_points(:,i)' - 2*(center_old*sharp_points(:,i)') + center_old*center_old', 1, 9);
    
  end
  
  h = J \ -f;
  
  center_new = center_old + h(1:3);
  A_new = reshape(A_old(:) + h(4:12),3,3);
  
  rel_error = norm(cat(1,center_old(:), A_old(:)) - cat(1,center_new(:),A_new(:))) / norm(cat(1,center_old(:), A_old(:)))
  
  A_old = A_new;
  center_old = center_new;
end


center = center_new;
A = A_new;
end

