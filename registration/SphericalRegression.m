close all;
%% DONT DELETE!!! DATA FROM PAPER!
t=0:1/4:1;
pv0 = [1;0;0;0;1;0];
p = pv0(1:3);
v = pv0(4:6);
P = [-0.89,0.8243,-0.9164,-0.9383, 0.0192;...
    -0.3941, -0.2085, -0.158, 0.3022, -0.7635;...
    -0.2292, 0.5264, -0.3678, 0.1678, 0.6455];


%% data symmetric
P = [0.5 0.5 0.5 0.5;...
    0.25 0.25 0.25 0.25;...
    1 1 1 1];
    

%% data 2 points!
P = [0.1585, -0.5605;...
    -0.8624, 0.4575;...
    0.4807, 0.6903];
%%
[pstar2,vstar2] = sphericalRegression3D(P,p,v);
% % Geodesic regression problem on the unit sphere
% 
%% WORK WITH DATA c.cFROM RUN_ME
data1 = round(x_s(GFPOnSphere == 1 & z_s <= 0)*10^10)/10^10;
data2 = round(y_s(GFPOnSphere == 1 & z_s <= 0)*10^10)/10^10;
data3 =  round(z_s(GFPOnSphere == 1 & z_s <= 0)*10^10)/10^10;
data = [data1';data2';data3'];
data = unique(data','rows')';
tic
[pstar,vstar] = sphericalRegression3D(data,[1;0;0],[0;0;-1]);
toc