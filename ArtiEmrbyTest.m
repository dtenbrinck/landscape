clear all;
close all;

%% IMAGE PREPROCESSING

img = im2double(imread('Segmented_Embryo.tif'));
img = img(:,:,1);
img = 1-img;
img(img<1) = 0;
img(img>1) = 1;

%% FINDING THE HEAD

[centers, radii, metric] = imfindcircles(img,[60 100],'Sensitivity',0.98);
figure(1),imagesc(img);
viscircles(centers,radii)

% Maybe make a condition if there are more than one circles

if size(radii) == 1
    headpoint = round(centers);
else
    return;
end

%% EVALUATING LEVELSET

ERDimg = EikoRootDistFunctionNew2D(0.125,500,0.0001,1,headpoint,img);