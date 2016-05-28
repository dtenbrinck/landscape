function kernel = generate3dLaplacian( resolution )
%GENERATE3DLAPLACIAN Summary of this function goes here
%   Detailed explanation goes here

% compute terms for anisotropic Laplacian finite difference stencil
y = 1 / resolution(1);
x = 1 / resolution(2);
z = 1 / resolution(3);
center = 2*(x+y+z);

% set size and half size of kernel
ks = [3, 3, 3];
khs = floor(ks/2);

% initialize 3D Laplacian kernel
kernel = zeros(ks);
kernel(:,:,1) = [0 0 0; 0 z 0; 0 0 0];
kernel(:,:,2) = [0 y 0; x -center x; 0 y 0];
kernel(:,:,3) = [0 0 0; 0 z 0; 0 0 0];
kernel = -kernel;

end

