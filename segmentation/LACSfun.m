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

%% Preprocessing:

% Perform background removal using morphological filters
data = removeBackground(data);

% Resize data
resized_data = rescaleSlices(data, scale);

% Normalize data
resized_data = normalizeData(resized_data);


%% Segmentation:

% Estimate surface of embryo by fitting an ellipsoid
[center, radii, axes] = estimateEmbryoSurface(resized_data.Dapi, round(resolution/scale));

% Segment landmark in GFP channel
disp('Segmenting GFP...');
landmark = segmentGFP(resized_data.GFP, round(resolution/scale));

 % Segment stem cells in mCherry channel and get the centroids of the cells
 disp('Segmenting mCherry...');
[cells,origCentCoords] = segmentCells(resized_data.mCherry, round(resolution/scale) );

% get orientation of embryo
headOrientation = determineHeadOrientation(computeMIP(landmark));

% Get coordinates of the cells %
% Fit Coordinates to real resolution
centCoords = diag(round(resolution/scale))*origCentCoords;

% Transform the coordinates into the sphere. With scaling and rotating.

centCoords(1,:) = centCoords(1,:)-center(1);
centCoords(2,:) = centCoords(2,:)-center(2);
centCoords(3,:) = centCoords(3,:)-center(3);
centCoords = diag([1/radii(1),1/radii(2),1/radii(3)])*axes'*centCoords;

% Only take the centers that are really inside the ball with a toleranz
tol = 0.1;
normCoords = sqrt(centCoords(1,:).^2+centCoords(2,:).^2+centCoords(3,:).^2);


% Delete each point that is > 1+tol
centCoords(:,normCoords>1+tol) = [];

% Normalize each point that is > 1 but <= 1+tol
centCoords(:,normCoords>1&normCoords<1+tol) = ...
centCoords(:,(normCoords>1&normCoords<1+tol))...
    .*1./repmat(normCoords(:,(normCoords>1&normCoords<1+tol)),[3,1]);


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

