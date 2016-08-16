function [ output ] = LACSfun(data, resolution, scale)
%LACSfun: Short for Landmark And Cells Segmentation Function. This function
%segments the landmark in the GFP channel and the cells in the mCherry 
%channel.
%% Input:
%   data:   Data structure. It has the following fields:
%       .Dapi:      fluorescence of nuclei near the embryo membrane
%       .GFP:       fluorescence of anatomic structure denoted as 'landmark'
%       .mCherry:   fluorescence of labeled stem cells in embryo
%% Output:
% output:   Data structure. It has the following fields:
%       .landmark:  Segmented GFP data
%       .cells:     Segmented cells for the mCherry channel
%       .centCoords:centroid Coordinates of the cells
%       .ellipsoid: Data structure:
%           .center:    center of ellipsoid
%           .radii:     radii of the ellipsoid [x,y,z]
%           .axes:      rotation matrix of the ellipsoid.

%% Initialization:

% TODO: Preallocate containers for resized data!

% Rescale data for higher processing speed using trilinear interpolation
for i=1:size(data.Dapi,3)
  dapi_resized(:,:,i) = imresize(data.Dapi(:,:,i), scale);
  gfp_resized(:,:,i) = imresize(data.GFP(:,:,i), scale); % coarse data for segmentation sufficient
  mCherry_resized(:,:,i) = imresize(data.mCherry(:,:,i), scale);
end

% Normalize data
dapi_resized = normalizeData(dapi_resized);           % nuclei in embryo membrane
gfp_resized = normalizeData(gfp_resized);             % landmark
mCherry_resized = normalizeData(mCherry_resized);     % labeled cells

% Generate three-dimensional Gaussian filter
g = generate3dGaussian(9, 1.5);

% Denoise DAPI channel by blurring
blurred = imfilter(dapi_resized, g, 'same','replicate');

% Generate a three-dimensional Laplacian filter
kernelLaplace = generate3dLaplacian(resolution);

%% Main Code:

% Determine sharp areas in DAPI channel by Laplacian filtering
sharp_areas = normalizeData (imfilter(blurred, kernelLaplace, 'same', 'replicate'));

% Estimate embryo shape by fitting ellipsoid to sharp areas
[center radii axes v] = fitEllipsoid(sharp_areas, resolution);

% Segment landmark in GFP channel
landmark = segmentGFP(gfp_resized, resolution);

% Segment stem cells in mCherry channel and get the centroids of the cells
[cells,origCentCoords] = segmentCells( mCherry_resized, resolution );

% Get coordinates of the cells %
% Fit Coordinates to real resolution
centCoords = diag(resolution)*origCentCoords;

% Transform the coordinates into the sphere. With scaling and rotating.

centCoords(1,:) = centCoords(1,:)-center(1);
centCoords(2,:) = centCoords(2,:)-center(2);
centCoords(3,:) = centCoords(3,:)-center(3);
centCoords = diag([1/radii(1),1/radii(2),1/radii(3)])*axes'*centCoords;

%% Generate Output

output = struct;
output.landmark = landmark;
output.cells = cells;
output.origCentCoords = origCentCoords;
output.centCoords = centCoords;
output.ellipsoid.center = center;
output.ellipsoid.radii = radii;
output.ellipsoid.axes = axes;
%% Information for the data dimensions
% The image is always set in [row, column, z] dimensionsen. When we are
% working with axis [x,y,z] x = column, y = row and z = z. fitEllipsoid is
% working on the axis. So we get a center and a radii that depends on the
% axis and not on the image itself. So if we compute a sphere in the axis
% we can just use center and radii as it is. but if we want to visualize it
% in the image we need to permute the dimensions. So we can just work with
% the the output of fitEllipsoid on our sphere etc. But we need to be
% carefull when we use interp3 with landmark. landmark is the segmentation
% of the gfp channel. So it is in the same dimensions as the other images.
% We dont need to care about the resolution now because it is the same for
% x and y. 
% centCoords gives us the centroids of the cells in the image. It is
% computed with regionprops. This gives us the right centroids with the
% right order. So we can just use it for our axial representation.

end

