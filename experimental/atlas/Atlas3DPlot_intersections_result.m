% INITIALIZATION
clear; clc; close all;

% load necessary variables
root_dir = fileparts(fileparts(pwd));
addpath([root_dir '/parameter_setup/']);
p = initializeScript('processing', root_dir);
p.resolution = [1.1512, 1.1512, 5];   % 30 percent scale

% Select the registered data
dname = uigetfile(p.dataPath,'Please select the intersection data!'); % Select all files to see the data
dname_2 = uigetfile(p.dataPath,'Please select the accumulator data!');

load([p.dataPath '\' dname]);
load([p.dataPath '\' dname_2]);

acc = zeros(256,256,256);
acc(1:255,1:255,1:255) = currentAccumulator;

accumulator = acc;

[X1, Y1, Z1] = sphere(50);
X1 = 116 * X1;
Y1 = 116 * Y1;
Z1 = 116 * Z1;
X1 = X1 + 128;
Y1 = Y1 + 128;
Z1 = Z1 + 128;

registeredData.Dapi = intersection_registration_threshold.Dapi .* accumulator;
registeredData.landmark = intersection_registration_threshold.landmark .* accumulator;
registeredData.mesoderm = intersection_registration_threshold.mesoderm .* accumulator;
registeredData.ecto = intersection_registration_threshold.ectoderm .* accumulator;

% Dapi
figure
data = registeredData.Dapi;
data = smooth3(data,'box',1);
patch(isocaps(data,.5),...
   'FaceColor','interp','EdgeColor','none');
p1 = patch(isosurface(data,.5),...
   'FaceColor','b','EdgeColor','none');
alpha(0.3);
isonormals(data,p1);
view(3); 
set(gca,'ZDir','reverse'); 
xlabel('x');
ylabel('y');
zlabel('z');
axis vis3d tight
camlight left
colormap('jet');
lighting gouraud
title([dname(1) '\_' dname(3) '\_' dname(5:6) '\_ registered data 3D Dapi plot']);
axis equal
hold on
surf(X1, Y1, Z1,'FaceAlpha', .15, 'FaceColor', 'b', 'EdgeColor', 'none', 'DisplayName', 'unit sphere' );
hold off
savefig([p.resultsPath '\' dname(1) '_' dname(3) '_' dname(5:6) '_Dapi_3D_Plot.fig'])

% Landmark Plot
figure
data = registeredData.landmark;
data = smooth3(data,'box',1);
patch(isocaps(data,.5),...
   'FaceColor','interp','EdgeColor','none');
p1 = patch(isosurface(data,.5),...
   'FaceColor','r','EdgeColor','none');
alpha(0.3);
isonormals(data,p1);
view(3); 
set(gca,'ZDir','reverse'); 
xlabel('x');
ylabel('y');
zlabel('z');
axis vis3d tight
camlight left
colormap('jet');
lighting gouraud
title([dname(1) '\_' dname(3) '\_' dname(5:6) '\_ registered data 3D landmark plot']);
axis equal
hold on
surf(X1, Y1, Z1,'FaceAlpha', .15, 'FaceColor', 'b', 'EdgeColor', 'none', 'DisplayName', 'unit sphere' );
hold off
savefig([p.resultsPath '\' dname(1) '_' dname(3) '_' dname(5:6) '_landmark_3D_Plot.fig'])

% Mesoderm
figure
data = registeredData.mesoderm;
data = smooth3(data,'box',1);
patch(isocaps(data,.5),...
   'FaceColor','interp','EdgeColor','none');
p1 = patch(isosurface(data,.5),...
   'FaceColor','y','EdgeColor','none');
alpha(0.3);
isonormals(data,p1);
view(3); 
set(gca,'ZDir','reverse'); 
xlabel('x');
ylabel('y');
zlabel('z');
axis vis3d tight
camlight left
colormap('jet');
lighting gouraud
title([dname(1) '\_' dname(3) '\_' dname(5:6) '\_ registered data 3D mesoderm plot']);
axis equal
hold on
surf(X1, Y1, Z1,'FaceAlpha', .15, 'FaceColor', 'b', 'EdgeColor', 'none', 'DisplayName', 'unit sphere' );
hold off
savefig([p.resultsPath '\' dname(1) '_' dname(3) '_' dname(5:6) '_mesoderm_3D_Plot.fig'])

% Ectoderm/Endoderm plot
figure
data = registeredData.ecto;
data = smooth3(data,'box',1);
patch(isocaps(data,.5),...
   'FaceColor','interp','EdgeColor','none');
p1 = patch(isosurface(data,.5),...
   'FaceColor','g','EdgeColor','none');
alpha(0.3);
isonormals(data,p1);
view(3); 
set(gca,'ZDir','reverse'); 
xlabel('x');
ylabel('y');
zlabel('z');
axis vis3d tight
camlight left
colormap('jet');
lighting gouraud
title([dname(1) '\_' dname(3) '\_' dname(5:6) '\_ registered data 3D ectoderm plot']);
axis equal
hold on
surf(X1, Y1, Z1,'FaceAlpha', .15, 'FaceColor', 'b', 'EdgeColor', 'none', 'DisplayName', 'unit sphere' );
hold off
savefig([p.resultsPath '\' dname(1) '_' dname(3) '_' dname(5:6) '_ectoderm_3D_Plot.fig'])


registeredData.endo = intersection_registration_threshold.endoderm .* accumulator;

% Ectoderm/Endoderm plot
figure
data = registeredData.endo;
data = smooth3(data,'box',1);
patch(isocaps(data,.5),...
   'FaceColor','interp','EdgeColor','none');
p1 = patch(isosurface(data,.5),...
   'FaceColor','g','EdgeColor','none');
alpha(0.3);
isonormals(data,p1);
view(3); 
set(gca,'ZDir','reverse'); 
xlabel('x');
ylabel('y');
zlabel('z');
axis vis3d tight
camlight left
colormap('jet');
lighting gouraud
title([dname(1) '\_' dname(3) '\_' dname(5:6) '\_ registered data 3D endoderm plot']);
axis equal
hold on
surf(X1, Y1, Z1,'FaceAlpha', .15, 'FaceColor', 'b', 'EdgeColor', 'none', 'DisplayName', 'unit sphere' );
hold off
savefig([p.resultsPath '\' dname(1) '_' dname(3) '_' dname(5:6) '_endoderm_3D_Plot.fig'])


rest = max(0,accumulator - (registeredData.landmark + registeredData.mesoderm + registeredData.ecto + registeredData.endo));

figure
data = rest;
data = smooth3(data,'box',1);
patch(isocaps(data,.5),...
   'FaceColor','interp','EdgeColor','none');
p1 = patch(isosurface(data,.5),...
   'FaceColor','g','EdgeColor','none');
alpha(0.3);
isonormals(data,p1);
view(3); 
set(gca,'ZDir','reverse'); 
xlabel('x');
ylabel('y');
zlabel('z');
axis vis3d tight
camlight left
colormap('jet');
lighting gouraud
title([dname(1) '\_' dname(3) '\_' dname(5:6) '\_registered data 3D rest plot']);
axis equal
hold on
surf(X1, Y1, Z1,'FaceAlpha', .15, 'FaceColor', 'b', 'EdgeColor', 'none', 'DisplayName', 'unit sphere' );
hold off
savefig([p.resultsPath '\' dname(1) '_' dname(3) '_' dname(5:6) '_rest_3D_Plot.fig'])
% title(['All data plot' dname(1) '\_' dname(3:17)]);
% legend('Landmark','Dapi','Ectoderm','Mesoderm')
% hold off