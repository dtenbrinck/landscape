function [center, radii, axes] = estimateEmbryoSurface( Dapi_data, resolution )

% Generate three-dimensional Gaussian filter
g = generate3dGaussian(9, 1.5);

% Denoise DAPI channel by blurring
%blurred = imfilter(Dapi_data, g, 'same','replicate');
blurred = Dapi_data;

% Generate a three-dimensional Laplacian filter
kernelLaplace = generate3dLaplacian(resolution);

% Determine sharp areas in DAPI channel by Laplacian filtering
sharp_areas = normalizeData (imfilter(blurred, kernelLaplace, 'same', 'replicate'));

% Estimate embryo shape by fitting ellipsoid to sharp areas
[center, radii, axes] = fitEllipsoid(sharp_areas, resolution);

end

