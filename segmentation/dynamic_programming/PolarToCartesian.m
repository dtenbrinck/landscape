%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Copyright 2013    Daniel Tenbrinck, Xiaoyi Jiang                      %
%   Institute of Computer Science                                         %
%   University of Muenster, Germany                                       %
%   email: daniel.tenbrinck@uni-muenster.de, xjiang@uni-muenster.de       %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function imageCartesian = PolarToCartesian(imagePolar, height, width, method)

imageCartesian = zeros(height, width);

%%% compute image center
xc = round(size(imageCartesian,2) / 2);
yc = round(size(imageCartesian,1) / 2);

%%% generate meshgrid for interpolation
radius = linspace(0, round(max(height, width) / 2), size(imagePolar,1));
angles = linspace(-pi, pi, size(imagePolar,2));
[X Y] = meshgrid(angles, radius);

radius = zeros(size(imageCartesian));
angle = radius;
%%% sample the image
for i = 1:height
    for j = 1:width
        
        radius(i,j) = sqrt((i - yc)^2 + (j - xc)^2);
        
        if j - xc > 0
            angle(i,j) = atan( (i - yc) / (j - xc) );
        elseif j - xc < 0 && i - yc >= 0 
            angle(i,j) = atan( (i - yc) / (j - xc) ) + pi;
        elseif j - xc < 0 && i - yc < 0 
            angle(i,j) = atan( (i - yc) / (j - xc) ) - pi;
        elseif j - xc == 0 && i - yc > 0 
            angle(i,j) = pi / 2;
        elseif j - xc == 0 && i - yc < 0 
            angle(i,j) = - pi / 2;
        end
        
    end
end

% shift image for range of pi, since arctan has different domain
imagePolar = cat(2, imagePolar(:, round(size(imagePolar,2) / 2) + 1:end), imagePolar(:,1: round(size(imagePolar,2) / 2)));
%interpolate image
imageCartesian = interp2(X,Y,imagePolar, angle, radius, method);
imageCartesian(isnan(imageCartesian) == 1) = 0;
end