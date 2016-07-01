function varargout = Embryo_Heatmap(varargin)
% EMBRYO_HEATMAP MATLAB code for Embryo_Heatmap.fig
%      EMBRYO_HEATMAP, by itself, creates a new EMBRYO_HEATMAP or raises the existing
%      singleton*.
%
%      H = EMBRYO_HEATMAP returns the handle to a new EMBRYO_HEATMAP or the handle to
%      the existing singleton*.
%
%      EMBRYO_HEATMAP('CALLBACK',hObject,eventData,handles,...) calls the local
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

% Last Modified by GUIDE v2.5 01-Jul-2016 15:44:51

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
function Embryo_Heatmap_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Embryo_Heatmap (see VARARGIN)

% Choose default command line output for Embryo_Heatmap
handles.output = hObject;

% Load handles from the main GUI
handles.MGH = varargin{1,1};

% Initialize the data for the heatmaps %


% Set defaults

handles.typeNH = 'sphere';
handles.sizeNH = 3;
handles.numOfLayers = 4;
handles.layerType = 'linear';

% Get all cell coordinates
fieldNames = fieldnames(handles.MGH.SegData);
allCentCoords = [];
for i = 1:size(fieldNames,1)
   allCentCoords = horzcat(allCentCoords,handles.MGH.SegData.(char(fieldNames(i))).centCoords);
end
handles.allCentCoords = allCentCoords;
handles.numOfCells = size(allCentCoords,2);
handles.sizeLandmark = size(handles.MGH.SegData.(fieldNames{1}).landmark);

% Compute the standard density matrix
handles = updateSampAndDens(handles);

% Update uicontrols
axes(handles.axMain),imagesc(handles.proMat), colormap('jet');
set(handles.tabPro,'FontWeight','bold');
set(handles.tab3D,'FontWeight','normal');
set(handles.tabBars,'FontWeight','normal');
clickTab(handles.tabPro);
set(handles.edSamples,'String',num2str(handles.MGH.samples));
set(handles.edSamples,'Value',handles.MGH.samples);
set(handles.slCloudLayer,...
    'Min',1,...
    'Max',numOfSlices,...
    'Value',4,...
    'SliderStep', [1 ,1]/(5-1));

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes Embryo_Heatmap wait for user response (see UIRESUME)
% uiwait(handles.figEmbrHeat);

%% OTHER FUNCTIONS 

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
set(currentPanels,'Visible','on');
set(otherPanels,'Visible','off');

function toggleIt(hObject)

if get(hObject,'Value')
    set(hObject,'FontWeight','bold');
    set(hObject,'BackgroundColor',[0.8,0.8,0.8]);
elseif ~get(hObject,'Value')
    set(hObject,'FontWeight','normal');
    set(hObject,'BackgroundColor',[0.94,0.94,0.94]);
end

function handles = updateSampAndDens(handles,sampleType,typeNH,sizeNH,samples)
% Input:
%   sampleType:     Type of the sampling: 'datasize', 'samples'
%                       'datasize': Sampling on size(landmark) grid
%                       'samples':  Sampling on input variable samples
%   typeNH:         Type of the neighbourhood: 'sphere','cube'
%                       'sphere':   spherical neighbourhood of diameter sizeNH
%                       'cube':     cubic neighbourhood of size sizeNH
%   sizeNH:         Size of the neighbourhood for the density. Default: 3
%   samples:        Only used when sampleType is 'samples'. Default:
%                                                       Sampling of sphere
% % % % % % % % % % % % % % % % % % % % % % % %

if nargin < 2
    sampleType = 'samples';
end 
if nargin < 3
    typeNH = 'sphere';
end
if nargin < 4
    sizeNH = 3;
end
if nargin < 5
    samples = handles.MGH.samples;
end
if strcmp(sampleType,'datasize')
    [handles.samCoordsG,handles.samCoordsU] ...
        = fitOnSamSphere(handles.allCentCoords,handles.sizeLandmark);
    handles.densMat ...
        = compDens3D(handles.sizeLandmark,handles.samCoordsG,sizeNH,typeNH);
elseif strcmp(sampleType,'samples')
    [handles.samCoordsG,handles.samCoordsU] ...
        = fitOnSamSphere(handles.allCentCoords,samples);
    handles.densMat ...
        = compDens3D(samples,handles.samCoordsG,sizeNH,typeNH);
end

% Update handles
handles.sampleType = sampleType;
handles.typeNH = typeNH;
handles.sizeNH = sizeNH;
handles.samples = samples;

% Compute projected matrix
handles.proMat = sum(handles.densMat,3);


function draw3DMap(h)
% This function draws the cloud heatmap. Therefore it has different options
% given by the user. They are stored in the handle h.

% Get axes and clear it
axes(h.axMain), cla;
hold on;

% Draws points if button Points is toggled
if get(h.tbPoints,'Value');
    scatter3(samCoordsG(1,:),samCoordsG(2,:),samCoordsG(3,:));
end

% Draws cloud if button Cloud is toggled
if get(h.tbCloud)
    drawCloud(h.densMat,get(h.slCloudLayer,'Value'),h.layerType,get(h.cbCloudSmooth,'Value'));
end

function drawCloud(data,numOfLayers,layerType,smooth);
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
for i=4:15:64;
    colors(i,:) = colorArray(i,:);
end
colors(1,:) = colorArray(1,:);
colors = colors(1:numOfLayers);

% Find the density in the data in a linear way
minD = min(data(:));
maxD = max(data(:));

if strcmp(layerType,'linear')
    layerValues = round(minD:(maxD-minD)/4:maxD);
    % Check if layerValues are really points in the data or fit them on
    % data
    for i=2:4
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
    p = patch(isoS,'FaceColor',colors(i),'FaceAlpha',transArray(i),'EdgeColor','none');
    isonormals(data,p), view(3), daspect([1 1 1]), axis tight, camlight(-80,-10), lighting gouraud;
end

%% UI CONTROL FUNCTIONS
% --- Outputs from this function are returned to the command line.
function varargout = Embryo_Heatmap_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in tabPro.
function tabPro_Callback(hObject, eventdata, handles)
% hObject    handle to tabPro (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Update uicontrols
axes(handles.axMain),imagesc(handles.proMat), colormap('jet');
clickTab(hObject);

guidata(hObject,handles);
% --- Executes on button press in tab3D.
function tab3D_Callback(hObject, eventdata, handles)
% hObject    handle to tab3D (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Update uicontrols
axes(handles.axMain),imagesc(handles.proMat), colormap('jet');
clickTab(hObject);

guidata(hObject,handles);

% --- Executes on button press in tabBars.
function tabBars_Callback(hObject, eventdata, handles)
% hObject    handle to tabBars (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Update uicontrols
axes(handles.axMain),imagesc(handles.proMat), colormap('jet');
clickTab(hObject);

guidata(hObject,handles);

% --- Executes on button press in tabSlice.
function tabSlice_Callback(hObject, eventdata, handles)
% hObject    handle to tabSlice (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
clickTab(hObject);

% --- Executes on button press in btnSave.
function btnSave_Callback(hObject, eventdata, handles)
% hObject    handle to btnSave (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in rbSamples.
function rbSamples_Callback(hObject, eventdata, handles)
% hObject    handle to rbSamples (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of rbSamples

get(hObject,'Value');
handles ...
    = updateSampAndDens(handles,'samples',handles.typeNH,handles.sizeNH,handles.samples);
axes(handles.axMain),imagesc(handles.proMat),colormap('jet');
guidata(hObject,handles);


% --- Executes on button press in rbDatasize.
function rbDatasize_Callback(hObject, eventdata, handles)
% hObject    handle to rbDatasize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of rbDatasize

handles ...
    = updateSampAndDens(handles,'datasize',handles.typeNH,handles.sizeNH,handles.samples);
axes(handles.axMain),imagesc(handles.proMat),colormap('jet');

guidata(hObject,handles);


function edSamples_Callback(hObject, eventdata, handles)
% hObject    handle to edSamples (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edSamples as text
%        str2double(get(hObject,'String')) returns contents of edSamples as a double

handles.samples = str2double(get(hObject,'String'));
set(hObject,'Value',handles.samples);
handles ...
    = updateSampAndDens(handles,'samples',handles.typeNH,handles.sizeNH,handles.samples);
axes(handles.axMain), imagesc(handles.proMat), colormap('jet');
% Activate the radiobutton for the samples
set(handles.rbSamples,'Value',1);
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function edSamples_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edSamples (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in tbCloud.
function tbCloud_Callback(hObject, eventdata, handles)
% hObject    handle to tbCloud (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of tbCloud
toggleIt(hObject);

guidata(hObject,handles);

% --- Executes on button press in tbPoints.
function tbPoints_Callback(hObject, eventdata, handles)
% hObject    handle to tbPoints (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of tbPoints
toggleIt(hObject);

guidata(hObject,handles);


% --- Executes on button press in cbCloudSmooth.
function cbCloudSmooth_Callback(hObject, eventdata, handles)
% hObject    handle to cbCloudSmooth (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of cbCloudSmooth


% --- Executes on slider movement.
function slCloudLayer_Callback(hObject, eventdata, handles)
% hObject    handle to slCloudLayer (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function slCloudLayer_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slCloudLayer (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end
