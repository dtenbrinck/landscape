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

% Last Modified by GUIDE v2.5 01-Jul-2016 00:59:17

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
% Update handles structure
guidata(hObject, handles);

% UIWAIT makes Embryo_Heatmap wait for user response (see UIRESUME)
% uiwait(handles.figEmbrHeat);

%% OTHER FUNCTIONS 

function clickTab(hObject)
currentTab = get(hObject,'Tag');
namesTab = {'tabPro','tab3D','tabBars'};
index = find(not(cellfun('isempty', strfind(namesTab, currentTab))));
namesTab(index) = [];
for i=1:2
   tabTag = char(namesTab(i)); 
   h = findobj('Tag',tabTag);
   set(h,'BackgroundColor',[0.8,0.8,0.8]);
   set(h,'FontWeight','normal');
end

set(hObject,'FontWeight','bold');
set(hObject,'BackgroundColor',[0.94,0.94,0.94]);

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

% Compute projected matrix
handles.proMat = sum(handles.densMat,3);

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



function edSamples_Callback(hObject, eventdata, handles)
% hObject    handle to edSamples (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edSamples as text
%        str2double(get(hObject,'String')) returns contents of edSamples as a double

handles.samples = str2double(get(hObject,'String'));
set(hObject,'Value',handles.samples);
if get(handles.rbSamples,'Value')
    handles ...
        = updateSampAndDens(handles,'samples',handles.typeNH,handles.sizeNH,handles.samples);
end
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
