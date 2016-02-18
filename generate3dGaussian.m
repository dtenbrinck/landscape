function kernel = generate3dGaussian( width, sigma )
%GENERATE3DGAUSSIAN Summary of this function goes here
%   Detailed explanation goes here

kernel1D = fspecial('Gaussian', width, sigma);

kernel = imfilter(kernel1D, kernel1D', 'same');
kernel = imfilter(kernel, reshape(kernel1D,[1 1 numel(kernel1D)]));

end

