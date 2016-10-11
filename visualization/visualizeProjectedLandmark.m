function visualizeProjectedLandmark( sphereCoordinates, landmarkOnSphere )
%VISUALIZEPROJECTEDLANDMARK Summary of this function goes here
%   Detailed explanation goes here

size_markers = ones(size(sphereCoordinates(:,1)));
size_markers(landmarkOnSphere == 1) = 100;
size_markers(landmarkOnSphere == 0) = 5;

figure; scatter3(sphereCoordinates(:,1),sphereCoordinates(:,2),sphereCoordinates(:,3), size_markers, -1*landmarkOnSphere(:),'*');
drawnow;

end

