function [phi, theta] = sample2rad( phi, theta, samples)
%SAMPLE2RAD: This functions takes in the samples and give the corresponding
% radial coordinates in dependence to the samplerate

% Input:
% phi:      phi sample coordinate
% theta:    theta sample coordinate
% samples:  Samplerate
% Output:
% phi:      phi in radial values
% theta:    theta in radial values
%% Code

samplePhi = pi:pi/samples:2*pi;
sampleTheta = 0:pi*2/samples:2*pi;

phi = samplePhi(phi(:));
theta = sampleTheta(theta(:));

end

