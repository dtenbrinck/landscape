function modifiedData = gui_manualSegmentation( data )

modifiedData = data;

% TODO: check if exists!
im = computeMIP(data.processed.mCherry);
im2 = computeMIP(data.processed.cells);
h = figure; set(h,'Units','normalized','Position',[0.1 0.1 0.9 0.9]); imagesc(im,[0, max(im(:))/2]); colormap gray;
text(size(im,2) / 2, -30, 'Select center point of cell!', 'HorizontalAlignment','center', 'BackgroundColor',[.7 .9 .7]);

figure(h); drawSegmentation(im, im2);

[xCenter yCenter] = ginput(1);
text(size(im,2) / 2, -30, 'Select point outside of cell (~ double distance to membrane)!', 'HorizontalAlignment','center', 'BackgroundColor',[.7 .9 .7]);
[xOutside yOutside] = ginput(1);
%close(h);
pause(0.1);


%%% compute bounding box
distance = norm([xCenter yCenter] - [xOutside yOutside],2);
%distance = 30;
yMin = round(yCenter - distance);
yMax = round(yCenter + distance);
xMin = round(xCenter - distance);
xMax = round(xCenter + distance);

if yMin >= 0 && yMax < size(im,1) && xMin >= 0 && xMax < size(im,2)
  
  %%% extract roi
  roi = im(yMin:yMax, xMin:xMax);
  %load('roi_cell2.mat');
  
  options.numberAngles = 360;
  options.numberRadii = max(size(roi));
  
  profile on
  %%%%%%%%%% segment image
  segmentation = segmentCell(roi,options, fileNames{experiment});
  profile viewer
  profile off
  
  im2(yMin:yMax,xMin:xMax) = im2(yMin:yMax,xMin:xMax) | segmentation;
  
else
  disp('Error: ROI to small for specified points!');
end

figure(h); drawSegmentation(im, im2);
pause(0.1);

end

