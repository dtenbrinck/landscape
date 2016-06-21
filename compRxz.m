function [ Rxz ] = compRxz(origin)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

origin = origin(1:2)/norm(origin(1:2));
Rxz = diag([1,1,1]);
Rxz(1,1) = origin(1);
Rxz(2,2) = origin(1);
Rxz(2,1) = -origin(2);
Rxz(1,2) = origin(2);

end

