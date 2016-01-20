function CoM = computeCoM( mask )
%COMPUTECOM Summary of this function goes here
%   Detailed explanation goes here

% initialize center of mass as zero vector
CoM = zeros(1,2);

% initialize counter of contributing pixels
counter = 0;

% add up all coordinates of 1s in mask
for y = 1:size(mask,1)
    for x = 1:size(mask,2)
        if mask(y,x) == 1
            CoM = CoM + [y,x];
            counter = counter + 1;
        end
    end
end

% normalize coordinates
CoM = CoM / counter;

end

