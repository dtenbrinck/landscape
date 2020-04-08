function transformation = registerLandmark( landmarkCoordinates, reg_parameter)
%REGISTERLANDMARK Summary of this function goes here
%   Detailed explanation goes here

reference_point = reg_parameter.reference_point;
reference_vector = reg_parameter.reference_vector;   
landmarkCharacteristic = reg_parameter.landmarkCharacteristic;
weight = reg_parameter.characteristicWeight;

% Compute regression

[pstar,vstar] = computeRegression_new(landmarkCoordinates','false');

% Tilt refpstar onto the specified position
[pstar,vstar] = getCharPos_daniel(pstar,vstar,landmarkCoordinates',landmarkCharacteristic,weight);
pstar = pstar/norm(pstar);
vstar = vstar/norm(vstar);

% visualization for debugging
%visualizeRegression( landmarkCoordinates, pstar, vstar, reference_point, reference_vector ) 

% Rotationmatrix: Rotate the great circle s.t. pstar is on refpstar
[Rp,~,~,~,vAngle]...
    = rotateGreatCircle(pstar,vstar,reference_point,reference_vector);

% Rotationmatrix: Rotates the regression line onto the reference line
Ra = rotAboutAxis(vAngle,reference_point);

transformation = Ra * Rp;

%pstar = Rp*pstar;
%vstar = Ra*Rp*vstar;
%transformedCoordinates = transformation * landmarkCoordinates';

% Compute regression
% [pstar2,vstar2,Tstar2] = computeRegression_new(transformed_Coordinates,'false');
% 
% % Tilt refpstar onto the specified position
% [pstar2,vstar2] = getCharPos_new(pstar2,vstar2,Tstar2,transformed_Coordinates',landmarkCharacteristic);

% visualization for debugging
%visualizeRegression( transformedCoordinates, pstar, vstar, reference_point, reference_vector )

end

