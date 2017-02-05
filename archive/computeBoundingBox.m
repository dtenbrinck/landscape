function bBox = computeBoundingBox( mask )
%COMPUTEBOUNDINGBOX Summary of this function goes here
%   Detailed explanation goes here

% set detection threshold
threshold = 0;

% initialize bounding box as image size (minY,maxY,,minX,maxX)
bBox = zeros(1,4);
bBox(1) = 1;
bBox(2) = size(mask,1);
bBox(3) = 1;
bBox(4) = size(mask,2);

% search for top border
for y=1:bBox(2)
   if sum(mask(y,:)) > threshold
       bBox(1) = y;
       break;
   end
end

% search for bottom border
for y=bBox(2):-1:bBox(1)
   if sum(mask(y,:)) > threshold
       bBox(2) = y;
       break;
   end
end

% search for left border
for x=1:bBox(4)
   if sum(mask(:,x)) > threshold
       bBox(3) = x;
       break;
   end
end

% search for left border
for x=bBox(4):-1:bBox(3)
   if sum(mask(:,x)) > threshold
       bBox(4) = x;
       break;
   end
end

end

