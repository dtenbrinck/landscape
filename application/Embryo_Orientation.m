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

% Last Modified by GUIDE v2.5 11-Jul-2016 16:54:36

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

% No master ref selected.

handles.masterRef = 0;

% Get names of the Data fields
handles.datanames = fieldnames(handles.MGH.data);

% Set axes
axes(handles.axes1), imagesc(handles.MGH.data.(char(handles.datanames(1))).GFP(:,:,1));
set(handles.axes1,'XTick','','YTick','');
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
set(handles.axes1,'XTick','','YTick','');
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
set(handles.axes1,'XTick','','YTick','');
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
set(handles.axes1,'XTick','','YTick','');
drawnow


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
set(handles.axes1,'XTick','','YTick','');
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
set(handles.axes1,'XTick','','YTick','');
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
if handles.masterRef == 1
    handles.masterRef = 0;
    handles.MGH.data = rmfield(handles.MGH.data,'Data_Ref');
end
guidata(hObject,handles);

% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over btnRef.
function btnRef_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to btnRef (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in btnMasterRef.
function btnMasterRef_Callback(hObject, eventdata, handles)
% hObject    handle to btnMasterRef (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Open up file browser

if handles.masterRef == 1
   choice = questdlg('You have already added a Master Reference. Do you pick another?','Repick','Yes','No','Yes');
   switch choice
       case 'Yes'
           handles.data = [];
       case 'No'
           return
   end   
end

[fileNames,pathName] = uigetfile('*.stk','Please select the master reference files!','MultiSelect','on');
fileNames = fileNames';
% Check if there is the correct size of data and all types of channels
% selected

if size(fileNames,1) == 3
    
    % Check for correct experiment
    indices = strfind(fileNames,'_');
    expNum = [0;0;0];
    for i=1:3
        expNum(i) = str2double(strtok(...
            fileNames{i}(indices{i,1}((size(indices{i,1},2)-1))+1:indices{i,1}((size(indices{i,1},2)-1))+2),'_'));
    end
    expNum = unique(expNum);
    if size(expNum,1)>1
        errordlg('You have selected data from different experiments! Please repick!');
        return;
    end
    
    % Check for correct channels
    stkFiles = cell(1,3);
    
    % Find Dapi
    index = strfind(fileNames,'Dapi');
    rightind = find(~cellfun(@isempty,index));
    if ~isempty(rightind) && size(rightind,1) == 1
        stkFiles{i,1} = fileNames(rightind);
    elseif isempty(rightind)
        errordlg('You have selected no Dapi channel! Please repick files!');
        return;
    elseif size(rightind,1) ~= 1
        errordlg('You have selected more than one Dapi channel! Please repick files!');
        return;
    end
    
    % Find GFP
    index = strfind(fileNames,'GFP');
    rightind = find(~cellfun(@isempty,index));
    if ~isempty(rightind) && size(rightind,1) == 1
        stkFiles{i,2} = fileNames(rightind);
    elseif isempty(rightind)
        errordlg('You have selected no GFP channel! Please repick files!');
        return;
    elseif size(rightind,1) ~= 1
        errordlg('You have selected more than one GFP channel! Please repick files!');
        return;
    end
    
    % Find mCherry
    index = strfind(fileNames,'mCherry');
    rightind = find(~cellfun(@isempty,index));
    if ~isempty(rightind) && size(rightind,1) == 1
        stkFiles{i,3} = fileNames(rightind);
    elseif isempty(rightind)
        errordlg('You have selected no mCherry channel! Please repick files!');
        return;
    elseif size(rightind,1) ~= 1
        errordlg('You have selected more than one mCherry channel! Please repick files!');
        return;
    end
else
    errordlg('You need to select 3 files! One for each channel!');
    return;
end

% Load data

% Create waitbar
wb1=waitbar(0, 'Loading selected data... Please wait...');
set(findobj(wb1,'type','patch'),'edgecolor','k','facecolor','b');

data = struct;
try
    dataName = 'Data_Ref';
    
    % Load Dapi
    data.(dataName) = [];
    pathFile = [pathName,'\',char(stkFiles{i,1})];
    TIFF = tiffread(pathFile);
    % Set x_resolution
    xres = TIFF.('x_resolution');
    yres = TIFF.('y_resolution');
    height = TIFF.('height');
    width = TIFF.('width');
    data.(dataName).x_resolution = xres(1);
    data.(dataName).y_resolution = yres(1);
    data.(dataName).Dapi ...
        = double(reshape(cell2mat({TIFF(:).('data')}),height,width,size(TIFF,2)));
    waitbar(1/3);
    % Load GFP
    pathFile = [pathName,'\',char(stkFiles{i,2})];
    TIFF = tiffread(pathFile);
    data.(dataName).GFP ...
        = double(reshape(cell2mat({TIFF(:).('data')}),height,width,size(TIFF,2)));
    waitbar(2/3);
    % Load mCherry
    pathFile = [pathName,'\',char(stkFiles{i,3})];
    TIFF = tiffread(pathFile);
    data.(dataName).mCherry ...
        = double(reshape(cell2mat({TIFF(:).('data')}),height,width,size(TIFF,2)));
    waitbar(3/3);
catch ME
    
    warning(['Some error occured while reading the TIFF file!', ...
        '\n this file will be skipped!\n The error',...
        ' message was: ',ME.message]);
    rmfield(data,dataName);
    return;
end

% Work it into the handles structure

handles.MGH.data.Data_Ref = data.Data_Ref;
set(handles.textRef,'String','Data_Ref');
close(wb1);
handles.masterRef = 1;

% UPDATE THE SLIDER!!!
guidata(hObject,handles);