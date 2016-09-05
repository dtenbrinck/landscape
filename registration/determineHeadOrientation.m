function orientation = determineHeadOrientation( segmentation )

% generate histogram of column sums
columnHistogram = sum(segmentation,1);

% search for the part where the GFP landmark is segmented
% TODO: Add robustness against outliers
valid_part = find(columnHistogram > 0);
left = valid_part(1);
right = valid_part(end);

% compute center of the segmented GFP landmark 
center = (left + right) / 2;

% visualization for debugging
%figure; plot(columnHistogram(left:right));

% search for a peak in the column histogram -> indicating head
peak = find(columnHistogram == max(columnHistogram(:)));

% determine head orientation by checking where the peak is in relation to
% the center
if  peak(1) < center
  orientation = 'left';
else
  orientation = 'right';
end

end

