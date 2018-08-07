function resized_data = rescaleSlices( data, scale, method )

% check if interpolation method is specified
if nargin == 2
  method = 'bilinear';
end

% check if we have a struct
if isstruct(data)
  
  % initialize struct for rescaled data
  resized_data = data;
  resized_data.Dapi = zeros(ceil(scale * size(data.Dapi,1)),...
                            ceil(scale * size(data.Dapi,2)),...
                                         size(data.Dapi,3));
  resized_data.GFP      = resized_data.Dapi;
  
  % Rescale data for higher processing speed using trilinear interpolation
  for i=1:size(data.Dapi,3)
    resized_data.Dapi(:,:,i)    = imresize(data.Dapi(:,:,i), scale, method);
    resized_data.GFP(:,:,i)     = imresize(data.GFP(:,:,i), scale, method);
  end
  
else % otherwise rescale data directly
  
  resized_data = zeros(ceil(scale * size(data,1)),...
                       ceil(scale * size(data,2)),...
                                    size(data,3));
                                       
  % Rescale data for higher processing speed using trilinear interpolation
  for i=1:size(data,3)
    resized_data(:,:,i) = imresize(data(:,:,i), scale, method);
  end
  
end
end

