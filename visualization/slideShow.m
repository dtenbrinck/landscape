function slideShow( data, varargin )

% set default values
segmentation = ones(size(data));

% check if a mask for plotting contours is given
if length(varargin) >= 1
  segmentation = varargin{1};
end

% check if a directory name for output is given
if length(varargin) >= 2
  output_dir = varargin{2};
end

% set time between slices
time = 0.5;

% determine number of slices in data
slices = size(data,3);

% determine minimum and maximum values of data
minData = min(data(:));
maxData = max(data(:));

  for i=1:slices
    figure(5);
    drawContours(data(:,:,i), segmentation(:,:,i), minData, maxData);
    pause(time);
    if exist('output_dir', 'var')
        print([output_dir 'output_' num2str(i,'%03d') '.png'],'-dpng')
    end
  end

end

function drawContours(u, Xi, minData, maxData)

imagesc(u,[minData maxData])

% set figure properties accordingly
set(gcf, 'Color', 'w'); set(gca, 'XTickLabel', ''); set(gca, 'YTickLabel', '');
axis image; colormap(jet);

% draw segmentation contours in red and green into image
hold on;
[contourMatrix, handle] = contour(Xi, [0.5,0.5], 'r');
set(handle, 'LineWidth', 2);
set(gca,'YDir','reverse');
[contourMatrix, handle] = contour(Xi, [1.5,1.5], 'g');
set(handle, 'LineWidth', 2);
set(gca,'YDir','reverse');
drawnow;
hold off;

end

