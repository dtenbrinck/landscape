

phi1 = 40;
theta1 = 2;
phi2 = 55;
theta2 = 2;
GFPOnSphere(isnan(GFPOnSphere)) = 0;
A = GFPOnSphere;
A(phi1,theta1) = 2;
A(phi2,theta2) = 2;
[phi,theta] = find(A);
figure(1), imagesc(A);

[phi1,theta1] = sample2rad(phi1,theta1,samples);
[phi2,theta2] = sample2rad(phi2,theta2,samples);
[phi,theta] = sample2rad(phi,theta,samples);

[x,y,z] = computeSphericalLine(phi1,theta1,phi2,theta2,10);
[x_p,y_p,z_p] = computeSphericalPoints(phi,theta);
%[X,Y,Z] = sphere;
figure(2), %plot3(X,Y,Z),
hold on;plot3(x,y,z,'-');scatter3(x_p,y_p,z_p);

%% Spherical manipulation 


%%
% Works fine but i dont like it like this.
% n=17;
% p = 0:1/n:1;
% phi = round(phi1+p.*(phi2-phi1));
% theta = round(theta1+p.*(theta2-theta1));
% A(phi,theta) = 2;
% figure(2);
% renderCellsInSphere(CellsInSphere,xu,yu,zu);
% hold on;
% %scatter3(x,y,z);
% %scatter3(x_p,y_p,z_p);
% plot3(x_s(A==2),y_s(A==2),z_s(A==2),'-');
% scatter3(x_s(GFPOnSphere == 1), y_s(GFPOnSphere == 1), z_s(GFPOnSphere == 1 ),50,[1 0 0]); 
% hold off;
% axis vis3d equal;
% view([-37.5, -75])