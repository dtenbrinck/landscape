function [radii surface3D] = estimateSurface(mask3D, center)

% determine size of data
N = size(mask3D);

% initialize mask for 3D surface of embryo
surface3D = zeros(N);

% initialize vector to collect radii (min and max)
radii = zeros(N(3), 2);

% compute radial integrals by checking every pixel (linear time)
for z = 1:N(3)
    
    % determine largest radius possible
    distances = N(1:2) - center(z,:);
    maxRadius = floor(max(distances));
    
    % initialize empty integral
    integral = zeros(1,maxRadius);
    
    for y = 1:N(1)
        for x = 1:N(2)
            
            % check if mask has 1
            if mask3D(y,x,z) == 1
                d = norm([y,x] - center(z,:));
                
                % make sure pixel is not outside of maximal radius
                if d < maxRadius
                    
                    % add value to all circles with radius bigger than d
                    integral(ceil(d):end) = integral(ceil(d):end) + 1;
                    
                end
            end
        end
    end
    
    % TODO: comments
    innerRadius = find(integral(:) > 0);
    
    if(isempty(innerRadius))
        innerRadius = 0;
    else
        innerRadius = min(innerRadius) - 1;
    end
    circumference = 2 * pi * innerRadius;
    
    threshold = 5*circumference; % TODO check for robustness
    
    
    % get indices that are interesting
    indices = intersect(find(integral(:) > threshold), find(integral(:) < integral(end)));
    if isempty(indices)
        radii(z,:) = [0 0];
    else
        radii(z,:) = [min(indices(:))-1, max(indices(:))-1];
    end
    
    for y = 1:N(1)
        for x = 1:N(2)
        
            d = norm([y,x] - center(z,:));
             
            if radii(z,1) <= d & radii(z,2) >= d
                % set current position as part of surface
                surface3D(y,x,z) = 1;
            end
                    
        end
    end
end