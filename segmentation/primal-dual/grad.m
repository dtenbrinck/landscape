%GRAD Computation of the gradient of a function.
%   GRADIENT = GRAD(U, DATAP) expects a real function and the struct DATAP
%   containing the relevant parameters of the data, i.e., grid width
%   and spatial dimensions. 
%
%   Example:
%   --------
%   u = rand(20,30);
%   dataP.hx = 1; dataP.hy = 1; dataP.dim = 2; dataP.nx = size(u,1);
%   dataP.ny = size(u,2); dataP.nz = size(u,3);
%   grad_u = grad(u, dataP);
%
%   Further details can be found in:
%   --------------------------------
%   [1] A. Chambolle, "An Algorithm for Total Variation Minimization and
%   Applications", Journal of Mathematical Imaging and Vision 10, pp. 89-97 
%   (2004)
% 
%
%   Copyright: Alex Sawatzky, Daniel Tenbrinck 
%   Department of Mathematics and Computer Science
%   University of Muenster, Germany
%   email: alex.sawatzky@wwu.de - daniel.tenbrinck@wwu.de
%   $Date: 2013/12/17 $
%
%   IMPORTANT: When using this code please cite the following publication.
%   Sawatzky A, Tenbrinck D, Jiang X, Burger M, "A Variational Framework for 
%   Region-Based Segmentation Incorporating Physical Noise Models", Journal 
%   of Mathematical Imaging and Vision, 47(3), p. 179-209 (2013)
function gradient = grad(u,dataP)

% compute gradient via forward euler discretization with zero gradient
% boundary (cf. [1])
gradient(:,:,:,1) = dataP.hx^(-1) * cat(1, u(2:dataP.nx,:,:) - u(1:dataP.nx-1,:,:), zeros(1,dataP.ny,dataP.nz));

% in case of 2D image compute also derivatives with respect to y-direction
if (dataP.dim >= 2)
    gradient(:,:,:,2) = dataP.hy^(-1) * cat(2, u(:,2:dataP.ny,:) - u(:,1:dataP.ny-1,:), zeros(dataP.nx,1,dataP.nz));
end

% in case of 3D data compute also derivatives with respect to z-direction
if (dataP.dim >= 3)
    gradient(:,:,:,3) = dataP.hz^(-1) * cat(3, u(:,:,2:dataP.nz) - u(:,:,1:dataP.nz-1), zeros(dataP.nx,dataP.ny,1));
end

end

% % VARIANT: compute gradient with periodic boundary values (cf. [1])
% gradient(:,:,:,1) = dataP.hx^(-1) * (u([2:dataP.nx, 1],:,:) - u); 
%
% % in case of 2D image compute also derivatives with respect to y-direction
% if (dataP.dim >= 2)
%    gradient(:,:,:,2) = dataP.hy^(-1) * (u(:,[2:dataP.ny, 1],:) - u); 
% end
%
% % in case of 3D data compute also derivatives with respect to z-direction
% if (p.dataDim>=3)
%    gradient(:,:,:,3) = dataP.hz^(-1) * (u(:,:,[2:dataP.nz, 1]) - u);
% end

