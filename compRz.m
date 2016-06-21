function [ Rz ] = compRz(origin)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
cachev = origin/norm(origin);
Rz = diag([1,1,1]);
Rz(1,1) = cachev(3);
Rz(3,3) = cachev(3);
Rz(3,1) = norm(origin(1:2))/norm(origin);
Rz(1,3) = norm(origin(1:2))/norm(origin);

end

