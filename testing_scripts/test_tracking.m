close all; clear; clc

% add all subdirs to path
addpath(genpath('../'));

% load tiff data
data = loadDynamicData('../data/dynamic/horst.tif');

% get number of timesteps
nb_timesteps = size(data,4);

% set scale factor for speed up
scale = 0.75;

% compute resolution of data 
resolution = [1.29/scale, 1.29/scale, 20];

% create a structuring element for morphology
% TODO: test best size for dynamic data
struct_element_mCherry = strel('disk',17);

% initialize container for preprocessed data
data_filtered = zeros(...
                round(size(data,1)*scale),...
                round(size(data,2)*scale),...
                size(data,3));
                

% process each time step separately
for t = 1:nb_timesteps
  
  % resize data
  for slice = 1:size(data,3)
    data_filtered(:,:,slice,t) = imresize(data(:,:,slice,t), scale);
  end
  
  % perform background subtraction
  data_filtered(:,:,:,t) = imtophat(data_filtered(:,:,:,t), struct_element_mCherry);
  
  % normalize data between 0 and 255
  data_filtered(:,:,:,t) = normalizeData(data_filtered(:,:,:,t));
  
  % compute maximum intensity projection
  MIP = computeMIP(data_filtered(:,:,:,t));
  
  % visualize maximum intensity projection
  figure(1); imagesc(MIP); pause(0.1);
  
  % segment cells 
  segmentedCells(:,:,t) = segmentCells2D(MIP, resolution);
  
  % save result
  %imwrite(max(normalizeData(segmentedCells(:,:,t)),[],3), gray(256), ['./cells_processed_' num2str(t) '.png'],'png');
end

% visualize segmentations over time
%figure;
%for t=1:size(data,4)
%  imagesc(segmentedCells(:,:,t)); pause(0.15);
%end

% Find centroids
cells=logical(segmentedCells);
centroid=zeros(50,2,size(cells,3));
M=size(cells,1);
N=size(cells,2);
d=2;
r=6;
[X,Y]=meshgrid(1:r:N,1:r:M);
for t=1:size(cells,3)
  props=regionprops(cells(:,:,t),'centroid');
  centroid(1:size(props,1),:,t) = cat(1, props.Centroid);
end

% Adapt notaion
n_frames = size(cells,3);
for i_frame = 1 : n_frames
  points{i_frame} = centroid(:,:,i_frame);
end

%% Plot the centroids

figure(1)
clf
% imshow(segmentedCells(:,:,1))
hold on
for i_frame = 1 : n_frames
  
  str = num2str(i_frame);
  for j_point = 1 : size(points{i_frame}, 1)
    pos = points{i_frame}(j_point, :);
    plot(pos(1), pos(2), 'x', 'Color', 'r')
    text('Position', pos, 'String', str)
  end
  
end

%% Track them

max_linking_distance = 10;
max_gap_closing = Inf;
debug = true;

[ tracks adjacency_tracks ] = simpletracker(points,...
  'MaxLinkingDistance', max_linking_distance, ...
  'MaxGapClosing', max_gap_closing, ...
  'Debug', debug);

%% Plot tracks

n_tracks = numel(tracks);
colors = hsv(n_tracks);

all_points = vertcat(points{:});

for i_track = 1 : n_tracks
  
  % We use the adjacency tracks to retrieve the points coordinates. It
  % saves us a loop.
  
  track = adjacency_tracks{i_track};
  track_points = all_points(track, :);
  
  plot(track_points(:,1), track_points(:, 2), 'Color', colors(i_track, :))
  
end


for t=1:size(cells,3)
  figure(2);
  imshow(segmentedCells(:,:,t)); colormap gray;
  
  
  
  hold on
  plot(centroid(:,1,t),centroid(:,2,t), 'r*')
  for i_track = 1 : n_tracks
    
    % We use the adjacency tracks to retrieve the points coordinates. It
    % saves us a loop.
    
    track = adjacency_tracks{i_track};
    track_points = all_points(track, :);
    
    plot(track_points(:,1), track_points(:, 2), 'Color', colors(i_track, :))
    
  end
  hold off
  pause;
end