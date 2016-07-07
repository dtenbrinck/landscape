close all; clear all; clc

% load data
load('E:\Embryo_Registration\data\data\20um_130s\10um_300s_mCherry')
% load('D:\Biologen\embryo_registration\15um_180s_mCherry');
% load('D:\Biologen\embryo_registration\20um_130s_mCherry');

% Find centroids
cells=logical(segmentedCells);
centroid=zeros(50,2,size(cells,3));
M=size(cells,1);
N=size(cells,2);
d=2;
r=6;
[X,Y]=meshgrid(1:r:N,1:r:M);
for i=1:size(cells,3)
    props=regionprops(cells(:,:,i),'centroid');
    centroid(1:size(props,1),:,i) = cat(1, props.Centroid);
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

for i=1:size(cells,3)
    figure(2);
    imshow(segmentedCells(:,:,i))
    hold on
    plot(centroid(:,1,i),centroid(:,2,i), 'r*')
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