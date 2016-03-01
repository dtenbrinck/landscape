function fitEllipsoid( sharp_areas )
%FITELLIPSOID Summary of this function goes here
%   Detailed explanation goes here

% determine global threshold to detect sharp areas
threshold = kittler_thresholding(sharp_areas);

% determine sharp points
sharp_points = find(sharp_areas > threshold);

% convert indices to coordinates
[Y, X, Z] = ind2sub(size(sharp_areas),sharp_points);

% guess initial center
initialCenter = round(size(sharp_areas) / 2)';

% fit best ellipsoid using Gauss-Newton approach
[center A] = gaussNewtonEllipsoid(cat(1,Y',X',Z'), initialCenter);

end

