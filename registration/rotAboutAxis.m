function [R] = rotAboutAxis(theta,u)
%ROTABOUTAXIS: This function computes the rotation matrix that
% rotates points anti-clockwise about an axis in the direction of u by the 
% angle theta. The math is described in the following. 

%% Math:
% Let $u$ be a unit vector, so $\Vert u\Vert = 1$. The rotation matrix is
% than given by:
% $ R = cos(\theta)I+sin(\theta)[u]_x+(1-cos(\theta))u\otimes u$.
% With $[u]_x$ as the cross product matrix and $u\otimes u$ as the tensor
% product.

%% Input %%
%   theta:      rotation angle about the axis.
%   u:          unit vector. Direction of the axis.
%% Output %%
%   R:          rotation about axis u with angle -theta
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Main Code %%

% Compute [u]_x
ux = [0,-u(3),u(2);u(3), 0, -u(1); -u(2),u(1),0];

% Compute tensor product
tensorproduct = [u(1)^2,u(1)*u(2),u(1)*u(3);...
    u(1)*u(2),u(2)^2,u(2)*u(3);...
    u(1)*u(3),u(2)*u(3),u(3)^2];

% Compute R
R = cos(-theta)*eye(3) + sin(-theta)*ux +(1-cos(-theta))*tensorproduct;

end

