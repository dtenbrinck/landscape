close all;
clear all;
%% IMAGE PREPROCESSING

img = im2double(imread('Segmented_Embryo.tif'));
img = img(:,:,1);
img = 1-img;
img(img<1) = 0;
img(img>1) = 1;

img2 = im2double(imread('Segmented_Embryo2.tif'));
img2 = img2(:,:,1);
img2 = 1-img2;
img2(img2<1) = 0;
img2(img2>1) = 1;

% landsum = sum(landmark,3);
% [Y,X] = find(landsum);
% figure(1), scatter(X,Y);
% X(isnan(X)) = 0;
% Y(isnan(Y)) = 0;

[startPoint, endPoint, a0, a1] = computeLinearRegression(img,'true');
[startPoint2, endPoint2, a02, a12] =computeLinearRegression(img2,'true');
p = startPoint:endPoint;
line = a1*p+a0;
indexi1 = sub2ind(size(img),round(line),p);
img(indexi1(:)) = 2;
p2 = startPoint2:endPoint2;
line2 = a12*p2+a02;
indexi2 = sub2ind(size(img2),round(line2),p2);
img2(indexi2(:)) = 2;
figure,imagesc(img);
figure,imagesc(img2);
%%
segmented3D = landmark;
irgendwas = zeros(size(segmented3D));
segmented3D(segmented3D>0) = 1;
segmented = sum(segmented3D,3);
segmented(segmented>0) = 1;
[startPoint, endPoint, a0, a1] = computeLinearRegression(segmented,'true');
p=startPoint:endPoint;line = a1*p+a0;
indexi = sub2ind(size(segmented),round(line),p);
line = zeros(size(segmented));
line(indexi(:)) = 1;

% THERE SHOULD BE CHECKED IF THE STARTPOINT IS ALSO ON THE LOWEST SLICE.
% REASON: WHEN THE EMBRYO GOES AROUND THE EGG THEN THE STARTPOINT IS SHIFTED BELOW THE BALL.
for i=1:size(segmented3D,3)
    irgendwas(:,:,end-i+1) = segmented3D(:,:,end-i+1).*line;
    figure(4),imagesc(segmented3D(:,:,end-i+1));
    figure(5),imagesc(irgendwas(:,:,end-i+1));
    pause();
    
end


startlinepoint = a0+a1*startPoint;
endlinepoint = a0+a1*endPoint;
for i=1:size(segmented3D,3)
%     irgendwas(:,:,i) = segmented3D(:,:,i).*line;
%     figure(4),imagesc(segmented3D(:,:,i));
%     figure(5),imagesc(irgendwas(:,:,i));
%     pause();
    
end

whatever=interp3(x, y, z, irgendwas, xs_t, ys_t, zs_t,'nearest');
%[x_sl,y_sl,z_sl] = computeSphericalLine(
figure(4), 
scatter3(x_s(:), y_s(:), z_s(:),10,[0 1 0]); hold on;
scatter3(x_s(GFPOnSphere == 1 & z_s <= 0), y_s(GFPOnSphere == 1 & z_s <= 0), z_s(GFPOnSphere == 1 & z_s <= 0),50,[1 0 0]);
scatter3(x_s(whatever == 1 & z_s <= 0), y_s(whatever == 1 & z_s <= 0), z_s(whatever == 1 & z_s <= 0),50,[1 0 0]); 
hold off;


%%
%Assume img is fix and im2 should be on it.
% 1. startPoint on StartPoint.
% 2. shorten or enxtend the endPoint and rotate it onto the other one. Or
% directly on the line. better way.
% 3. 

% 1. 
%%
diffBetweenStartPoints = startPoint2-startPoint;
diffBetweenIntercepts = a02 - a0;
a02 = a0;
startPoint2 = startPoint;

% ROTATION
% To rotate we will take notice that tan(alpha) = m so we compute tan^-1(m)
% of both functions
alpha1 = arctan(a1);
alpha2 = arctan(a2);

diffBetweenAlpha = alpha2 - alpha1;

% Rotate by diffBetweenAlpha!!!




% BLABLA
p2 = startPoint2:endPoint2;
line3 = a12*p2+a02;
indexi2 = sub2ind(size(img2),round(line3),p2);
img(indexi2(:)) = 2;
figure,imagesc(img)
