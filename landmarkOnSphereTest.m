close all;
%radius of ellipsoid
radii;
samples = 64; %samples < min(sizeRes);
%punkte der sphere berechnen in dem raum von landmark
sizeRes = size(landmark).*resolution;

%generate ellipsoid on the domain of landmark at centerpoint.

[x,y,z] = ind2sub(size(landmark),find(landmark));
%coordinates in the correct resolution
x = x*resolution(1);
y = y*resolution(2);
z = z*resolution(3);

%find the vectors from the center to the point [x(i),y(i),z(i)]

CX = x-center(1);
CY = y-center(2);
CZ = z-center(3);

% shrink them down to the unitsphere

uCX = CX/radii(1);
uCY = CY/radii(2);
uCZ = CZ/radii(3);

uCenter(1) = center(1)/radii(1);
uCenter(2) = center(2)/radii(2);
uCenter(3) = center(3)/radii(3);

% Get a unit sphere
[alpha, beta] = meshgrid(linspace(pi,2*pi,samples/2), linspace(0,2*pi,samples)); % TODO: only one time 2*pi!
z_s = cos(alpha) .* sin(beta);
x_s = sin(alpha) .* sin(beta);
y_s = cos(beta);

x_e = (x_s+uCenter(1))*radii(1);
y_e = (y_s+uCenter(2))*radii(2);
z_e = (z_s+uCenter(3))*radii(3);

%% Faster way

x_d = x/radii(2);
y_d = y/radii(1);
z_d = z/radii(3);

%% Projection on sphere

%% INTERP3



%% OLD TRY

a = sqrt(1-(x_d-uCenter(2)).^2-(y_d-uCenter(1)).^2)-(z_d-uCenter(3));
z_d2 = z_d+a;
% sample the points onto the samplepoints of the sphere. Get there angles
% and then compute the nearest ankle of a samplepoint.
alpha2 = atan((y_d-uCenter(1))./(x_d-uCenter(2)));
beta2 = acos(z_d2-uCenter(3));
x_s2 = sin(beta2) .* cos(alpha2);
y_s2 = sin(beta2) .* sin(alpha2);
z_s2 = cos(beta2);
%data = [y_d';x_d';z_d2'];

%% figures
% figure,scatter3(y_s(:),z_s(:),x_s(:))
% hold on
% scatter3(center(1),center(2),center(3));
% scatter3(x,y,z);
% hold off
x_s = x_s+uCenter(1);
y_s = y_s+uCenter(2);
z_s = z_s+uCenter(3);

% figure,scatter3(x_s(:),y_s(:),z_s(:))
% axis('equal')
% hold on
% scatter3(uCenter(1),uCenter(2),uCenter(3));
% scatter3(y_d,x_d,z_d);
% hold off

figure,scatter3(x_s(:),y_s(:),z_s(:))
axis('equal')
hold on
scatter3(uCenter(1),uCenter(2),uCenter(3));
scatter3(y_s2+uCenter(1),x_s2+uCenter(2),z_s2+uCenter(3));
hold off


figure,scatter3(x_s(:),y_s(:),z_s(:))
axis('equal')
hold on
scatter3(uCenter(1),uCenter(2),uCenter(3));
scatter3(y_d,x_d,z_d2);
hold off


% figure,scatter3(z_s(:),x_s(:),y_s(:))
% axis('equal')
% hold on
% normsderp = sqrt(uCX(:).^2+uCY(:).^2+uCZ(:).^2);
% scatter3(uCenter(1),uCenter(2),uCenter(3));
% scatter3(uCY+uCenter(2),uCX+uCenter(1),uCZ+uCenter(3));
% hold off



% figure,scatter3(x_e(:),y_e(:),z_e(:))
% axis('equal');
% hold on
% scatter3(y(:),x(:),z(:));
% hold off

% figure,scatter3(z_s(:),x_s(:),y_s(:))
% hold on
% scatter3(uCenter(1),uCenter(2),uCenter(3));
% normsderp = sqrt(uCX(:).^2+uCY(:).^2+uCZ(:).^2);
% scatter3(uCX./normsderp+uCenter(1),uCY./normsderp+uCenter(2),uCZ./normsderp+uCenter(3));
% hold off


