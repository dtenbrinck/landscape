function [ transformation ] = computeTransformationMatrix( ellipsoid )
%COMPUTETRANSFORMATIONMATRIX: This function computes the transformation 
%to transform the given ellipsoid to unit sphere
%% Input:
% ellipsoid:       struct containing the information about the ellipsoid
%                  ellipsoid.radii: 3x1 vector
%                  ellipsoid.axes: 3x3 matrix
%% Output:
% transformation: 3x3 matrix
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Code

transformation = diag(ellipsoid.radii(:)) * ellipsoid.axes;

end

