function varargout = Embryo_Heatmap(varargin)
% EMBRYO_HEATMAP MATLAB code for Embryo_Heatmap.fig
%      EMBRYO_HEATMAP, by itself, creates a new EMBRYO_HEATMAP or raises the existing
%      singleton*.
%
%      H = EMBRYO_HEATMAP returns the handle to a new EMBRYO_HEATMAP or the handle to
%      the existing singleton*.
%
%      EMBRYO_HEATMAP('CALLBACK',hObject,eventData,h,...) calls the local
%      function named CALLBACK in EMBRYO_HEATMAP.M with the given input arguments.
%
%      EMBRYO_HEATMAP('Property','Value',...) creates a new EMBRYO_HEATMAP or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Embryo_Heatmap_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Embryo_Heatmap_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help Embryo_Heatmap

% Last Modified by GUIDE v2.5 07-Jul-2016 12:04:46

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Embryo_Heatmap_OpeningFcn, ...
                   'gui_OutputFcn',  @Embryo_Heatmap_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before Embryo_Heatmap is made visible.
function Embryo_Heatmap_OpeningFcn(hObject, eventdata, h, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% h    structure with h and user data (see GUIDATA)
% varargin   command line arguments to Embryo_Heatmap (see VARARGIN)

% Choose default command line output for Embryo_Heatmap
h.output = hObject;

% Load h from the main GUI
h.MGH = varargin{1,1};

% Initialize the data for the heatmaps %

% Set defaults

h.typeNH = 'gaussian';
h.sizeNH = 3;
h.numOfLayers = 4;
h.layerType = 'linear';
h.pmSelection = 1;
% Get all cell coordinates
fieldNames = fieldnames(h.MGH.SegData);
allCentCoords = [];
for i = 1:size(fieldNames,1)
   allCentCoords = horzcat(allCentCoords,h.MGH.SegData.(char(fieldNames(i))).centCoords);
end
h.allCentCoords = allCentCoords;
h.numOfCells = size(allCentCoords,2);
h.sizeLandmark = size(h.MGH.SegData.(fieldNames{1}).landmark);

% Compute the standard density matrix
h = updateSampAndDens(h);

% Update uicontrols

% Invisible subplots
h.subax1 = axes('Visible','off');
h.subax2 = axes('Visible','off');
h.subax3 = axes('Visible','off'); 

drawProMap(h);
set(h.tabPro,'FontWeight','bold');
set(h.tab3D,'FontWeight','normal');
set(h.tabBars,'FontWeight','normal');

set(h.edSamples,'String',num2str(h.MGH.samples));
set(h.edSamples,'Value',h.MGH.samples);
set(h.slCloudLayer,...
    'Min',1,...
    'Max',5,...
    'Value',4,...
    'SliderStep', [1 ,1]/(5-1));

set(h.slSlices,...
    'Min',1,...
    'Max',h.samples,...
    'Value',1,...
    'SliderStep', [1 ,1]/(h.samples-1));

set(h.slAutoSpeed,...
    'Min',1,...
    'Max',10,...
    'Value',1,...
    'SliderStep', [1 ,1]/(10-1));

set(h.edSizeNH,'Value',h.sizeNH);
set(h.edSizeNH,'String',num2str(h.sizeNH));
h.currentTab = 'Pro';

initTab(hObject,h.proMat);

% ARRANGE THE UI CONTROLERS

% - Projected - %

set(h.paVis_Pro,'Parent',h.paControls,...
    'Units','normalized',...
    'Position',get(h.paVisPH,'Position'));
set(h.tbPoints_Pro,'Parent',h.paVis_Pro,...
    'Units','normalized',...
    'FontUnits','normalized',...
    'Position',get(h.tbVisBot,'Position'));
set(h.paControl_Pro,'Parent',h.paControls,...
    'Units','normalized',...
    'Position',get(h.paControlPH,'Position'));
set(h.tbZoom_Pro,'Parent',h.paControl_Pro,...
    'Units','normalized',...
    'Position',get(h.tbControlBot,'Position'));
set(h.tbValue_Pro,'Parent',h.paControl_Pro,...
    'Units','normalized',...
    'Position',get(h.tbControlTop,'Position'));
set(h.cbLabelAxis,'Parent',h.paVis_Pro,...
    'Units','normalized',...
    'FontUnits','normalized',...
    'Position',get(h.cbLAPH,'Position'));

% - Slice by Slice - %

set(h.paVis_Slice,'Parent',h.paControls,...
    'Units','normalized',...
    'Position',get(h.paVisPH,'Position'));
set(h.tbAnime,'Parent',h.paVis_Slice,...
    'Units','normalized',...
    'FontUnits','normalized',...
    'Position',get(h.tbVisBot,'Position'));
set(h.slSlices,'Parent',h.paVis_Slice,...
    'Units','normalized',...
    'FontUnits','normalized',...
    'Position',get(h.slTop,'Position'));
set(h.slAutoSpeed,'Parent',h.paVis_Slice,...
    'Units','normalized',...
    'FontUnits','normalized',...
    'Position',get(h.slBot,'Position'));
set(h.cbLabelAxis_Slice,'Parent',h.paVis_Slice,...
    'Units','normalized',...
    'FontUnits','normalized',...
    'Position',get(h.cbLAPH,'Position'));

set(h.paControls_Slice,'Parent',h.paControls,...
    'Units','normalized',...
    'Position',get(h.paControlPH,'Position'));
set(h.tbZoom,'Parent',h.paControls_Slice,...
    'Units','normalized',...
    'Position',get(h.tbControlBot,'Position'));
set(h.tbValue_Slice,'Parent',h.paControls_Slice,...
    'Units','normalized',...
    'Position',get(h.tbControlTop,'Position'));

% - 3D - %

set(h.paVis_3D,'Parent',h.paControls,...
    'Units','normalized',...
    'Position',get(h.paVisPH,'Position'));
set(h.tbCloud,'Parent',h.paVis_3D,...
    'Units','normalized',...
    'FontUnits','normalized',...
    'Position',get(h.tbVisTop,'Position'));
set(h.tbPoints,'Parent',h.paVis_3D,...
    'Units','normalized',...
    'FontUnits','normalized',...
    'Position',get(h.tbVisBot,'Position'));
set(h.slCloudLayer,'Parent',h.paVis_3D,...
    'Units','normalized',...
    'FontUnits','normalized',...
    'Position',get(h.slTop,'Position'));
set(h.cbCloudSmooth,'Parent',h.paVis_3D,...
    'Units','normalized',...
    'FontUnits','normalized',...
    'Position',get(h.cbPH,'Position'));
set(h.cbLabelAxis_3D,'Parent',h.paVis_3D,...
    'Units','normalized',...
    'FontUnits','normalized',...
    'Position',get(h.cbLAPH,'Position'));

set(h.paControls_3D,'Parent',h.paControls,...
    'Units','normalized',...
    'Position',get(h.paControlPH,'Position'));
set(h.btnRotate_3D,'Parent',h.paControls_3D,...
    'Units','normalized',...
    'Position',get(h.tbControlTop,'Position'));
set(h.btnZoom_3D,'Parent',h.paControls_3D,...
    'Units','normalized',...
    'Position',get(h.tbControlBot,'Position'));


% - Bars - %

set(h.paVis_Bars,'Parent',h.paControls,...
    'Units','normalized',...
    'Position',get(h.paVisPH,'Position'));
set(h.tb2D_Bars,'Parent',h.paVis_Bars,...
    'Units','normalized',...
    'FontUnits','normalized',...
    'Position',get(h.tbVisTop,'Position'));
set(h.tb3D_Bars,'Parent',h.paVis_Bars,...
    'Units','normalized',...
    'FontUnits','normalized',...
    'Position',get(h.tbVisBot,'Position'));
set(h.tb2DOnePlot,'Parent',h.paVis_Bars,...
    'Units','normalized',...
    'FontUnits','normalized',...
    'Position',get(h.tbPH,'Position'));
set(h.pm2DDim,'Parent',h.paVis_Bars,...
    'Units','normalized',...
    'FontUnits','normalized',...
    'Position',get(h.pmPH,'Position'));
set(h.cbLabelAxis_Bars,'Parent',h.paVis_Bars,...
    'Units','normalized',...
    'FontUnits','normalized',...
    'Position',get(h.cbLAPH,'Position'));

set(h.paControls_Bars,'Parent',h.paControls,...
    'Units','normalized',...
    'Position',get(h.paControlPH,'Position'));
set(h.tbRot_Bars,'Parent',h.paControls_Bars,...
    'Units','normalized',...
    'Position',get(h.tbControlTop,'Position'));

% Update h structure
guidata(hObject, h);

% UIWAIT makes Embryo_Heatmap wait for user response (see UIRESUME)
% uiwait(h.figEmbrHeat);

%% OTHER FUNCTIONS 

function d = showProcessing(h)
% Positioning it into the middle of the figure
posFig = get(h.figEmbrHeat,'Position');

posDiag = [posFig(1)+posFig(3)/2-20, posFig(2)+posFig(4)/2-3, 40, 10];
d = dialog('Units','characters','Position',round(posDiag),'Name','Wait');
uicontrol('Parent',d,...
    'Units','normalized',...
    'Style','text',...
    'Position',[0 0 01 0.6],...
    'String','Updating the density map...');
drawnow  

function h = updateSampAndDens(h,sampleType,typeNH,sizeNH,samples)
% Input:
%   sampleType:     Type of the sampling: 'datasize', 'samples'
%                       'datasize': Sampling on size(landmark) grid
%                       'samples':  Sampling on input variable samples
%   typeNH:         Type of the neighbourhood: 'sphere','cube','gaussian'
%                       'sphere':   spherical neighbourhood of diameter sizeNH
%                       'cube':     cubic neighbourhood of size sizeNH
%                       'gaussian': 3d gaussian filter
%   sizeNH:         Size of the neighbourhood for the density. Default: 3
%   samples:        Only used when sampleType is 'samples'. Default:
%                                                       Sampling of sphere
% % % % % % % % % % % % % % % % % % % % % % % %

dialogBox = showProcessing(h);           

if nargin < 2
    sampleType = 'samples';
end 
if nargin < 3
    typeNH = 'gaussian';
end
if nargin < 4
    sizeNH = 3;
end
if nargin < 5
    samples = h.MGH.samples;
end
if strcmp(sampleType,'datasize')
    [h.samCoordsG,h.samCoordsU] ...
        = fitOnSamSphere(h.allCentCoords,h.sizeLandmark);
    h.densMat ...
        = compDens3D(h.sizeLandmark,h.samCoordsG,sizeNH,typeNH);
elseif strcmp(sampleType,'samples')
    [h.samCoordsG,h.samCoordsU] ...
        = fitOnSamSphere(h.allCentCoords,samples);
    h.densMat ...
        = compDens3D(samples,h.samCoordsG,sizeNH,typeNH);
end

% Update h
h.sampleType = sampleType;
h.typeNH = typeNH;
h.sizeNH = sizeNH;
h.samples = samples;

% Compute projected matrix
h.proMat = sum(h.densMat,3);

close(dialogBox);
set(h.txInfo,'String',{'Processing Done!', 'Waiting for new commands.'});


% % --- TAB FUNCTIONS --- % %
% --- General Tab function --- %

function labelAxis(h,datasize,color)
if nargin<2
    color = 'magenta';
end
cT = h.currentTab;
if strcmp(cT,'Pro')||strcmp(cT,'Slice')
    text(2, datasize(2)/2,max(h.proMat(:))*2/3,'Tail','FontSize',12,'Color',color,'Rotation',90);
    text(datasize(1), datasize(2)/2,max(h.proMat(:))*2/3,'Head','FontSize',12,'Color',color,'Rotation',90);
    text(datasize(1)/2,2,max(h.proMat(:))*2/3,'Rightside','FontSize',12,'Color',color);
    text(datasize(1)/2,datasize(2),max(h.proMat(:))*2/3,'Leftside','FontSize',12,'Color',color);
elseif strcmp(cT,'3D')||strcmp(cT,'Bars')
    text(0, datasize(2)/2,max(h.proMat(:))*2/3,'Rightside','FontSize',12,'Color',color);
    text(datasize(1), datasize(2)/2,max(h.proMat(:))*2/3,'Leftside','FontSize',12,'Color',color);
    text(datasize(1)/2,0,max(h.proMat(:))*2/3,'Tail','FontSize',12,'Color',color);
    text(datasize(1)/2,datasize(2),max(h.proMat(:))*2/3,'Head','FontSize',12,'Color',color);
end

function toggleIt_wo(hObject)
% Toggle function without the drawing
if get(hObject,'Value')
    set(hObject,'FontWeight','bold');
    set(hObject,'BackgroundColor',[0.8,0.8,0.8]);
elseif ~get(hObject,'Value')
    set(hObject,'FontWeight','normal');
    set(hObject,'BackgroundColor',[0.94,0.94,0.94]);
end


% --- Initializes the first tab when gui is started --- %
function initTab(hObject,proMat)
currentTab = 'tabPro';

namesTab = {'tabPro','tabSlice','tab3D','tabBars'};
index = find(not(cellfun('isempty', strfind(namesTab, currentTab))));
namesTab(index) = [];
for i=1:3
   tabTag = char(namesTab(i)); 
   h = findobj('Tag',tabTag);
   set(h,'BackgroundColor',[0.8,0.8,0.8]);
   set(h,'FontWeight','normal');
end
h = findobj('Tag',currentTab);
set(h,'FontWeight','bold');
set(h,'BackgroundColor',[0.94,0.94,0.94]);

currentTabType = currentTab(4:end);
% Get panel list
panelArray = findall(findobj('Tag','figEmbrHeat'),'Type','uipanel');
panelTags = get(panelArray,'Tag');

% Make visible all panels belonging to the tab.
currentPanels = [];
otherPanels = [];
for i = 1:size(panelTags,1)
    name = char(panelTags(i));
    tabType = name(findstr(name,'_')+1:end);
    if strcmp(tabType,currentTabType)
        currentPanels = [currentPanels, panelArray(i)];
    elseif ~strcmp(tabType,currentTabType)
        if isempty(tabType)
        else
            otherPanels = [otherPanels, panelArray(i)];
        end
    end
end

set(currentPanels,'Visible','on');
set(otherPanels,'Visible','off');

% ---                       --- %
function clickTab(hObject)
currentTab = get(hObject,'Tag');
namesTab = {'tabPro','tabSlice','tab3D','tabBars'};
index = find(not(cellfun('isempty', strfind(namesTab, currentTab))));
namesTab(index) = [];
for i=1:3
   tabTag = char(namesTab(i)); 
   h = findobj('Tag',tabTag);
   set(h,'BackgroundColor',[0.8,0.8,0.8]);
   set(h,'FontWeight','normal');
end

set(hObject,'FontWeight','bold');
set(hObject,'BackgroundColor',[0.94,0.94,0.94]);
loadUpTab(hObject);


function loadUpTab(hObject)
% This function loads all the important buttons and data for the tab
% definded by hObject.

currentTab = get(hObject,'Tag');
currentTabType = currentTab(4:end);
% Get panel list
panelArray = findall(findobj('Tag','figEmbrHeat'),'Type','uipanel');
panelTags = get(panelArray,'Tag');

% Make visible all panels belonging to the tab.
currentPanels = [];
otherPanels = [];
for i = 1:size(panelTags,1)
    name = char(panelTags(i));
    tabType = name(findstr(name,'_')+1:end);
    if strcmp(tabType,currentTabType)
        currentPanels = [currentPanels, panelArray(i)];
    elseif ~strcmp(tabType,currentTabType)
        if isempty(tabType)
        else
            otherPanels = [otherPanels, panelArray(i)];
        end
    end
end

% Deactivate Rotation
h = guidata(hObject);
if ~strcmp(currentTabType,'3D')
    if get(h.btnRotate_3D,'Value')
        set(h.btnRotate_3D,'Value',0);
        toggleIt_wo(h.btnRotate_3D);
    end
    rotate3d off;
    drawnow;
end

% Deactivate data cursor

if ~strcmp(currentTabType,'Slice')
    if get(h.tbValue_Slice,'Value')
        set(h.tbValue_Slice,'Value',0);
        toggleIt_wo(h.tbValue_Slice);
    end
    if get(h.tbAnime,'Value')
        set(h.tbAnime,'Value',0);
        toggleIt_wo(h.tbAnime);
        animateStop(h);
    end
    if get(h.tbZoom,'Value')
        set(h.tbZoom,'Value',0);
        toggleIt_wo(h.tbZoom);
    end
    zoom off;
    datacursormode off;
    drawnow;
end

if ~strcmp(currentTabType,'Pro')
    if get(h.tbValue_Pro,'Value')
        set(h.tbValue_Pro,'Value',0);
        toggleIt_wo(h.tbValue_Pro);
    end
    if get(h.tbZoom_Pro,'Value')
        set(h.tbZoom_Pro,'Value',0);
        toggleIt_wo(h.tbZoom_Pro);
    end
    zoom off;
    datacursormode off;
    drawnow;
end

if ~strcmp(currentTabType,'Bars')
    if get(h.tb2DOnePlot,'Value')
        set(h.tb2DOnePlot,'Value',0);
        toggleIt_wo(h.tb2DOnePlot);
        set([h.subax1,h.subax2,h.subax3],'Visible','off');
        set(allchild(h.subax1),'Visible','off');
        set(allchild(h.subax2),'Visible','off');
        set(allchild(h.subax3),'Visible','off');
        set(h.axMain,'Visible','on');
        set(h.pm2DDim,'Enable','on');
    end
    % Activate tb rotate
    set(h.tbRot_Bars,'Value',0);
    toggleIt_wo(h.tbRot_Bars);
    set(h.tbRot_Bars,'Enable','off');
    set(h.tb3D_Bars,'Value',0);
    toggleIt_wo(h.tb3D_Bars);
    drawnow;
end




% Load data for the tab
loadDataForTab(guidata(hObject),currentTabType);

set(currentPanels,'Visible','on');
set(otherPanels,'Visible','off');


function loadDataForTab(h,currentTab)

if strcmp(currentTab,'Pro');
    drawProMap(h)
elseif strcmp(currentTab,'Slice');
    drawSlice(h,1)
elseif strcmp(currentTab,'3D');
    view(h.axMain,37.5+180,40);
    %set(h.axMain,'YDir','Reverse');
    draw3DMap(h);
elseif strcmp(currentTab,'Bars');
    drawBars2D(h);
    set(h.tb2D_Bars,'Value',1);
    set(h.tbRot_Bars,'Enable','off');
    set(h.pm2DDim,'Enable','on');
    set(h.cbLabelAxis_Bars,'Enable','off');
    set(h.tb2DOnePlot,'Enable','on');
    toggleIt_wo(h.tb2D_Bars);
end



% --- Projected tab functions ---%

function drawProMap(h)
axes(h.axMain), cla reset;
hold on;
if get(h.tbPoints_Pro,'Value')
    contour(h.proMat');
    scatter(h.samCoordsG(1,:),h.samCoordsG(2,:),'k','*');
else
    imagesc(h.proMat'),colormap('jet');
    axis tight manual
end
hold off;



% --- Slice by Slice tab functions --- %

% - Draw function - %
function drawSlice(h,sliceNumber)
clim = [0, max(h.densMat(:))];
cla(h.axMain,'reset');
imagesc(h.axMain,h.densMat(:,:,sliceNumber)'); 
colormap(h.axMain,'jet');
set(h.axMain,'YDir','Normal');
h.axMain.CLim = clim;


% - Slider Slice functions - %
function upSlicerMax(h,newMax)
h.slSlices.Max = newMax;
upTxSlicer(h,h.slSlices.Value,newMax);
drawnow;

function upSlicerPos(h,newPos)
h.slSlices.Value = newPos;
upTxSlicer(h,newPos,h.slSlices.Max);
drawnow;

function upTxSlicer(h,currentValue, max)
h.txSlicer.String = ['Slice ', num2str(currentValue),' of ', num2str(max)];
drawnow;

% - Animation functions - %

% These function will take care of the animation of the slice by slice
% representation. The speed value goes from 1-10 where 1 is slowest and 10
% is fastest. 1 represents 2.5 seconds between each slice and 10 0.25 seconds

function timefunction(x,y,h)

if get(h.slSlices,'Value')<get(h.slSlices,'Max')
    set(h.slSlices,'Value',get(h.slSlices,'Value')+1);
else
    set(h.slSlices,'Value',1);
end

axes(h.axMain);
upSlicerPos(h,get(h.slSlices,'Value'));
drawSlice(h,get(h.slSlices,'Value'));
drawnow;


function animateIt(hObject)
% This function is running while the Animation button is toggled.
h = guidata(hObject);
set(h.slAutoSpeed,'Enable','on');
speed = get(h.slAutoSpeed,'Value');
timesteps = fliplr(0.125:0.25:2.375);
period = timesteps(speed);
% Timer object
t = timer;
t.TimerFcn = {@timefunction,h};
t.Period = period;
t.TasksToExecute = 10000;
t.ExecutionMode = 'fixedRate';
start(t)

function animateStop(h)
t = timerfindall;
stop(t);
delete(t);
set(h.slAutoSpeed,'Enable','off');

% --- 3D tab functions --- %

function toggleIt(hObject)

if get(hObject,'Value')
    set(hObject,'FontWeight','bold');
    set(hObject,'BackgroundColor',[0.8,0.8,0.8]);
    draw3DMap(guidata(hObject));
elseif ~get(hObject,'Value')
    set(hObject,'FontWeight','normal');
    set(hObject,'BackgroundColor',[0.94,0.94,0.94]);
    draw3DMap(guidata(hObject));
end

function draw3DMap(h)
% This function draws the cloud heatmap. Therefore it has different options
% given by the user. They are stored in the handle h.

% Get axes and clear it
axes(h.axMain), cla;

hold on,
% Draws points if button Points is toggled
if get(h.tbPoints,'Value');
    scatter3(h.samCoordsG(2,:),h.samCoordsG(1,:),h.samCoordsG(3,:));
end

% Draws cloud if button Cloud is toggled
if get(h.tbCloud,'Value')
    drawCloud(h.densMat,get(h.slCloudLayer,'Value'),h.layerType,get(h.cbCloudSmooth,'Value'));
end


axis(h.axMain,'square')

% Show the side with the head and the tail


% Set limits
if get(h.rbSamples,'Value')
    set(h.axMain,'XLim',[0, h.samples]);
    set(h.axMain,'YLim',[0, h.samples]);
    set(h.axMain,'ZLim',[0, h.samples]);
elseif get(h.rbDatasize,'Value')
    sizData = size(h.densMat);
    h.axMain.XLim = [0, sizData(1)];
    h.axMain.YLim = [0, sizData(2)];
    h.axMain.ZLim = [0, sizData(3)];
end


function drawCloud(data,numOfLayers,layerType,smooth)
% Input:
%   data:           density map.
%   numOfLayers:    number of Layers. In [1 5]. From highest density to lower
%   layerType:      prototype
%   smooth:         sets value if we smooth the data or not.
%%%%%%%%%%%%%%%%
% Main Code:

% Transparancy
transArray = [1, 0.4 , 0.3 , 0.2 , 0.1];
% Color for the layers
colorArray = flipud(colormap('jet'));
colors = zeros(5,3);
steps = 4:15:64;
for i=1:5
    index = steps(i);
    colors(i,:) = colorArray(index,:);
end
colors(1,:) = colorArray(1,:);

% Find the density in the data in a linear way
minD = min(data(:));
maxD = max(data(:));
% normalize onto [0,5]
data = (data-minD)/maxD*5;

if strcmp(layerType,'linear')
    layerValues = 1:5;
    % Check if layerValues are really points in the data or fit them on
    % data
    for i=2:5
        [~,index] = min(abs(data(:)-layerValues(i)));
        layerValues(i) = data(index(1));
    end
end
layerValues = fliplr(layerValues);
layerValues = layerValues(1:numOfLayers);

ax = gca;
if smooth
    data = smooth3(data);
end
for i = 1:numOfLayers
    isoS = isosurface(data,layerValues(i));
    p = patch(isoS,'FaceColor',colors(i,:),'FaceAlpha',transArray(i),'EdgeColor','none');
    isonormals(data,p), daspect([1 1 1]), axis tight manual, camlight(-80,-10), lighting gouraud;
end

% --- Bars tab functions --- 

function drawBars2D(h)

cla(h.axMain,'reset');

if get(h.tb2DOnePlot,'Value')
    
    posAx = get(h.axMain,'Position');
    units = get(h.axMain,'Units');
    
    set(h.axMain,'Visible','off');
    set(allchild(h.axMain),'visible','off');
    sizData = size(h.densMat);
    
    % Subplot 1
    set(h.subax1,'Visible','on');
    set(h.subax1,'Units',units);
    set(h.subax1,'Position',[posAx(1) posAx(2)+8+2*(posAx(4)-8)/3 posAx(3) (posAx(4)-8)/3]);
    barMat1 = permute(sum(sum(h.densMat)),[3,2,1]);
    b1 = bar(h.subax1,barMat1);
    xlabel(h.subax1,'Slices','FontSize',10);
    set(h.subax1,'YTickLabel','');
    
    % Subplot 2
    set(h.subax2,'Visible','on');
    set(h.subax2,'Units',units);
    set(h.subax2,'Position',[posAx(1) posAx(2)+4+(posAx(4)-8)/3 posAx(3) (posAx(4)-8)/3]);
    barMat2 = sum(sum(h.densMat,3),2);
    b2 = bar(h.subax2,barMat2);
    xlabel(h.subax2,'Tail \leftarrow \rightarrow Head','FontSize',10);
    set(h.subax2,'YTickLabel','');
    
    % Subplot 3
    set(h.subax3,'Visible','on');
    set(h.subax3,'Units',units);
    set(h.subax3,'Position',[posAx(1) posAx(2) posAx(3) (posAx(4)-8)/3]);
    barMat3 = sum(sum(h.densMat,3),1)';
    b3 = bar(h.subax3,barMat3);
    xlabel(h.subax3,'Leftside \leftarrow \rightarrow Rightside','FontSize',10)
    set(h.subax3,'YTickLabel','');
    
    % Set limits
    if get(h.rbSamples,'Value')
        set([h.subax1,h.subax2,h.subax3],'XLim',[1, h.samples]);
    elseif get(h.rbDatasize,'Value')
        h.subax1.XLim = [1, sizData(3)];
        h.subax2.XLim = [1, sizData(1)];
        h.subax3.XLim = [1, sizData(2)];
    end
    drawnow;
else
    
    % Delete subaxis if visible
    set([h.subax1,h.subax2,h.subax3],'Visible','off');
    
    % Gets the selected popup menu value
    pmSelect = h.pmSelection;
    if pmSelect == 1
        barMat = permute(sum(sum(h.densMat)),[3,2,1]);
    elseif pmSelect ==2
        barMat = sum(sum(h.densMat,3),2);
    elseif pmSelect == 3
        barMat = sum(sum(h.densMat,3),1)';
    end
    bar(h.axMain,barMat);
    colormap('jet')
    set(h.axMain,'YTickLabel','');
    % Set limits
    if get(h.rbSamples,'Value')
        set(h.axMain,'XLim',[1, h.samples]);
        if pmSelect == 1
            xlabel(h.axMain,'Slices','FontSize',10);
        elseif pmSelect == 2
            xlabel(h.axMain,'Tail \leftarrow \rightarrow Head','FontSize',10);
        elseif pmSelect == 3
            xlabel(h.axMain,'Leftside \leftarrow \rightarrow Rightside','FontSize',10)
        end
    elseif get(h.rbDatasize,'Value')
        sizData = size(h.densMat);
        if pmSelect == 1
            h.axMain.XLim = [1, sizData(3)];
            xlabel(h.axMain,'Slices','FontSize',10);
        elseif pmSelect == 2
            h.axMain.XLim = [1, sizData(1)];
            xlabel(h.axMain,'Tail \leftarrow \rightarrow Head','FontSize',10);
        elseif pmSelect == 3
            h.axMain.XLim = [1, sizData(2)];
            xlabel(h.axMain,'Leftside \leftarrow \rightarrow Rightside','FontSize',10)
        end
    end
end


drawnow;

function drawBars3D(h)

proMat = sum(h.densMat,3);
b = bar3(h.axMain,proMat);

colormap('jet')
for k = 1:length(b)
    zdata = b(k).ZData;
    b(k).CData = zdata;
    b(k).FaceColor = 'interp';
end

set(h.axMain,'XLim',[1, h.samples]);
set(h.axMain,'YLim',[1, h.samples]);
set(h.axMain,'YDir','Reverse');
set(h.axMain,'ZTickLabel','');
align_axislabels(3,h.axMain);
view(h.axMain,37.5+180,40);

if get(h.cbLabelAxis,'Value')
    if get(h.rbSamples,'Value')
        labelAxis(h,[h.samples,h.samples],'magenta');
    elseif get(h.rbDatasize,'Value')
        labelAxis(h,size(proMat));
    end
end

%% UI CONTROL FUNCTIONS
% --- Outputs from this function are returned to the command line.
function varargout = Embryo_Heatmap_OutputFcn(hObject, eventdata, h) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% h    structure with h and user data (see GUIDATA)

% Get default command line output from h structure
varargout{1} = h.output;


% --- Executes on button press in tabPro.
function tabPro_Callback(hObject, eventdata, h)
% hObject    handle to tabPro (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% h    structure with h and user data (see GUIDATA)

% Update uicontrols
clickTab(hObject);
h.currentTab = 'Pro';

guidata(hObject,h);

% --- Executes on button press in tab3D.
function tab3D_Callback(hObject, eventdata, h)
% hObject    handle to tab3D (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% h    structure with h and user data (see GUIDATA)

% Update uicontrols
clickTab(hObject);
h.currentTab = '3D';
guidata(hObject,h);

% --- Executes on button press in tabBars.
function tabBars_Callback(hObject, eventdata, h)
% hObject    handle to tabBars (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% h    structure with h and user data (see GUIDATA)

% Update uicontrols
clickTab(hObject);
h.currentTab = 'Bars';
guidata(hObject,h);

% --- Executes on button press in tabSlice.
function tabSlice_Callback(hObject, eventdata, h)
% hObject    handle to tabSlice (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% h    structure with h and user data (see GUIDATA)
clickTab(hObject);
h.currentTab = 'Slice';
guidata(hObject,h);

% --- Executes on button press in btnSave.
function btnSave_Callback(hObject, eventdata, h)
% hObject    handle to btnSave (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% h    structure with h and user data (see GUIDATA)


% --- Executes on button press in rbSamples.
function rbSamples_Callback(hObject, eventdata, h)
% hObject    handle to rbSamples (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% h    structure with h and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of rbSamples
h ...
    = updateSampAndDens(h,'samples',h.typeNH,h.sizeNH,h.samples);
if strcmp(h.currentTab,'Pro')
    axes(h.axMain),drawProMap(h);
elseif strcmp(h.currentTab,'3D')
    axes(h.axMain),draw3DMap(h);
elseif strcmp(h.currentTab,'Slice')
    drawSlice(h,get(h.slSlices,'Value'));
elseif strcmp(h.currentTab,'Bars')
    if get(h.tb2D_Bars)
        axes(h.axMain),drawBars2D(h);
    elseif get(h.tb3D_Bars)
        axes(h.axMain),drawBars3D(h);
    end
end
upSlicerMax(h,size(h.densMat,3));
upSlicerPos(h,1);

guidata(hObject,h);


% --- Executes on button press in rbDatasize.
function rbDatasize_Callback(hObject, eventdata, h)
% hObject    handle to rbDatasize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% h    structure with h and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of rbDatasize

h ...
    = updateSampAndDens(h,'datasize',h.typeNH,h.sizeNH,h.samples);
if strcmp(h.currentTab,'Pro')
    axes(h.axMain),drawProMap(h);
elseif strcmp(h.currentTab,'3D')
    axes(h.axMain),draw3DMap(h);
elseif strcmp(h.currentTab,'Slice')
    drawSlice(h,get(h.slSlices,'Value'));
elseif strcmp(h.currentTab,'Bars')
    if get(h.tb2D_Bars)
        axes(h.axMain),drawBars2D(h);
    elseif get(h.tb3D_Bars)
        axes(h.axMain),drawBars3D(h);
    end
end

upSlicerMax(h,size(h.densMat,3));
if size(h.densMat,3)>get(h.slSlices,'Value')
    set(h.slSlices,'Value',size(h.densMat,3));
end

% Update the slider in slices
if size(h.densMat,3)<get(h.slSlices,'Value')
   set(h.slSlices,'Value',size(h.densMat,3)); 
end
set(h.slSlices,'Max',size(h.densMat,3));


guidata(hObject,h);


function edSamples_Callback(hObject, eventdata, h)
% hObject    handle to edSamples (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% h    structure with h and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edSamples as text
%        str2double(get(hObject,'String')) returns contents of edSamples as a double

h.samples = str2double(get(hObject,'String'));
set(hObject,'Value',h.samples);
h ...
    = updateSampAndDens(h,'samples',h.typeNH,h.sizeNH,h.samples);


% Activate the radiobutton for the samples
set(h.rbSamples,'Value',1);

% Update the slider in slices
if h.samples<get(h.slSlices,'Value')
   set(h.slSlices,'Value',h.samples); 
end
set(h.slSlices,'Max',h.samples);

% Draw in axes
if strcmp(h.currentTab,'Pro')
    axes(h.axMain),drawProMap(h);
elseif strcmp(h.currentTab,'3D')
    axes(h.axMain),draw3DMap(h);
elseif strcmp(h.currentTab,'Slice')
    drawSlice(h,get(h.slSlices,'Value'));
elseif strcmp(h.currentTab,'Bars')
    if get(h.tb2D_Bars)
        axes(h.axMain),drawBars2D(h);
    elseif get(h.tb3D_Bars)
        axes(h.axMain),drawBars3D(h);
    end
end
guidata(hObject,h);

% --- Executes during object creation, after setting all properties.
function edSamples_CreateFcn(hObject, eventdata, h)
% hObject    handle to edSamples (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% h    empty - h not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in tbCloud.
function tbCloud_Callback(hObject, eventdata, h)
% hObject    handle to tbCloud (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% h    structure with h and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of tbCloud
toggleIt(hObject);
if get(h.cbLabelAxis,'Value')
    if get(h.rbSamples,'Value')
        labelAxis(h,[h.samples,h.samples],'magenta');
    elseif get(h.rbDatasize,'Value')
        labelAxis(h,size(h.proMat));
    end
end


% --- Executes on button press in tbPoints.
function tbPoints_Callback(hObject, eventdata, h)
% hObject    handle to tbPoints (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% h    structure with h and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of tbPoints
toggleIt(hObject);
if get(h.cbLabelAxis,'Value')
    if get(h.rbSamples,'Value')
        labelAxis(h,[h.samples,h.samples],'magenta');
    elseif get(h.rbDatasize,'Value')
        labelAxis(h,size(h.proMat));
    end
end

% --- Executes on button press in cbCloudSmooth.
function cbCloudSmooth_Callback(hObject, eventdata, h)
% hObject    handle to cbCloudSmooth (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% h    structure with h and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of cbCloudSmooth

draw3DMap(h);

% --- Executes on slider movement.
function slCloudLayer_Callback(hObject, eventdata, h)
% hObject    handle to slCloudLayer (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% h    structure with h and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

draw3DMap(h);

% --- Executes during object creation, after setting all properties.
function slCloudLayer_CreateFcn(hObject, eventdata, h)
% hObject    handle to slCloudLayer (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% h    empty - h not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


function edSizeNH_Callback(hObject, eventdata, h)
% hObject    handle to edSizeNH (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% h    structure with h and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edSizeNH as text
%        str2double(get(hObject,'String')) returns contents of edSizeNH as a double

h.sizeNH = str2double(get(hObject,'String'));

% If its the same value as before
if h.sizeNH == get(hObject,'Value')
    return
end

set(hObject,'Value',h.sizeNH);
if get(h.rbSamples,'Value')
    h ...
        = updateSampAndDens(h,'samples',h.typeNH,h.sizeNH,h.samples);
elseif get(h.rbDatasize,'Value')
    h ...
        = updateSampAndDens(h,'datasize',h.typeNH,h.sizeNH,h.samples);
end

% Draw in axes
if strcmp(h.currentTab,'Pro')
    axes(h.axMain),drawProMap(h);
elseif strcmp(h.currentTab,'3D')
    axes(h.axMain),draw3DMap(h);
elseif strcmp(h.currentTab,'Slice')
    	drawSlice(h);
elseif strcmp(h.currentTab,'Bars')
    if get(h.tb2D_Bars,'Value')
        drawBars2D(h);
    elseif get(h.tb3D_Bars,'Value')
        drawBars3D(h);
    end
end
guidata(hObject,h);


% --- Executes during object creation, after setting all properties.
function edSizeNH_CreateFcn(hObject, eventdata, h)
% hObject    handle to edSizeNH (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% h    empty - h not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




% --- Executes on button press in btnRotate_3D.
function btnRotate_3D_Callback(hObject, eventdata, h)
% hObject    handle to btnRotate_3D (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% h    structure with h and user data (see GUIDATA)

toggleIt_wo(hObject);

% Activate 3D rotation
if get(hObject,'Value')
    rotate3d on;
    % If zoom is activated deactivate it
    if get(h.btnZoom_3D,'Value')
       zoom off;
       set(h.btnZoom_3D,'Value',0);
       toggleIt_wo(h.btnZoom_3D);
    end
else
    rotate3d off
end

guidata(hObject,h);

% --- Executes on button press in btnZoom_3D.
function btnZoom_3D_Callback(hObject, eventdata, h)
% hObject    handle to btnZoom_3D (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% h    structure with h and user data (see GUIDATA)

toggleIt_wo(hObject);

% Activate zoom
if get(hObject,'Value')
    zoom on
    % If zoom is activated deactivate it
    if get(h.btnRotate_3D,'Value')
       rotate3d off;
       toggleIt_wo(h.btnRotate_3D);
       set(h.btnRotate_3D,'Value',0);
    end
else
    zoom off
end
guidata(hObject,h);


% --- Executes on button press in tbPoints_Pro.
function tbPoints_Pro_Callback(hObject, eventdata, h)
% hObject    handle to tbPoints_Pro (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% h    structure with h and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of tbPoints_Pro

toggleIt_wo(hObject);
drawProMap(guidata(hObject));

% --- Executes on button press in tbAnime.
function tbAnime_Callback(hObject, eventdata, h)
% hObject    handle to tbAnime (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% h    structure with h and user data (see GUIDATA)
toggleIt_wo(hObject)
if get(h.tbAnime,'Value')
    animateIt(hObject);
else
    animateStop(h);
end

% --- Executes on slider movement.
function slAutoSpeed_Callback(hObject, eventdata, h)
% hObject    handle to slAutoSpeed (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% h    structure with h and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

animateStop(h);
animateIt(hObject);

% --- Executes during object creation, after setting all properties.
function slAutoSpeed_CreateFcn(hObject, eventdata, h)
% hObject    handle to slAutoSpeed (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% h    empty - h not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function slSlices_Callback(hObject, eventdata, h)
% hObject    handle to slSlices (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% h    structure with h and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
set(hObject,'Value',round(get(hObject,'Value')));
drawSlice(h,get(hObject,'Value'));
upTxSlicer(h,get(hObject,'Value'), get(hObject,'Max'));


% --- Executes during object creation, after setting all properties.
function slSlices_CreateFcn(hObject, eventdata, h)
% hObject    handle to slSlices (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% h    empty - h not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on button press in tbValue_Pro.
function tbValue_Pro_Callback(hObject, eventdata, h)
% hObject    handle to tbValue_Pro (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% h    structure with h and user data (see GUIDATA)
toggleIt_wo(hObject);
if get(hObject,'Value')
    datacursormode on
    zoom off
    set(h.tbZoom_Pro,'Value',0);
    toggleIt_wo(h.tbZoom_Pro);
else
    datacursormode off
end

% --- Executes on button press in tbValue_Slice.
function tbValue_Slice_Callback(hObject, eventdata, h)
% hObject    handle to tbValue_Slice (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% h    structure with h and user data (see GUIDATA)
toggleIt_wo(hObject);
if get(hObject,'Value')
    datacursormode on
    zoom off
    set(h.tbZoom,'Value',0);
    toggleIt_wo(h.tbZoom);
else
    datacursormode off
end


% --- Executes on button press in tbZoom_Pro.
function tbZoom_Pro_Callback(hObject, eventdata, h)
% hObject    handle to tbZoom_Pro (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% h    structure with h and user data (see GUIDATA)

toggleIt_wo(hObject);

% Activate zoom
if get(hObject,'Value')
    zoom on
    datacursormode off
    set(h.tbValue_Pro,'Value',0);
    toggleIt_wo(h.tbValue_Pro);
else
    zoom off
end
guidata(hObject,h);


% --- Executes on button press in tbZoom.
function tbZoom_Callback(hObject, eventdata, h)
% hObject    handle to tbZoom (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% h    structure with h and user data (see GUIDATA)

toggleIt_wo(hObject);

% Activate zoom
if get(hObject,'Value')
    zoom on
    datacursormode off
    set(h.tbValue_Slice,'Value',0);
    toggleIt_wo(h.tbValue_Slice);
else
    zoom off
end
guidata(hObject,h);



% --- Executes on button press in tb2D_Bars.
function tb2D_Bars_Callback(hObject, eventdata, h)
% hObject    handle to tb2D_Bars (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% h    structure with h and user data (see GUIDATA)

toggleIt_wo(hObject);

% Activate bars
if get(hObject,'Value')
    set(h.tb3D_Bars,'Value',0);
    toggleIt_wo(h.tb3D_Bars);
    drawBars2D(h);
    
    % Activate popupmenu
    set(h.pm2DDim,'Enable','on');
    set(h.tb2DOnePlot,'Enable','on');
    set(h.cbLabelAxis_Bars,'Enable','off');
    % Deactivate tb rotate
    set(h.tbRot_Bars,'Value',0);
    toggleIt_wo(h.tbRot_Bars);
    set(h.tbRot_Bars,'Enable','off');
    rotate3d off;
    
    set(h.cbLabelAxis,'Enable','off');

else
    set(hObject,'Value',1);
    toggleIt_wo(hObject);
end
guidata(hObject,h);


% --- Executes on button press in tb3D_Bars.
function tb3D_Bars_Callback(hObject, eventdata, h)
% hObject    handle to tb3D_Bars (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% h    structure with h and user data (see GUIDATA)

toggleIt_wo(hObject);

% Activate bars
if get(hObject,'Value')
    set(h.tb2D_Bars,'Value',0);
    toggleIt_wo(h.tb2D_Bars);
    set([h.subax1,h.subax2,h.subax3],'Visible','off');
    set(allchild(h.subax1),'Visible','off');
    set(allchild(h.subax2),'Visible','off');
    set(allchild(h.subax3),'Visible','off');
    drawBars3D(h);
    % Deactivate popupmenu and On Plot
    set(h.pm2DDim,'Enable','off');
    set(h.tb2DOnePlot,'Enable','off');
    % Activate tb rotate
    set(h.tbRot_Bars,'Value',0);
    set(h.tbRot_Bars,'Enable','on');
    set(h.cbLabelAxis_Bars,'Enable','on');
    % Enable Checkbox
    set(h.cbLabelAxis,'Enable','on');
else
    set(hObject,'Value',1);
    toggleIt_wo(hObject);
    
end
guidata(hObject,h);


% --- Executes on button press in tb2DOnePlot.
function tb2DOnePlot_Callback(hObject, eventdata, h)
% hObject    handle to tb2DOnePlot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% h    structure with h and user data (see GUIDATA)
toggleIt_wo(hObject);
drawBars2D(h);
if get(hObject,'Value')
    set(h.pm2DDim,'Enable','off');
else
    set(h.pm2DDim,'Enable','on');
end


% --- Executes on selection change in pm2DDim.
function pm2DDim_Callback(hObject, eventdata, h)
% hObject    handle to pm2DDim (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% h    structure with h and user data (see GUIDATA)

h.pmSelection = get(hObject,'Value');
drawBars2D(h);

guidata(hObject,h);


% --- Executes during object creation, after setting all properties.
function pm2DDim_CreateFcn(hObject, eventdata, h)
% hObject    handle to pm2DDim (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% h    empty - h not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in tbRot_Bars.
function tbRot_Bars_Callback(hObject, eventdata, h)
% hObject    handle to btnRotate_3D (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% h    structure with h and user data (see GUIDATA)

toggleIt_wo(hObject);

% Activate 3D rotation
if get(hObject,'Value')
    rotate3d on
else
    rotate3d off
end

guidata(hObject,h);


% --- Executes on button press in cbLabelAxis.
function cbLabelAxis_Callback(hObject, eventdata, h)
% hObject    handle to cbLabelAxis (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% h    structure with h and user data (see GUIDATA)

if get(h.cbLabelAxis,'Value')
    if get(h.rbSamples,'Value')
        labelAxis(h,[h.samples,h.samples],'magenta');
    elseif get(h.rbDatasize,'Value')
        labelAxis(h,size(h.proMat));
    end
else
    axes(h.axMain),drawProMap(h);
end

% --- Executes on button press in cbLabelAxis_Slice.
function cbLabelAxis_Slice_Callback(hObject, eventdata, h)
% hObject    handle to cbLabelAxis_Slice (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if get(h.cbLabelAxis_Slice,'Value')
    if get(h.rbSamples,'Value')
        labelAxis(h,[h.samples,h.samples],'magenta');
    elseif get(h.rbDatasize,'Value')
        labelAxis(h,size(h.proMat));
    end
else
    drawSlice(h,get(h.slSlices,'Value'));
end

% --- Executes on button press in cbLabelAxis_Bars.
function cbLabelAxis_Bars_Callback(hObject, eventdata, h)
% hObject    handle to cbLabelAxis_Bars (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if get(h.cbLabelAxis_Bars,'Value')
    if get(h.rbSamples,'Value')
        labelAxis(h,[h.samples,h.samples],'magenta');
    elseif get(h.rbDatasize,'Value')
        labelAxis(h,size(h.proMat));
    end
else
    axes(h.axMain),drawBars3D(h);
end
% --- Executes on button press in cbLabelAxis_3D.
function cbLabelAxis_3D_Callback(hObject, eventdata, h)
% hObject    handle to cbLabelAxis_3D (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if get(h.cbLabelAxis_3D,'Value')
    if get(h.rbSamples,'Value')
        labelAxis(h,[h.samples,h.samples],'magenta');
    elseif get(h.rbDatasize,'Value')
        labelAxis(h,size(h.proMat));
    end
else
    axes(h.axMain),draw3DMap(h);
end

% --- Executes during object creation, after setting all properties.
function paControlPH_CreateFcn(hObject, eventdata, h)
% hObject    handle to paControlPH (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes during object creation, after setting all properties.
function paVisPH_CreateFcn(hObject, eventdata, handles)
% hObject    handle to paVisPH (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes on selection change in pmPH.
function pmPH_Callback(hObject, eventdata, handles)
% hObject    handle to pmPH (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns pmPH contents as cell array
%        contents{get(hObject,'Value')} returns selected item from pmPH


% --- Executes during object creation, after setting all properties.
function pmPH_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pmPH (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on slider movement.
function slTop_Callback(hObject, eventdata, handles)
% hObject    handle to slTop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function slTop_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slTop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function slBot_Callback(hObject, eventdata, handles)
% hObject    handle to slBot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function slBot_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slBot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


