%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Copyright 2013    Daniel Tenbrinck, Xiaoyi Jiang                      %
%   Institute of Computer Science                                         %
%   University of Muenster, Germany                                       %
%   email: daniel.tenbrinck@uni-muenster.de, xjiang@uni-muenster.de       %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function imagePolar = CartesianToPolar(imageCartesian, samplingAngles, samplingRadius,method)

imagePolar = zeros(samplingRadius, samplingAngles);

%%% compute image center
xc = round(size(imageCartesian,2) / 2);
yc = round(size(imageCartesian,1) / 2);

%%% compute maximal radius
rmax = floor(max(size(imageCartesian)) / 2) - 1;

%%% generate meshgrid for interpolation
[X Y] = meshgrid(1:size(imageCartesian,2), 1:size(imageCartesian,1));

angles = linspace(2*pi / samplingAngles, 2*pi, samplingAngles);
radii = linspace(0, rmax, samplingRadius);

x_coord = zeros(size(imagePolar));
y_coord = x_coord;

%%% sample the image
for i = 1:samplingRadius
    for j = 1:samplingAngles
        
        r = radii(i);
        theta = angles(j);
        y_coord(i,j) = r * sin(theta) + yc;
        x_coord(i,j) = r * cos(theta) + xc;
        
    end
end

%interpolate image
imagePolar = interp2(X,Y,imageCartesian, x_coord, y_coord, method);
end

