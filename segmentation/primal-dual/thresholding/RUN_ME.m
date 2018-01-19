% load standard image of cameraman
f = double(imread('cameraman.tif'));

% show input image
figure(1); imagesc(f); axis image; colormap gray; title('Input image');

% compute threshold according to Kapur algorithm
t_Kapur = kapur_thresholding(f); 
figure(2); imagesc(f >= t_Kapur); axis image; colormap gray;
title(['Kapur thresholding algorithm for t = ' int2str(t_Kapur)]);

% compute threshold according to Kittler algorithm
t_Kittler = kittler_thresholding(f); 
figure(3); imagesc(f >= t_Kittler); axis image; colormap gray;
title(['Kittler thresholding algorithm for t = ' int2str(t_Kittler)]);

% compute threshold according to Otsu algorithm
t_Otsu = otsu_thresholding(f); 
figure(4); imagesc(f >= t_Otsu); axis image; colormap gray;
title(['Otsu thresholding algorithm for t = ' int2str(t_Otsu)]);