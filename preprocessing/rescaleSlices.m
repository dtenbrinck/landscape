function resized_data = rescaleSlices( data, scale )

% initialize struct for rescaled data
resized_data = data;
resized_data.Dapi = zeros(round(scale * size(data.Dapi,1)),...
                          round(scale * size(data.Dapi,2)),...
                                        size(data.Dapi,3));
resized_data.GFP      = resized_data.Dapi;
resized_data.mCherry  = resized_data.Dapi;

% adapt x-/y-resolution with respect to new scale
resized_data.x_resolution = resized_data.x_resolution / scale;
resized_data.y_resolution = resized_data.y_resolution / scale;

% Rescale data for higher processing speed using trilinear interpolation
for i=1:size(data.Dapi,3)
  resized_data.Dapi(:,:,i)    = imresize(data.Dapi(:,:,i), scale);
  resized_data.GFP(:,:,i)     = imresize(data.GFP(:,:,i), scale);
  resized_data.mCherry(:,:,i) = imresize(data.mCherry(:,:,i), scale);
end

end

