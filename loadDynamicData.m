clear; close all;
tifData = tiffread('horst2.tif');

for frame=1:22
        images(:,:,frame) = tifData(frame*24 -12).data;
end

figure(1);
while true
for i = 1:22
    imagesc(images(:,:,i));
    pause(0.2);
end
end
