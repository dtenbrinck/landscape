function varargout = Embryo_Projected(varargin)
% EMBRYO_PROJECTED MATLAB code for Embryo_Projected.fig
%      EMBRYO_PROJECTED, by itself, creates a new EMBRYO_PROJECTED or raises the existing
%      singleton*.
%
%      H = EMBRYO_PROJECTED returns the handle to a new EMBRYO_PROJECTED or the handle to
%      the existing singleton*.
%
%      EMBRYO_PROJECTED('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in EMBRYO_PROJECTED.M with the given input arguments.
%
%      EMBRYO_PROJECTED('Property','Value',...) creates a new EMBRYO_PROJECTED or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Embryo_Projected_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Embryo_Projected_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help Embryo_Projected

% Last Modified by GUIDE v2.5 30-Jun-2016 22:01:29

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Embryo_Projected_OpeningFcn, ...
                   'gui_OutputFcn',  @Embryo_Projected_OutputFcn, ...
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


% --- Executes just before Embryo_Projected is made visible.
function Embryo_Projected_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Embryo_Projected (see VARARGIN)

% Choose default command line output for Embryo_Projected
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes Embryo_Projected wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = Embryo_Projected_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
