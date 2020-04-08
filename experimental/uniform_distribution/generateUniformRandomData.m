resolution = [128 128];
numberOfCells = 11500;

maxi =0.0015517;

% generate random polar coordinates
theta = pi*rand(numberOfCells,1);
phi = -pi/2 + pi*rand(numberOfCells,1);

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
accumulator = reshape(accumarray(indPoints,ones(size(indPoints)),[prod(resolution) 1]), resolution);

accumulator = accumulator ./ numberOfCells;

% show heatmap (debugging only!)
imagesc(accumulator,[0 maxi]); axis image; colorbar; axis off; colormap parula;
saveas(gcf,'randomHeatMap.png','png');
savefig('randomHeatMap.fig')