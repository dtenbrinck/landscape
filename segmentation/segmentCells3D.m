function segmentation = segmentCells3D(data)

% normalize data
data = normalizeData(data);

% get histogram
[h, bins] = imhist(data(:));

% get integral over histogram
p = cumsum(h);

% normalize integral
p = p / p(end);

% get only brightest signals
threshold = 0.99; % WARNING: THIS IS HEURISTIC!

% get relevant indices
indices = find(p > threshold);

% take first index
index = indices(1);

t = bins(index);

segmentation = data >= t;
end