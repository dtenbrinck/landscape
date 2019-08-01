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

% change reference point and refernce vector to z-value of head positions
% if needed for proofOfPrinciple
%if p.proofOfPrinciple > 1
%zwert = pstar(3);
%reference_point = [-sqrt(1-zwert^2); 0; zwert]; 
%if zwert < 0  
    %reference_vector = [-1; 0; -sqrt(1-zwert^2)/zwert];
    %reference_vector = reference_vector * 1/norm(p.reg.reference_vector); 
%elseif zwert > 0  
    %reference_vector = [1; 0; sqrt(1-zwert^2)/zwert];
    %reference_vector = reference_vector * 1/norm(p.reg.reference_vector); 
    %reference_point = [-1; 0; 0]; 
    %reference_vector = [0; 0; -1]; 
%end
%end

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

