function transformedCoordinates = transformCoordinates(originalCoordinates, originalCenter, transformationMatrix, newCenter)
%TRANSFORMCOORDINATES Summary of this function goes here
%   Detailed explanation goes here

% translate coordinates to center
transformedCoordinates =  (originalCoordinates - repmat(originalCenter',size(originalCoordinates,1),1))';

% scale coordinates
transformedCoordinates = transformationMatrix * transformedCoordinates;
                
% translate to target center point
transformedCoordinates = transformedCoordinates + repmat(newCenter,1,size(originalCoordinates,1));

end

