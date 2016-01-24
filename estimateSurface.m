function [radii surface] = estimateSurface(mask, center,radius_embryo)

% determine size of data
[N(1), N(2), N(3)] = size(mask);

% initialize mask for surface of embryo
surface = zeros(N);

% initialize vector to collect radii (min and max)
radii = zeros(N(3), 2);

% compute radial integrals by checking every pixel (linear time)
for z = 1:N(3)
    
    % determine largest radius possible
    distances = N(1:2) - center(z,:);
    
    % set maximum radius to search for
    if nargin == 3
        maxRadius = radius_embryo;
    else
        maxRadius = 2*floor(max(distances));
    end
        
    % initialize empty integral
    integral = zeros(1,maxRadius);
    
    for y = 1:N(1)
        for x = 1:N(2)
            
            % check if mask has 1
            if mask(y,x,z) == 1
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
    
    threshold = 5* circumference; % TODO check for robustness
    
    
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
                surface(y,x,z) = 1;
            end
                    
        end
    end
end