function transformedCoordinates = transformCoordinates(originalCoordinates, originalCenter, transformationMatrix, newCenter)
%TRANSFORMCOORDINATES Summary of this function goes here
%   Detailed explanation goes here

transformedCoordinates =  (originalCoordinates - repmat(originalCenter',size(originalCoordinates,1),1)) ...
                         * transformationMatrix ...
                         + repmat(newCenter',size(originalCoordinates,1),1);

end

