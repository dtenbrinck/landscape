function [radii surface3D] = estimateSurface(mask, center)

% round center coordinates
center = round(center);

% determine size of data
[N(1), N(2), N(3)] = size(mask);

% initialize mask for surface of embryo
surface3D = zeros(N);

% initialize vector to collect radii (min and max)
radii = zeros(N(3), 2);

% compute radial integrals by checking every pixel (linear time)
for z = 1:N(3)
  
  % skip for slices which are out of focus
  if center(z,:) == [0,0]
    continue;
  end
  
  % determine largest radius possible
  distances = N(1:2) - center(z,:);
  
  % set maximal search radius
  maxRadius = floor(max(distances));
  
  % initialize empty integral
  integral = zeros(1,maxRadius);
  
  % iterate over all pixels
  for y = 1:N(1)
    for x = 1:N(2)
      
      % check if mask has 1
      if mask(y,x,z) == 1
        d = norm([y,x] - center(z,:));
        
        % make sure pixel is not outside of maximal radius
        if d < maxRadius
          
          % add value to all circles with radius bigger than d
          integral(ceil(d)+1:end) = integral(ceil(d)+1:end) + 1;
          
        end
      end
    end
  end
  
  
  % get indices that are interesting
  indices = intersect(find(integral(:) > 0.05*integral(end)), find(integral(:) < 0.80*integral(end)));
  
  % sanity check
  if isempty(indices)
    error('Something strange here!');
  end
  
  % get smallest detected radius
  radii(z,1) = indices(1)-1;
  
  % if radius is very small it is likely that we are in first slice of embryo
  if min(indices(:)) < 15
    radii(z,1) = 0; % set radius to be zero in this case
  end
  
  % get largest detected radius
  radii(z,2) = indices(end)-1;
  
  % generate mask for 3D surface
  for y = 1:N(1)
    for x = 1:N(2)
      
      % compute distance of current pixel to center point
      d = norm([y,x] - center(z,:));
      
      % if pixel is in disc -> mark it
      if radii(z,1) <= d && radii(z,2) >= d
        % set current position as part of surface
        surface3D(y,x,z) = 1;
      end
      
    end
  end
end