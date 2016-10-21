function [ transformation ] = computeTransformationMatrix( ellipsoid )
%COMP Summary of this function goes here
%   Detailed explanation goes here

% compute transformation to transform ellisoid to unit sphere
transformation = diag(ellipsoid.radii(:)) * ellipsoid.axes;

end
