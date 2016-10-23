function regression_Function = testWrapper( data )
%TESTWRAPPER Summary of this function goes here
%   Detailed explanation goes here

regression_Function = @(input) computeDistanceToGreatCircle(input(1:3)/norm(input(1:3)), input(4:6)/norm(input(4:6)), data);

end

