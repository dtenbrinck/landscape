%% Problem Parameter

% Dimensionality of the simulated problem (2 for 2D, 3 for 3D)
n_dim = 2;

% Number of frames to track the points over
n_frames = 20;

% Aproximative number of points per frame
n_points_per_frame = 10;

%% Create the random points

points = cell(n_frames, 1);

% Random start position
start = 20 * rand(n_points_per_frame, n_dim);

% Span initial direction
theta = linspace(0, 2* pi/4, n_points_per_frame)';
vec = [ cos(theta) sin(theta) ];

% Random direction change
theta_increase = pi / n_frames * rand(n_points_per_frame, 1);

for i_frame = 1 : n_frames

    % Disperse points as if their position was increasing by 1.5 in average
    % each frame.
    frame_points = start + vec .* i_frame .* [cos(theta_increase * i_frame) sin(theta_increase * i_frame) ] + rand(n_points_per_frame, n_dim) ;

    % Randomize them;
    randomizer = rand(n_points_per_frame, 1);
    [ sorted index ] = sort(randomizer);
    frame_points = frame_points(index, :);

    % Delete some of them, possible
    deleter = randn;
    while (deleter > 0);
        frame_points(1, :) = [];
        deleter = deleter - 1;
    end

    points{i_frame} = frame_points;

end

%% Plot the random points

figure(1)
clf
hold on
for i_frame = 1 : n_frames

    str = num2str(i_frame);
    for j_point = 1 : size(points{i_frame}, 1)
        pos = points{i_frame}(j_point, :);
        plot(pos(1), pos(2), 'x')
        text('Position', pos, 'String', str)
    end

end

%% Track them

max_linking_distance = 4;
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