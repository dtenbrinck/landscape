function convAcc = convolveAccumulator(accumulator,radius,sizeGrid)
% This function computes the convolution of the accumulator and a sphere
% with a radius

%% MAIN CODE
if radius>0
    [xx,yy,zz] = meshgrid(1:sizeGrid,1:sizeGrid,1:sizeGrid);
    NHMat = ... % neighbourhood matrix / matrix for convolution kernel
        (sqrt((xx-radius-1).^2+(yy-radius-1).^2+(zz-radius-1).^2))<=radius;
    convAcc = convn(accumulator,NHMat,'same');
elseif radius == 0
    convAcc = accumulator;
elseif radius < 0
    convAcc = accumulator;
    warning('Radius is negative. Will be handled as 0');
end
end
