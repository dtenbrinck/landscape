function [center_points, radii, radii_disc, surface3D] = fitCircles(sharp_areas)

% determine global threshold to detect sharp areas
threshold = kittler_thresholding(sharp_areas);

% determine number of slices
number_of_slices = size(sharp_areas,3);

% initialize array for center points and radii
center_points = zeros(number_of_slices,2);
radii = zeros(number_of_slices,1);

%process slice by slice
for slice = 1:number_of_slices
  
  % determine sharp points
  sharp_points = find(sharp_areas(:,:,slice) > threshold);
  
  % check if we have enough points for estimation
  if numel(sharp_points) < 100
    continue;
  end
  
  % convert indices to coordinates
  [Y, X] = ind2sub(size(sharp_areas),sharp_points);
  
  % fit best circle using Gauss-Newton approach
  [center_x, center_y, radius] = gaussNewton(cat(2,Y,X));
  
  % set output variables
  center_points(slice,:) = [center_y, center_x];
  radii(slice) = radius;
end

% post-processing: determine beginning of data
for slice = 2:number_of_slices/2
  if radii(slice) - radii(slice-1) < 0
    radii(1:slice-1) = 0;
    center_points(1:slice-1,:) = repmat([0, 0],slice-1,1);
  end
end

% post-processing: determine end of data
max_index = find(radii == max(radii));
radii(max_index+1:end) = 0;
center_points(max_index+1:end,1) = 0;
center_points(max_index+1:end,2) = 0;

% estimate 3D surface
[radii_disc, surface3D] = estimateSurface(double(sharp_areas > threshold), center_points);

end