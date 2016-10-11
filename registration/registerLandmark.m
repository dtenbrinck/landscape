function [ output_args ] = registerLandmark( landmarkCoordinates, pstar_reference, vstar_reference, landmarkCharacteristic)
%REGISTERLANDMARK Summary of this function goes here
%   Detailed explanation goes here

 % Compute regression
    [pstar,vstar] = computeRegression(landmarkCoordinates','false');
    
    % Tilt refpstar onto the specified position
    [refpstar,refvstar] = getCharPos(pstar_reference,vstar_reference,landmarkCoordinates',landmarkCharacteristic);
    
    % Rotationmatrix: Rotate the great circle s.t. pstar is on refpstar
    [Rp,Rv,pstar_r,vstar_r,vAngle]...
        = rotateGreatCircle(pstar,vstar,refpstar,refvstar);
    
    % Rotationmatrix: Rotates the regression line onto the reference line
    Ra = rotAboutAxis(vAngle,refpstar);
    
    % Rotate data set and cell coordinates
    regData_r = Ra*Rp*regData;
    handles.SegData.(fieldname).centCoords ...
        = Ra*Rp*handles.SegData.(fieldname).centCoords;

end

