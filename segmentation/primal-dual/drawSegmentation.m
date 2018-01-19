function drawSegmentation(u, Xi)
%DRAWSEGMENTATION Draws the segmentation contour into the image u
%
%  drawSegmentation(u0, Xi)
%
%   Copyright: Daniel Tenbrinck
%   Department of Mathematics and Computer Science
%   University of Muenster, Germany
%   email: daniel.tenbrinck@wwu.de
%   $Date: 2016/01/04 $

% show image
figure(1); imagesc(u)
%h = figure('Position', [0, 0, 1024, 1024]);

% set figure properties accordingly
set(gcf, 'Color', 'w'); set(gca, 'XTickLabel', ''); set(gca, 'YTickLabel', '');
axis image; colormap(gray);

% supress warnings for constant segmentations
if min(Xi(:)) == max(Xi(:))
  return;
end

% draw segmentation contour in red into image
hold on;
[contourMatrix, handle] = contour(Xi, [0.5,0.5], 'r');
set(handle, 'LineWidth', 2);
set(gca,'YDir','reverse');
drawnow;
hold off;