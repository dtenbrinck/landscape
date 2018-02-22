function [ ellipsoid ] = estimateEmbryoSurface2( nuclei_coord, resolution )
Y = (nuclei_coord(1,:) * resolution(1))';
X = (nuclei_coord(2,:) * resolution(2))';
Z = (nuclei_coord(3,:) * resolution(3))';

% fit ellipsoid to sharp points in areas in focus
[ ellipsoid.center, ellipsoid.radii, ellipsoid.axes, ellipsoid.v] = estimateMinimumEllipsoid( [ X Y Z ] );


% check axes orientation and flip if necessary
orientation = diag(ellipsoid.axes);
for i=1:3
    if orientation(i) < 0
        ellipsoid.axes(:,i) = -ellipsoid.axes(:,i);
    end
end

end

