function modifiedData = gui_manualSegmentation( data, p )

modifiedData = data;


% TODO: check if exists!
mip = computeMIP(single(data.processed.mCherry));

segmentation = data.processed.cellsMIP;

minData = min(mip(:));
maxData = max(mip(:));

figHandle = figure;
set(figHandle,'Units','normalized','Position',[0.1 0.1 0.9 0.9]);

% add a button for being finished
finish_button = uicontrol('Style', 'pushbutton', 'String', 'Finish',...
  'Position', [550 20 50 20],...
  'Callback', {@close_segmentation_GUI,figHandle});

threshold_slider = uicontrol('Style', 'slider',...
  'Min',round(minData + 1),...
  'Max',round(maxData - 1),...
  'Value',round((minData + maxData) / 6),...
  'SliderStep', [1/(maxData-minData), 10/(maxData-minData)],...
  'Position', [300 20 150 20],...
  'Callback', {@threshold_image,mip,figHandle});

threshold_editField=uicontrol('Style','edit',...
          'Position', [470 20 40 20],...
          'String',num2str(get(threshold_slider,'Value')));
        
%while finished == false
imageHandle = imagesc(mip,[0, max(mip(:))/2]); colormap gray; axis image;

hold on
[~,contour_handle] = contour(segmentation, [0.5 0.5], 'r');
set(contour_handle, 'LineWidth', 2);
%set(gca,'YDir','reverse');
hold off;


set(figHandle,'KeyPressFcn',@(a,b) capture_keystroke(figHandle,contour_handle,b));
addlistener(threshold_slider,'Value','PreSet',@(a,b) update_segmentation(b,contour_handle,mip));
addlistener(threshold_slider,'Value','PreSet',@(a,b) update_editField(b,threshold_editField));

%figure(h);
%ih = drawSegmentation(im, im2);
text(size(mip,2) / 2, -30, 'Select center point of cell!', 'HorizontalAlignment','center', 'BackgroundColor',[.7 .9 .7]);
axesHandle  = get(imageHandle,'Parent');
set(get(axesHandle,'children'),'HitTest','off')
set(axesHandle,'ButtonDownFcn',{@start_manual_segmentation,axesHandle,mip,contour_handle})

setappdata(figHandle,'segmentation',segmentation);

contrast_slider = uicontrol('Style', 'slider',...
  'Min',1,...
  'Max',5,...
  'Value',4,...
  'SliderStep', [0.25, 0.25],...
  'Position', [700 20 200 20],...
  'Callback', {@adjust_contrast,axesHandle,imageHandle});

uiwait(figHandle);

% TODO: Needed?
% added_segmentation = getappdata(figHandle,'new_segmentation');
% segmentation = getappdata(figHandle,'segmentation');
% 
% if ~isempty(segmentation)
%   
%   if ~isempty(added_segmentation)
%     segmentation = segmentation | added_segmentation;
%   end
%   modifiedData.processed.cellsMIP = segmentation;
%   
% else
%   
%   modifiedData.processed.cellsMIP = segmentation;
%   
% end

if ~ishandle(figHandle)
  modifiedData = [];
  return;
end

box_handle = msgbox('New cells are being registered. Please wait a few seconds!','Please wait!');

segmentation = getappdata(figHandle,'segmentation');
modifiedData.processed.cellsMIP = segmentation;

full_segmentation = repmat(modifiedData.processed.cellsMIP,...
                          [1 1 size(modifiedData.processed.mCherry,3)]);

cc = bwconncomp(full_segmentation);

cells = zeros(size(full_segmentation));

% remove too small items
% Centroid for all cells
j = 1;
for i = 1:cc.NumObjects
    pixelList = cc.PixelIdxList{i};
    if length(pixelList) > 50
        cellObjects{j} = pixelList;
        j = j+1;
    end
end

for j=1:length(cellObjects)
    currentCell = zeros(size(modifiedData.processed.mCherry));
    currentCell(cellObjects{j}) = 1;
    currentCell = currentCell .* single(modifiedData.processed.mCherry);
    
    maxSlice = 2;
    maxValue = -1;
    for slice = 2:size(modifiedData.processed.mCherry,3)-1
        if max(max(currentCell(:,:,slice))) > maxValue
            maxSlice = slice;
            maxValue = max(max(currentCell(:,:,slice)));
        end
    end
    
    sliceMask = zeros(size(modifiedData.processed.mCherry));
    sliceMask(:,:,maxSlice) = 1;
    
    currentCell = currentCell .* sliceMask;
    cells(currentCell > 0) = 1;
end


% Centroids of the cells

cc = bwconncomp(cells);
S = regionprops(cc,'centroid');
centCoords = round(reshape([S.Centroid],[3,numel([S.Centroid])/3]));

modifiedData.processed.cells = cells;
modifiedData.processed.cellCoordinates = centCoords;

registeredData = registerData( modifiedData.processed, p.resolution, modifiedData.registered.transformation_full, modifiedData.processed.ellipsoid, p.samples_cube);
          
modifiedData.registered.cellCoordinates = registeredData.cellCoordinates;
modifiedData.registered.cells = registeredData.cells;
modifiedData.registered.landmark = registeredData.landmark;
modifiedData.registered.Dapi = registeredData.Dapi;
modifiedData.registered.GFP = registeredData.GFP;
modifiedData.registered.mCherry = registeredData.mCherry;

close(box_handle);
close(figHandle);

end

function start_manual_segmentation(~,~,axesHandle,mip,contour_handle)
%disp('button_down');

fig = ancestor(axesHandle,'figure');

new_segmentation = getappdata(fig,'new_segmentation');
segmentation = getappdata(fig,'segmentation');

if ~isempty(new_segmentation)
  segmentation = segmentation | new_segmentation;
  setappdata(fig,'segmentation',segmentation);
  setappdata(fig,'new_segmentation',[]);
end

coordinates = get(axesHandle,'CurrentPoint');
center_point = coordinates(1,1:2);
%disp(['x = ' num2str(coordinates(1)) ' and y = ' num2str(coordinates(2))]);

hold on
dot_handle = plot(axesHandle,center_point(1),center_point(2),'g.','MarkerSize',12);
hold off

setappdata(fig,'Dot',dot_handle);

% Create position of circle.
pos = [center_point-1 2 2];

% Create circle via rect command.
circle_handle = rectangle('Position',pos,'Curvature',[1 1], 'EdgeColor', 'g', 'LineWidth', 2);


% get the values and store them in the figure's appdata
props.WindowButtonMotionFcn = get(fig,'WindowButtonMotionFcn');
props.WindowButtonUpFcn = get(fig,'WindowButtonUpFcn');

setappdata(fig,'TestGuiCallbacks',props);
%setappdata(fig,'Dot',handle_dot);

%set(fig,'WindowButtonMotionFcn',{@mouse_moving, x_start, y_start})

% Add a callback to the figure to update the position when the circle moves
set(fig, 'WindowButtonMotionFcn', @(a,b) scale_circle(axesHandle, circle_handle, center_point))
set(fig,'WindowButtonUpFcn',@(a,b) dp_segmentation(axesHandle,mip,circle_handle,center_point,contour_handle))

end

function scale_circle (axesHandle, circle_handle, center_point )
cp = get ( axesHandle, 'CurrentPoint' );
cp = [cp(1,1), cp(1,2)];
%set(h,'Position',[cp(1,1) cp(1,2) d d]);
set(circle_handle,'Position',[center_point - norm(center_point-cp) norm(center_point-cp)*2 norm(center_point-cp)*2]);
end

% function mouse_moving(figHandle,eventData, x_start, y_start)
%
% set(figHandle,'WindowButtonMotionFcn',[]);
%
% axesHandle  = get(figHandle,'CurrentAxes');
% coordinates = get(axesHandle,'CurrentPoint');
% coordinates = coordinates(1,1:2);
% %disp(['motion: x = ' num2str(coordinates(1)) ' and y = ' num2str(coordinates(2))]);
% x_current = coordinates(1); y_current = coordinates(2);
%
% radius = norm([x_start, y_start] - [x_current, y_current]);
%
%
%
% set(figHandle,'WindowButtonMotionFcn',{@mouse_moving, x_start, y_start});
%
% end

function dp_segmentation(axesHandle,data,circle_handle,center_point,contour_handle)

coordinates = get(axesHandle,'CurrentPoint');
currentPoint = coordinates(1,1:2);

radius = norm(center_point - currentPoint);

fig = ancestor(axesHandle,'figure');

segmentation = getappdata(fig,'segmentation');

props = getappdata(fig,'TestGuiCallbacks');
set(fig,props);
setappdata(fig,'TestGuiCallbacks',[]);

handle_dot = getappdata(fig,'Dot');
delete(handle_dot);
setappdata(fig,'Dot',handle_dot);

delete(circle_handle)

xCenter = center_point(1); yCenter = center_point(2);

%%% compute bounding box
yMin = round(yCenter - radius);
yMax = round(yCenter + radius);
xMin = round(xCenter - radius);
xMax = round(xCenter + radius);

new_segmentation = zeros(size(data));

if yMin >= 0 && yMax < size(data,1) && xMin >= 0 && xMax < size(data,2)
  
  %%% extract roi
  roi = data(yMin:yMax, xMin:xMax);
  
  options.show_segmentation_result = false;
  options.numberAngles = 180;
  options.numberRadii = max(size(roi));
  
  %%% segmentation parameters
  options.method = 'Chan-Vese-L1'; % Chan-Vese-L1 % Chan-Vese-L2 % Sobel % Chan-Vese-L1+Sobel % Malon % Chan-Vese-L1-inc % Chan-Vese-L2-inc
  options.lambda = 2;
  
  %profile on
  %%%%%%%%%% segment image
  segmented_roi = segmentCell(roi,options);
  new_segmentation(yMin:yMax,xMin:xMax) = new_segmentation(yMin:yMax,xMin:xMax) | segmented_roi;
  setappdata(fig,'new_segmentation',new_segmentation);
  %profile viewer
  %profile off

  set(contour_handle, 'ZData', segmentation | new_segmentation);
  set(contour_handle, 'LevelList', 0.5);
  
  %ih = drawSegmentation(data,segmentation | new_segmentation);
  %axesHandle  = get(ih,'Parent');
  %set(get(axesHandle,'children'),'HitTest','off')
  %set(axesHandle,'ButtonDownFcn',@(a,b)button_down(axesHandle,im))
  
  
else
  disp('Error: ROI to small for specified points!');
end


end

function close_segmentation_GUI(~,~,fig_handle)

new_segmentation = getappdata(fig_handle,'new_segmentation');

if ~isempty(new_segmentation)
  segmentation = getappdata(fig_handle,'segmentation');
  setappdata(fig_handle, 'segmentation', segmentation | new_segmentation);
  setappdata(fig_handle, 'new_segmentation', []);
end

uiresume(fig_handle);

end


function update_segmentation(event,contour_handle,mip)

threshold_value = round(get(event,'NewValue'));
set(contour_handle,'ZData',mip >= threshold_value);

end

function update_editField(event,editField_handle)

slider_value = round(get(event,'NewValue'));
set(editField_handle,'String',num2str(slider_value));

end


function threshold_image(src,~,mip,figHandle)

threshold_value = get(src,'Value');
setappdata(figHandle, 'segmentation', mip >= threshold_value);

end

function adjust_contrast(src,~,axesHandle,imageHandle)

val=round(get(src,'Value'));
set(src,'Value',val);

maxValue = max(max(get(imageHandle,'CData')));
contrast_value = get(src,'Value');

switch contrast_value
  case 1
    factor = 1/3;
  case 2
    factor = 1/2;
  case 3
    factor = 1;
  case 4
    factor = 2;
  case 5
    factor = 4;
  otherwise
    factor = 1;
end

set(axesHandle, 'CLim', [0 maxValue/factor]);

end

function capture_keystroke(figHandle, contour_handle, event)

if strcmp(event.Key,'delete') || strcmp(event.Key,'backspace')
  segmentation = getappdata(figHandle, 'segmentation');
  set(contour_handle, 'ZData', segmentation);
  setappdata(figHandle, 'new_segmentation', []);
end

end

