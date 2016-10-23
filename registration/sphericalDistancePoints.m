function spherical_distance = sphericalDistancePoints( point1, point2 )
%SPHERICALDISTANCE Summary of this function goes here
%   Detailed explanation goes here


spherical_distance = acos(point1' * point2 ./ (norm(point1) * norm(point2) ) );

end

