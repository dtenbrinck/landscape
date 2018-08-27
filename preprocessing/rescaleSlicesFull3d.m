function resized_data = rescaleSlicesFull3d( data, scale, method )

% check if interpolation method is specified
if nargin == 2
  method = 'linear';
end

% check if we have a struct
if isstruct(data)
  
  % initialize struct for rescaled data
  resized_data = data;
  
  % Include mCherry channel if needed
  if isfield(data, 'mCherry')
    % Rescale mCherry data for higher processing speed using trilinear interpolation
    resized_data.mCherry = imresize3(data.mCherry, scale, method);
  end
  
  % Rescale Dapi and GFP data for higher processing speed using trilinear interpolation
  resized_data.Dapi    = imresize3(data.Dapi, scale, method);
  resized_data.GFP     = imresize3(data.GFP, scale, method);
  
else % otherwise rescale data directly
                                       
  % Rescale data for higher processing speed using trilinear interpolation
  resized_data = imresize3(data, scale, method);
  
end
end

