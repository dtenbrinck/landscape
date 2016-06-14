close all;
clear all;

%% FIRST LINE
phi1 = 1;
theta1 = pi/3;
phi2 = 2;
theta2 = pi/2;

x1 = cos(phi1)*sin(theta1);
y1 = sin(phi1)*sin(theta1);
z1 = cos(theta1);

x2 = cos(phi2)*sin(theta2);
y2 = sin(phi2)*sin(theta2);
z2 = cos(theta2);


%% SECOND LINE

phi3 = 1.1;
theta3 = pi/3.1;
phi4 = 2.9;
theta4 = pi/4;

x3 = cos(phi3)*sin(theta3);
y3 = sin(phi3)*sin(theta3);
z3 = cos(theta3);

x4 = cos(phi4)*sin(theta4);
y4 = sin(phi4)*sin(theta4);
z4 = cos(theta4);


%% PLOT

[x,y,z] = sphere;
figure(1);plot3(x,y,z,'-');
hold on;
plot3(x1,y1,z1,'*');
plot3(x2,y2,z2,'*');
plot3(x3,y3,z3,'*');
plot3(x4,y4,z4,'*');

% Compute the lines WORKING!
n=10;
[X1,Y1,Z1] = computeSphericalLine(phi1,phi2,theta1,theta2,n);
plot3(X1,Y1,Z1,'-');
[X2,Y2,Z2] = computeSphericalLine(phi3,phi4,theta3,theta4,n);
plot3(X2,Y2,Z2,'-');


