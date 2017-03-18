function [x,y,z] = equidistSampledSphere(N,r)
% This function tries to generate equidistant points on a sphere. It is not
% 100% perfect but better than others. Source: 
% https://www.cmu.edu/biolphys/deserno/pdf/sphere_equi.pdf

if nargin < 2
r = 1;
end



%% MAIN CODE

a = 4*pi*r^2/N;
d = sqrt(a);
M_theta = round(pi/d);
d_theta = pi/M_theta;
d_phi = a/d_theta;
x = 0;
y = 0;
z = 0;

for i=1:M_theta
    theta = pi*(i+0.5)/M_theta;
    M_phi = round(2*pi*sin(theta)/d_phi);
    for j=1:M_phi
        phi = 2*pi*j/M_phi;
        x = [x;r*sin(theta).*cos(phi)];
        y = [y;r*sin(theta).*sin(phi)];
        z = [z;r*cos(theta)];
    end
end

end