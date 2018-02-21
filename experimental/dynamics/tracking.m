function [ tracks, adjacency_tracks ] = tracking( centroid )
% tracks and plots tracks of centroids in mCherry

%% Adapt notation
n_frames = size(centroid,2);
for i_frame = 1 : n_frames
    points{i_frame} = permute(centroid{i_frame},[2,1]);
end

%% Track cells

max_linking_distance = 10;
max_gap_closing = Inf;
debug = true;

[ tracks, adjacency_tracks ] = simpletracker(points,...
    'MaxLinkingDistance', max_linking_distance, ...
    'MaxGapClosing', max_gap_closing, ...
    'Debug', debug);

%% Plot tracks

n_tracks = numel(tracks);
colors = hsv(n_tracks);

all_points = vertcat(points{:});

for i=1:size(centroid,2)-1
    figure(2);
    plot3(points{i}(:,1),points{i}(:,2),points{i}(:,3), 'r*')
    hold on
    for i_track = 1 : n_tracks

        % We use the adjacency tracks to retrieve the points coordinates. It
        % saves us a loop.

        track = adjacency_tracks{i_track};
        track_points = all_points(track, :);

        plot3(track_points(:,1), track_points(:, 2), track_points(:,3), 'Color', colors(i_track, :))

    end
    hold off
    pause(1);
end

end