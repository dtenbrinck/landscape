function [ R ] = genAngleRotZ(theta)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here
R = diag([1,1,1]); 
R(1:2,1:2) = [cos(theta),-sin(theta);sin(theta),cos(theta)];

end

