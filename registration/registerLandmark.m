function transformation = registerLandmark( landmarkCoordinates, reg_parameter)
%REGISTERLANDMARK calculates a rotation matrix that aligns the given
%landmark to the location specified by reg_parameter
%% Input:
%   landmarkCoordinates:        nx3 matrix
%% Output:
%   transformation:             3x3 rotation matrix
%% Parameters:
%   reg_parameter:              Struct containing the parameters that specify the
%                               desired landmark rotation
%       characteristicWeight:               Ratio that picks a point between the start (0) and the end (1) of the landmark.
%                                           It will become the starting point pstar of the regression line (great circle).  
%       reference_point, reference_vector:  Define a second great circle. The regression line will be aligned to it s.t. pstar = reference_point. 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Main Code:

weight = reg_parameter.characteristicWeight;
reference_point = reg_parameter.reference_point;
reference_vector = reg_parameter.reference_vector;   

% Compute regression (great circle) of landmarkCoordinates
[pstar,vstar] = computeRegression_new(landmarkCoordinates');

% Move pstar along the great circle s.t. it is on the position specified
% by weight
[pstar,vstar] = getCharPos_daniel(pstar,vstar,landmarkCoordinates',weight);
pstar = pstar/norm(pstar);
vstar = vstar/norm(vstar);

% Rotationmatrix: Rotate the great circle s.t. pstar is on reference_point
% and vstar points into the same direction as reference_vector??
%TODO: What is the difference between Rp and Ra? Add correct commentary. 
[Rp,~,~,~,vAngle]...
    = rotateGreatCircle(pstar,vstar,reference_point,reference_vector);

% Rotationmatrix: Rotates the regression line onto the reference line
Ra = rotAboutAxis(vAngle,reference_point);

% Final rotation matrix
transformation = Ra * Rp;

end
