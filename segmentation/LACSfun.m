function [ output ] = LACSfun(data, samples, resolution, scale)
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
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Initialization
output = struct;

%% Segmentation:

% Estimate surface of embryo by fitting an ellipsoid
[center, radii, axes] = estimateEmbryoSurface(data.Dapi, resolution);

% Segment landmark in GFP channel
disp('Segmenting GFP...');
output.landmark = segmentGFP(data.GFP, resolution);

% Segment stem cells in mCherry channel and get the centroids of the cells
 disp('Segmenting mCherry...');
[output.cells,origCentCoords] = segmentCells(data.mCherry, resolution);

% Get orientation of embryo
headOrientation = determineHeadOrientation(computeMIP(output.landmark));

%% Projection

output = ProjectionOnSphere(output,samples,resolution);

%% Generate Output

output.origCentCoords = origCentCoords;
output.headOrientation = headOrientation;
output.ellipsoid.center = center;
output.ellipsoid.radii = radii;
output.ellipsoid.axes = axes;
%% Information for the data dimensions
% The image is always set in [row, column, z] dimensions. When we are
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

