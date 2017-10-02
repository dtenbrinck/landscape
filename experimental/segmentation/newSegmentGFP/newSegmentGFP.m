function closedLandmark = newSegmentGFP( data, GFPseg_parameter, resolution )
% GFP segmentation

epsilon = 1;
a = computeMIP(data);
binaryImage = zeros(size(data));

for i = 1 : size(data,1)
    for j = 1 : size(data,2)
        for k = 1 : size(data,3)
            if data(i,j,k) >= (a(i,j) - epsilon)
                binaryImage(i,j,k) = 1;
            end
        end
    end
end

landmark = segmentGFP( data, GFPseg_parameter, resolution );

newLandmark = binaryImage .* landmark;

% Do a "hole fill" to get rid of any background pixels or "holes" inside the blobs.
SE = strel('disk',5);
closedLandmark = imclose(newLandmark,SE);

end