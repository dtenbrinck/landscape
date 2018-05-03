function [ ellipsoid ] = estimateEmbryoSurface( nuclei_coord, resolution )
X = (nuclei_coord(1,:) * resolution(1))';
Y = (nuclei_coord(2,:) * resolution(2))';
Z = (nuclei_coord(3,:) * resolution(3))';

% fit ellipsoid to sharp points in areas in focus
regularisationParams.mu0 = 10^-8;
regularisationParams.mu1 = 0; 
regularisationParams.mu2 = 0.02; 
regularisationParams.mu3 = 1;
regularisationParams.gamma = 1; 
[ ellipsoid.center, ellipsoid.radii, ellipsoid.axes, ~,~,~,~] = ...
    getEllipsoidCharacteristicsInitialReferenceEstimation...
    ( [ X Y Z ], 'cg', regularisationParams, 1 );

% check axes orientation and flip if necessary
orientation = diag(ellipsoid.axes);
for i=1:3
    if orientation(i) < 0
        ellipsoid.axes(:,i) = -ellipsoid.axes(:,i);
    end
end

end

