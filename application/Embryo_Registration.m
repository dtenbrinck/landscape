function varargout = Embryo_Registration(varargin)
% EMBRYO_REGISTRATION MATLAB code for Embryo_Registration.fig
%      EMBRYO_REGISTRATION, by itself, creates a new EMBRYO_REGISTRATION or raises the existing
%      singleton*.
%
%      H = EMBRYO_REGISTRATION returns the handle to a new EMBRYO_REGISTRATION or the handle to
%      the existing singleton*.
%
%      EMBRYO_REGISTRATION('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in EMBRYO_REGISTRATION.M with the given input arguments.
%
%      EMBRYO_REGISTRATION('Property','Value',...) creates a new EMBRYO_REGISTRATION or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Embryo_Registration_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Embryo_Registration_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help Embryo_Registration

% Last Modified by GUIDE v2.5 30-Jun-2016 22:44:40

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @Embryo_Registration_OpeningFcn, ...
    'gui_OutputFcn',  @Embryo_Registration_OutputFcn, ...
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

% --- Executes just before Embryo_Registration is made visible.
function Embryo_Registration_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Embryo_Registration (see VARARGIN)

% Choose default command line output for Embryo_Registration
handles.output = hObject;

% Initialization %

% Visualize
handles.vis_regist = true;
handles.vis_regr = 'true';

% Set rescaling factor
handles.scale = 0.75;

% Set resolution for data in micrometers (given by biologists)
handles.resolution = [1.29/handles.scale, 1.29/handles.scale, 20];

% Set the sample rate (will be changeable for user later)
handles.samples = 256;

% Set Buttons
set(handles.textField,'String','Welcome! Please load your data.');
set(handles.start_seg,'Enable','off');
set(handles.btnOrientation,'Enable','off');
set(handles.btnReg,'Enable','off');
set(handles.btnHeat,'Enable','off');

% Set default reference data
handles.nRefData = 1;

% Set default visualization
handles.vis_regist = 0;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes Embryo_Registration wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = Embryo_Registration_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

% --- Executes on button press in Load.
function Load_Callback(hObject, eventdata, handles)
% hObject    handle to Load (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% TODO: Encapsulate loading functions to separate io and GUI

handles = guidata(hObject);

% Check if there is already data loaded
if isfield(handles,'data');
    choice = questdlg('You have already loaded data. Do you want to load again?','Reload','Yes','No','Yes');
    switch choice
        case 'Yes'
            handles.data = [];
        case 'No'
            return
    end
end

% set default search path for data
if exist('/4TB/data/SargonYigit/','dir') == 7
    dataPath = '/4TB/data/SargonYigit/';
elseif exist('E:/Embryo_Registration/data/SargonYigit/','dir') == 7
    dataPath = 'E:/Embryo_Registration/data/SargonYigit/';
else % in case the above folders don't exist take the current directory
    dataPath = './data';
end

% get path to selected folder
pathName = uigetdir(dataPath,'Please select a folder with the data!');
handles.PathName = pathName;

% get filenames of STK files in selected folder
fileNames = getSTKfilenames( pathName );

% check if any stk files have been found in selected folder
if size(fileNames,1) == 0
    errordlg('No data selected.');
    set(handles.textField,'String','Failed to load data. Please try again.');
    return;
end

% Give output and create waitbar for loading files
disp('Loading data...');
set(handles.textField,'String','Loading data...');
wb1=waitbar(0, 'Loading selected data... Please wait...');
set(findobj(wb1,'type','patch'),'edgecolor','k','facecolor','b');

% extract only valid experiments with three data sets
experimentSets = checkExperimentChannels(fileNames);

% load data for each experiment
data = loadExperimentData(experimentSets, pathName, wb1);

% close waitbar when finished
close(wb1);

% Update handles
handles.filenames = fileNames;
handles.nRefData = 1;
handles.data = data;
set(handles.textField,'String','Data loaded.');
set(handles.start_seg,'Enable','on');
guidata(hObject,handles);

% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over Load.
function Load_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to Load (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in start_seg.
function start_seg_Callback(hObject, eventdata, handles)
% hObject    handle to start_seg (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles = guidata(hObject);

set(handles.textField,'String','Starting segmentation...');

samples = handles.samples;

% Sample the unit sphere
[alpha, beta] = meshgrid(linspace(pi,2*pi,samples/2), linspace(0,2*pi,samples));
Zs = cos(alpha) .* sin(beta);
Xs = sin(alpha) .* sin(beta);
Ys = cos(beta);

% Sample the unit cube
[Xc, Yc, Zc] = meshgrid(linspace(-1,1,samples), linspace(-1,1,samples), linspace(-1,1,samples));
handles.SegData = genSegDataGUI(Xs,Ys,Zs,Xc,Yc,Zc,handles.data,samples,handles.resolution,handles.scale);

set(handles.textField,'String','Segmentation Done!');
set(handles.start_seg,'Enable','off');
set(handles.btnOrientation,'Enable','on');
set(handles.btnReg,'Enable','on');

guidata(hObject,handles);



function editSamples_Callback(hObject, eventdata, handles)
% hObject    handle to editSamples (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editSamples as text
%        str2double(get(hObject,'String')) returns contents of editSamples as a double

handles = guidata(hObject);
handles.samples = str2double(get(hObject,'String'));
set(hObject,'Value',handles.samples);

guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function editSamples_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editSamples (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in btnOrientation.
function btnOrientation_Callback(hObject, eventdata, handles)
% hObject    handle to btnOrientation (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

Embryo_Orientation(handles);

guidata(hObject,handles);


% --- Executes on button press in btnReg.
function btnReg_Callback(hObject, eventdata, handles)
% hObject    handle to btnReg (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles = compRegistrationGUI(handles);
set(handles.btnHeat,'Enable','on');

guidata(hObject,handles);

% --- Executes on button press in cbShowReg.
function cbShowReg_Callback(hObject, eventdata, handles)
% hObject    handle to cbShowReg (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of cbShowReg
if get(hObject,'Value')
    handles.vis_regist = 1;
else
    handles.vis_regist = 0;
end
guidata(hObject,handles);


% --- Executes on button press in btnHeat.
function btnHeat_Callback(hObject, eventdata, handles)
% hObject    handle to btnHeat (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

Embryo_Heatmap(handles);

guidata(hObject,handles);
