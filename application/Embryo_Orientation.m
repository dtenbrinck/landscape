function varargout = Embryo_Orientation(varargin)
% EMBRYO_ORIENTATION MATLAB code for Embryo_Orientation.fig
%      EMBRYO_ORIENTATION, by itself, creates a new EMBRYO_ORIENTATION or raises the existing
%      singleton*.
%
%      H = EMBRYO_ORIENTATION returns the handle to a new EMBRYO_ORIENTATION or the handle to
%      the existing singleton*.
%
%      EMBRYO_ORIENTATION('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in EMBRYO_ORIENTATION.M with the given input arguments.
%
%      EMBRYO_ORIENTATION('Property','Value',...) creates a new EMBRYO_ORIENTATION or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Embryo_Orientation_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Embryo_Orientation_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help Embryo_Orientation

% Last Modified by GUIDE v2.5 29-Jun-2016 16:23:53

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Embryo_Orientation_OpeningFcn, ...
                   'gui_OutputFcn',  @Embryo_Orientation_OutputFcn, ...
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


% --- Executes just before Embryo_Orientation is made visible.
function Embryo_Orientation_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Embryo_Orientation (see VARARGIN)

% Choose default command line output for Embryo_Orientation
handles.output = hObject;

% Load handles from the main GUI
handles.MGH = varargin{1,1};

% Initializing the GUI

% Get names of the Data fields
handles.datanames = fieldnames(handles.MGH.data);

% Set axes
axes(handles.axes1), imagesc(handles.MGH.data.(char(handles.datanames(1))).GFP(:,:,1));

% Set sliders
numOfSlices = size(handles.MGH.data.(char(handles.datanames(1))).GFP,3);
numOfData = size(handles.datanames,1);
set(handles.sliderSlice,...
    'Min',1,...
    'Max',numOfSlices,...
    'Value',1,...
    'SliderStep', [1 ,1]/(numOfSlices-1));
set(handles.sliderData,...
    'Min',1,...
    'Max',numOfData,...
    'Value',1,...
    'SliderStep', [1 ,1]/(numOfData-1));
    
    

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes Embryo_Orientation wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = Embryo_Orientation_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on slider movement.
function sliderData_Callback(hObject, eventdata, handles)
% hObject    handle to sliderData (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

datanum = round(get(hObject,'Value'));
slice = round(get(handles.sliderSlice,'Value'));
if get(handles.rbGFP,'Value')== 1
    axes(handles.axes1),imagesc(handles.MGH.data.(char(handles.datanames(datanum))).GFP(:,:,slice));
elseif get(handles.rbSeg,'Value')==1
    axes(handles.axes1),imagesc(handles.MGH.SegData.(char(handles.datanames(datanum))).landmark(:,:,slice));
end
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function sliderData_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sliderData (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function sliderSlice_Callback(hObject, eventdata, handles)
% hObject    handle to sliderSlice (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

datanum = round(get(handles.sliderData,'Value'));
slice = round(get(hObject,'Value'));
if get(handles.rbGFP,'Value')== 1
    axes(handles.axes1),imagesc(handles.MGH.data.(char(handles.datanames(datanum))).GFP(:,:,slice));
elseif get(handles.rbSeg,'Value')==1
    axes(handles.axes1),imagesc(handles.MGH.SegData.(char(handles.datanames(datanum))).landmark(:,:,slice));
end
guidata(hObject,handles);


% --- Executes during object creation, after setting all properties.
function sliderSlice_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sliderSlice (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on button press in rbGFP.
function rbGFP_Callback(hObject, eventdata, handles)
% hObject    handle to rbGFP (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

datanum = get(handles.sliderData,'Value');
slice = get(handles.sliderSlice,'Value');
value = get(handles.rbGFP,'Value');
if value == 1
    axes(handles.axes1),imagesc(handles.MGH.data.(char(handles.datanames(datanum))).GFP(:,:,slice));
end

guidata(hObject,handles);


% --- Executes on button press in rbSeg.
function rbSeg_Callback(hObject, eventdata, handles)
% hObject    handle to rbSeg (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of rbSeg

datanum = get(handles.sliderData,'Value');
slice = get(handles.sliderSlice,'Value');
value = get(handles.rbSeg,'Value');
if value == 1
    axes(handles.axes1),imagesc(handles.MGH.SegData.(char(handles.datanames(datanum))).landmark(:,:,slice));
end

guidata(hObject,handles);


% --- Executes when selected object is changed in bgImageType.
function bgImageType_SelectionChangedFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in bgImageType 
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

datanum = get(handles.sliderData,'Value');
slice = get(handles.sliderSlice,'Value');
value = get(handles.rbSeg,'Value');
if value == 1
    axes(handles.axes1),imagesc(handles.MGH.SegData.(char(handles.datanames(datanum))).landmark(:,:,slice));
end
