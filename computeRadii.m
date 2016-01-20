function radii = computeRadii(mask3D, center)

% determine size of data
N = size(mask3D);

% determine largest radius possible
distances = N(1:2) - center;
maxRadius = floor(max(distances));

% initialize empty integral
integral = zeros(N(3),maxRadius);

% initialize vector to collect radii (min and max)
radii = zeros(N(3), 2);


% compute radial integrals by checking every pixel (linear time)
for z = 1:N(3)
    for y = 1:N(1)
        for x = 1:N(2)
            
            % check if mask has 1
            if mask3D(y,x,z)
                d = norm([y,x] - center);
                
                % make sure pixel is not outside of maximal radius
                if d < maxRadius
                    
                    % add value to all circles with radius bigger than d
                    integral(z,ceil(d):end) = integral(z,ceil(d):end) + 1;
                end
            end
        end
    end
end


radii = 0;