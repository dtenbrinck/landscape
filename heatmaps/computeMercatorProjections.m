function mercatorProjections = computeMercatorProjections(shells, resolution)

% determine number of shells for which a mercator projection has to be computed
numberOfShells = size(shells,2);

% initialize container for mercator projections
mercatorProjections = zeros(resolution(1), resolution(2), numberOfShells);

% define rotation matrices for correct map computation
angle = -pi/2;
Rx = [1 0 0; 0 cos(angle) -sin(angle); 0 sin(angle) cos(angle)];
Ry = [cos(angle) 0 sin(angle); 0 1 0; -sin(angle) 0 cos(angle)];
    
% iterate over all shells starting from the outside
for currentShell=1:numberOfShells
    
    % ignore empty shells
    if size(shells{currentShell},1) == 0
        continue;
    end
    
    % extract coordinates in current shell
    coordinates = shells{currentShell};
    
    % rotate coordinates into correct position
    coordinates =  Rx* Ry * coordinates;
    
    % extract coordinates for easier implementation
    X = coordinates(1,:);
    Y = coordinates(2,:);
    Z = coordinates(3,:);
    
    % determine distance to origin for all coordinates
    radius = sqrt(X.^2 + Y.^2 + Z.^2);
    
    % normalize all coordinates to have same length within shell
    X = X ./ radius;
    Y = Y ./ radius;
    Z = Z ./ radius;
    
    % compute polar coordinates from Eucliean coordinates
    theta = pi/2 - atan(Z ./ sqrt(X.^2 + Y.^2));
    phi = atan2(Y,X);
    
    % determine latitude and longitude in degree (for debugging mainly!)
    latitude = theta * 360 / (2*pi);
    longitude = phi * 360 / (2*pi);
    
    % TODO: This is not well implemented yet
    % shift indices into positive interval and respect resolution of heatmap
    indicesLatitude = round(latitude * resolution(1)/180) + 1;
    indicesLongitude = round( (longitude + 180) * resolution(2)/360 ) + 1 ;
    
    % TODO: Remove this hack by computing the indices correctly above!
    % Sometimes the round operation gives indices == 0 or indices ==
    % resolution + 1, so we need to fix this manually currently.
    indicesLatitude(indicesLatitude <= 0) = 1;
    indicesLatitude(indicesLatitude > resolution(1)) = resolution(1);
    indicesLongitude(indicesLongitude <= 0) = 1;
    indicesLongitude(indicesLongitude > resolution(2)) = resolution(2);
       
    % transform sub indices into linear indices
    indPoints = sub2ind(resolution, indicesLatitude, indicesLongitude);

    % accumulate points in the same heatmap cell
    accumulator = reshape(accumarray(indPoints',ones(size(indPoints')),[prod(resolution) 1]), resolution);
   
    % show heatmap (debugging only!)
    %figure; imagesc(accumulator);
    
    % save mercator projection
    mercatorProjections(:,:,currentShell) = accumulator;

end

end