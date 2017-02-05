function varargout = TheSlider(varargin)
% THESLIDER MATLAB code for TheSlider.fig
%      THESLIDER, by itself, creates a new THESLIDER or raises the existing
%      singleton*.
%
%      H = THESLIDER returns the handle to a new THESLIDER or the handle to
%      the existing singleton*.
%
%      THESLIDER('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in THESLIDER.M with the given input arguments.
%
%      THESLIDER('Property','Value',...) creates a new THESLIDER or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before TheSlider_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to TheSlider_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help TheSlider

% Last Modified by GUIDE v2.5 03-Nov-2016 01:06:41

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @TheSlider_OpeningFcn, ...
                   'gui_OutputFcn',  @TheSlider_OutputFcn, ...
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
end

% --- Executes just before TheSlider is made visible.
function TheSlider_OpeningFcn(hObject, eventdata, h, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to TheSlider (see VARARGIN)

% Choose default command line output for TheSlider
h.output = hObject;

% Update handles structure
guidata(hObject, h);
% Get inputs
h.p = varargin{1,1};
h.option = varargin{1,2};
h.accumulator = varargin{1,3};
h.convAcc = varargin{1,4};
h.numOfAllCells = varargin{1,5};
h.numberOfResults = varargin{1,6};
h.sizeGrid = h.p.gridSize;
% Set the slice for each direction
h = setSliceTop(h,round(h.p.gridSize/2));
h = setSliceSide(h,round(h.p.gridSize/2));
h = setSliceHead(h,round(h.p.gridSize/2));
set3DSlices(h);
guidata(hObject,h);
% UIWAIT makes TheSlider wait for user response (see UIRESUME)
% uiwait(handles.figure1);
end

% --- Outputs from this function are returned to the command line.
function varargout = TheSlider_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;
end

% - Sub Functions - %

function h = setSliceTop(h,sliceNumber)
h.sliceNumTop = sliceNumber;
h.sliceTop = h.convAcc(:,:,sliceNumber);
colormap(h.axTop,jet(256));
imagesc(h.axTop,h.sliceTop);

xlabel(h.axTop,'Head \leftarrow \rightarrow Tail','FontSize',13);
ylabel(h.axTop,'Right \leftarrow \rightarrow Left','FontSize',13);
set(h.axTop,'xtick',[],'ytick',[])
drawnow;
end

function h = setSliceSide(h,sliceNumber)
h.sliceNumSide = sliceNumber;
h.sliceSide = reshape(h.convAcc(:,sliceNumber,:),[h.sizeGrid,h.sizeGrid]);
imagesc(h.axSide,h.sliceSide);
mycolorbar = jet(256);
colormap(h.axSide,mycolorbar);
ylabel(h.axSide,'Bottom \leftarrow \rightarrow Top','FontSize',13);
xlabel(h.axSide,'Left \leftarrow \rightarrow Right','FontSize',13);
set(h.axSide,'xtick',[],'ytick',[])
drawnow;
end

function h = setSliceHead(h,sliceNumber)
h.sliceNumHead = sliceNumber;
h.sliceHead = reshape(h.convAcc(sliceNumber,:,:),[h.sizeGrid,h.sizeGrid]);
imagesc(h.axHead,h.sliceHead);
mcm = jet(256);
colormap(h.axHead,mcm);
ylabel(h.axHead,'Bottom \leftarrow \rightarrow Top','FontSize',13);
xlabel(h.axHead,'Head \leftarrow \rightarrow Tail','FontSize',13);
set(h.axHead,'xtick',[],'ytick',[])
drawnow;
end

function set3DSlices(h)
cla(h.ax3D);
hold(h.ax3D,'on')
surf(h.ax3D,ones(h.sizeGrid,h.sizeGrid)*h.sliceNumTop,h.sliceTop,'EdgeColor','None')
[x,z] = meshgrid(1:h.sizeGrid,1:h.sizeGrid);
y = h.sliceNumSide*ones(size(x));
surf(h.ax3D,x,y,z,h.sliceSide,'EdgeColor','None')
[y,z] = meshgrid(1:h.sizeGrid,1:h.sizeGrid);
x = h.sliceNumSide*ones(size(y));
surf(h.ax3D,x,y,z,h.sliceHead,'EdgeColor','None');
drawnow;
end

function drawCrosshair(h)
hold(h.axTop,'on');
plot(h.axTop,[1,h.sizeGrid],[h.sliceNumSide,h.sliceNumSide],'black');
plot(h.axTop,[h.sliceNumHead,h.sliceNumHead],[1,h.sizeGrid],'black');
hold(h.axTop,'off');

hold(h.axHead,'on');
plot(h.axHead,[1,h.sizeGrid],[h.sliceNumTop,h.sliceNumTop],'black');
plot(h.axHead,[h.sliceNumSide,h.sliceNumSide],[1,h.sizeGrid],'black');
hold(h.axHead,'off');

hold(h.axSide,'on');
plot(h.axSide,[1,h.sizeGrid],[h.sliceNumHead,h.sliceNumHead],'black');
plot(h.axSide,[h.sliceNumTop,h.sliceNumTop],[1,h.sizeGrid],'black');
hold(h.axSide,'off');

end


function edGridSize_Callback(hObject, eventdata, handles)
% hObject    handle to edGridSize (see GCBO)
% eventdata   reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edGridSize as text
%        str2double(get(hObject,'String')) returns contents of edGridSize as a double
get(hObject,'String');
end
% --- Executes during object creation, after setting all properties.
function edGridSize_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edGridSize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end


% --- Executes on button press in tbRotate.
function tbRotate_Callback(hObject, eventdata, h)
% hObject    handle to tbRotate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of tbRotate

if get(hObject,'Value')
    rotate3d(h.ax3D,'on');
else
    rotate3d(h.ax3D,'off');
end
end