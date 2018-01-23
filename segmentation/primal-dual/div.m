%DIV Computation of the divergence of a vector field.
%   DIVERGENCE = DIV(V, DATAP) expects a vector field V and the struct
%   DATAP containing the relevant parameters of the data, i.e., grid width
%   and spatial dimensions. 
%
%   Example:
%   --------
%   v = rand(20,30,1,2);
%   dataP.hx = 1; dataP.hy = 1; dataP.dim = 2; dataP.nx = size(v,1); dataP.ny = size(v,2);
%   div_v = div(v, dataP);
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
function divergence = div(v,dataP)

% compute divergence via forward euler discretization with zero gradient
% boundary (cf. [1])
divergence = dataP.hx^(-1) * cat(1, v(1,:,:,1), v(2:dataP.nx-1,:,:,1) - v(1:dataP.nx-2,:,:,1), -v(dataP.nx-1,:,:,1));

% in case of 2D image add derivatives with respect to y-direction
if (dataP.dim >= 2)
    divergence = divergence + dataP.hy^(-1) * cat(2, v(:,1,:,2), v(:,2:dataP.ny-1,:,2) - v(:,1:dataP.ny-2,:,2), -v(:,dataP.ny-1,:,2));
end

% in case of 3D data add derivatives with respect to z-direction
if (dataP.dim >= 3)
    divergence = divergence + dataP.hz^(-1) * cat(3, v(:,:,1,3), v(:,:,2:dataP.nz-1,3) - v(:,:,1:dataP.nz-2,3), -v(:,:,dataP.nz-1,3));
end

end

% % VARIANT: compute divergence with periodic boundary values (cf. [1])
% divergence = dataP.hx^(-1) * (v(:,:,:,1) - v([dataP.nx, 1:dataP.nx-1],:,:,1));
% 
% % in case of 2D image add derivatives with respect to y-direction
% if (dataP.dim >= 2)
%     divergence = divergence + dataP.hy^(-1) * (v(:,:,:,2) - v(:,[dataP.ny, 1:dataP.ny-1],:,2));
% end
%
% % in case of 3D data add derivatives with respect to y-direction
% if (dataP.dim >= 3)
%     divergence = divergence + dataP.hz^(-1) * (v(:,:,:,3) - v(:,:,[dataP.nz 1:dataP.nz-1],3));
% end
