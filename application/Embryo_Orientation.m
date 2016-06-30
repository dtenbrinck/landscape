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

% Last Modified by GUIDE v2.5 30-Jun-2016 00:17:46

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

% Check if there is already a reference data set
if isfield(handles.MGH,'nRefData')
    handles.nRefData = handles.MGH.nRefData;
else
    handles.nRefData = 1;
end

fieldNames = fieldnames(handles.MGH.data); 
set(handles.textRef,'String',char(fieldNames(handles.nRefData)));
    

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


% --- Executes when selected object is changed in bgImageType.
function bgImageType_SelectionChangedFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in bgImageType 
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

datanum = get(handles.sliderData,'Value');
slice = get(handles.sliderSlice,'Value');

if get(handles.rbSeg,'Value')
    axes(handles.axes1),imagesc(handles.MGH.SegData.(char(handles.datanames(datanum))).landmark(:,:,slice));
elseif get(handles.rbGFP,'Value')
    axes(handles.axes1),imagesc(handles.MGH.data.(char(handles.datanames(datanum))).GFP(:,:,slice));
end


% --- Executes on button press in rbGFP.
function rbGFP_Callback(hObject, eventdata, handles)
% hObject    handle to rbGFP (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of rbGFP


% --- Executes on button press in rbSeg.
function rbSeg_Callback(hObject, eventdata, handles)
% hObject    handle to rbSeg (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of rbSeg


% --- Executes on button press in btnFlip.
function btnFlip_Callback(hObject, eventdata, handles)
% hObject    handle to btnFlip (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

datanum = get(handles.sliderData,'Value');
slice = get(handles.sliderSlice,'Value');

% Flip from left to right
handles.MGH.data.(char(handles.datanames(datanum))).GFP ...
    = fliplr(handles.MGH.data.(char(handles.datanames(datanum))).GFP);
handles.MGH.data.(char(handles.datanames(datanum))).Dapi ...
    = fliplr(handles.MGH.data.(char(handles.datanames(datanum))).Dapi);
handles.MGH.data.(char(handles.datanames(datanum))).mCherry ...
    = fliplr(handles.MGH.data.(char(handles.datanames(datanum))).mCherry);
handles.MGH.SegData.(char(handles.datanames(datanum))).landmark ...
    = fliplr(handles.MGH.SegData.(char(handles.datanames(datanum))).landmark);

% Update axes
if get(handles.rbSeg,'Value')
    axes(handles.axes1),imagesc(handles.MGH.SegData.(char(handles.datanames(datanum))).landmark(:,:,slice));
elseif get(handles.rbGFP,'Value')
    axes(handles.axes1),imagesc(handles.MGH.data.(char(handles.datanames(datanum))).GFP(:,:,slice));
end

guidata(hObject,handles);


% --- Executes on button press in btnNext.
function btnNext_Callback(hObject, eventdata, handles)
% hObject    handle to btnNext (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

slice = get(handles.sliderSlice,'Value');
datanum = get(handles.sliderData,'Value');
plusone = datanum+1;
if plusone <= size(handles.datanames,1)
    set(handles.sliderData,'Value',get(handles.sliderData,'Value')+1);
    % Update axes
    if get(handles.rbSeg,'Value')
        axes(handles.axes1),imagesc(handles.MGH.SegData.(char(handles.datanames(plusone))).landmark(:,:,slice));
    elseif get(handles.rbGFP,'Value')
        axes(handles.axes1),imagesc(handles.MGH.data.(char(handles.datanames(plusone))).GFP(:,:,slice));
    end
end

guidata(hObject,handles);


% --- Executes on button press in btnSave.
function btnSave_Callback(hObject, eventdata, handles)
% hObject    handle to btnSave (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
h = findobj('Name','Embryo Registration');
handles.MGH.nRefData = handles.nRefData;
guidata(h,handles.MGH)
close

% --- Executes on button press in btnDiscard.
function btnDiscard_Callback(hObject, eventdata, handles)
% hObject    handle to btnDiscard (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
close;


% --- Executes on button press in btnRef.
function btnRef_Callback(hObject, eventdata, handles)
% hObject    handle to btnRef (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.nRefData = get(handles.sliderData,'Value');
fieldNames = fieldnames(handles.MGH.data);
set(handles.textRef,'String',char(fieldNames(handles.nRefData)));

guidata(hObject,handles);

% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over btnRef.
function btnRef_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to btnRef (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
