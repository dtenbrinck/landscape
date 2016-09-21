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

% Last Modified by GUIDE v2.5 12-Jul-2016 17:51:56

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
handles.numOfSlices = numOfSlices;
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
txDataChange(handles.txDataOf,'Data_1');
txSliceChange(handles.txSliceOf,1,numOfSlices);

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes Embryo_Orientation wait for user response (see UIRESUME)
% uiwait(handles.figEmbrOrient);


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
txDataChange(handles.txDataOf,handles.datanames(datanum));
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
txSliceChange(handles.txSliceOf,slice,handles.numOfSlices);
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

datanum = round(get(handles.sliderData,'Value'));
slice = round(get(handles.sliderSlice,'Value'));

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

datanum = round(get(handles.sliderData,'Value'));
slice = round(get(handles.sliderSlice,'Value'));

% Flip from left to right
output = handles.MGH.SegData.(char(handles.datanames(datanum)));
handles.MGH.data.(char(handles.datanames(datanum))).GFP ...
    = rot90(handles.MGH.data.(char(handles.datanames(datanum))).GFP,2);
handles.MGH.data.(char(handles.datanames(datanum))).Dapi ...
    = rot90(handles.MGH.data.(char(handles.datanames(datanum))).Dapi,2);
handles.MGH.data.(char(handles.datanames(datanum))).mCherry ...
    = rot90(handles.MGH.data.(char(handles.datanames(datanum))).mCherry,2);
output.landmark ...
    = rot90(output.landmark,2);

% Flip cell coordinates
output.centCoords(1,:) = -output.centCoords(1,:);
output.centCoords(2,:) = -output.centCoords(2,:);

% Flip regression data
output.regData(1,:) = -output.regData(1,:);
output.regData(2,:) = -output.regData(2,:);

% Generate the flipped GPFOnSphere

samples = handles.MGH.samples;
[alpha, beta] = meshgrid(linspace(pi,pi*2,samples/2), linspace(0,2*pi,samples));
Zs = cos(alpha) .* sin(beta);
Xs = sin(alpha) .* sin(beta);
Ys = cos(beta);

% First change the rotationmatrix so that it fits the flipping

rotMat = output.ellipsoid.axes';
rotMat(2,1) = -rotMat(2,1);
rotMat(2,3) = -rotMat(2,3);
rotMat(1,2) = -rotMat(1,2);
rotMat(3,2) = -rotMat(3,2);

% Compute the new meshgrids
scaleMat = diag(1./output.ellipsoid.radii);
transform = scaleMat*rotMat;
% Transform all coordinates of the unit sphere
X = transform^-1*[Xs(:),Ys(:),Zs(:)]';

% Set the output and reshape it.
output.tSphere.Xs_t = reshape(X(1,:)+output.ellipsoid.center(1),size(Xs));
output.tSphere.Ys_t = reshape(X(2,:)+output.ellipsoid.center(2),size(Ys));
output.tSphere.Zs_t = reshape(X(3,:)+output.ellipsoid.center(3),size(Zs));

% Now generate the GRPOnSphere map

mind = [0 0 0]; maxd = size(output.landmark).*handles.MGH.resolution;
[ X, Y, Z ] = meshgrid( linspace( mind(2), maxd(2), size(output.landmark,2) ),...
        linspace( mind(1), maxd(1), size(output.landmark,1) ),...
        linspace( mind(3), maxd(3), size(output.landmark,3) ) );
    
output.GFPOnSphere ...
        = interp3(X, Y, Z, output.landmark, output.tSphere.Xs_t, output.tSphere.Ys_t, output.tSphere.Zs_t,'nearest');

    
handles.MGH.SegData.(char(handles.datanames(datanum))) = output;

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

slice = round(get(handles.sliderSlice,'Value'));
datanum = round(get(handles.sliderData,'Value'));
plusone = datanum+1;
if plusone <= size(handles.datanames,1)
    set(handles.sliderData,'Value',get(handles.sliderData,'Value')+1);
    % Update axes
    if get(handles.rbSeg,'Value')
        axes(handles.axes1),imagesc(handles.MGH.SegData.(char(handles.datanames(plusone))).landmark(:,:,slice));
    elseif get(handles.rbGFP,'Value')
        axes(handles.axes1),imagesc(handles.MGH.data.(char(handles.datanames(plusone))).GFP(:,:,slice));
    end
    txDataChange(handles.txDataOf,char(handles.datanames(plusone)));
end

txSliceChange(handles.txSliceOf,slice,handles.numOfSlices);
set(handles.axes1,'XTick','','YTick','');
guidata(hObject,handles);


% --- Executes on button press in btnSave.
function btnSave_Callback(hObject, eventdata, handles)
% hObject    handle to btnSave (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
h = findobj('Name','Embryo Registration');
handles.MGH.nRefData = handles.nRefData;
guidata(h,handles.MGH);
close;

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

handles.nRefData = round(get(handles.sliderData,'Value'));

if handles.masterRef == 1 && handles.nRefData == get(handles.sliderData,'Max')
    return;
end

fieldNames = fieldnames(handles.MGH.data);
set(handles.textRef,'String',char(fieldNames(handles.nRefData)));
if handles.masterRef == 1
    handles.masterRef = 0;
    handles.MGH.data = rmfield(handles.MGH.data,'Master_Ref');
    handles.MGH.SegData = rmfield(handles.MGH.SegData,'Master_Ref');
    handles.datanames = fieldnames(handles.MGH.data);
    
    % Update slider
    datanum = size(handles.datanames,1);
    set(handles.sliderData,...
        'Min',1,...
        'Max',datanum,...
        'Value',handles.nRefData,...
        'SliderStep', [1 ,1]/(datanum-1));
    
    numOfSlices = size(handles.MGH.data.(char(handles.datanames(1))).GFP,3);
    set(handles.sliderSlice,...
        'Min',1,...
        'Max',numOfSlices,...
        'Value',1,...
        'SliderStep', [1 ,1]/(numOfSlices-1));
    
    
    slice = 1;
    cla(handles.axes1);
    if get(handles.rbGFP,'Value')== 1
        axes(handles.axes1),imagesc(handles.MGH.data.(char(fieldNames(handles.nRefData))).GFP(:,:,slice));
    elseif get(handles.rbSeg,'Value')==1
        axes(handles.axes1),imagesc(handles.MGH.SegData.(char(fieldNames(handles.nRefData))).landmark(:,:,slice));
    end
    set(handles.axes1,'XTick','','YTick','');
    txDataChange(handles.txDataOf,char(fieldNames(handles.nRefData)));
    txSliceChange(handles.txSliceOf,1,handles.numOfSlices);
    
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

% Set default path
if exist('/4TB/data/SargonYigit/Image Registration/10hpf_data/ody data_10hpf_heatmap/potential master references_10hpf/','dir') == 7
    dataPath = '/4TB/data/SargonYigit/Image Registration/10hpf_data/ody data_10hpf_heatmap/potential master references_10hpf/*.stk';
elseif exist('E:/Embryo_Registration/data/SargonYigit/Image Registration/10hpf_data/ody data_10hpf_heatmap/potential master references_10hpf/','dir') == 7
    dataPath = 'E:/Embryo_Registration/data/SargonYigit/Image Registration/10hpf_data/ody data_10hpf_heatmap/potential master references_10hpf/*.stk';
end

[fileNames,pathName] = uigetfile(dataPath,'Please select the master reference files!','MultiSelect','on');
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
    dataName = 'Master_Ref';
    
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

close(wb1);

% Check if the master reference has the same amount of slices as the
% Dataset.

if size(data.Master_Ref.Dapi,3) > size(handles.MGH.data.Data_1.Dapi,3)
    choice = questdlg(['The master reference data has more slices than the corresponding data set.'...
        ,'Do you want to pick another master reference or just ignore it?'],'Too many slices',...
        'Repick','Ignore','Cancel','Cancel');
    switch choice
        case 'Repick'
            btnMasterRef_Callback(hObject,eventdata,handles);
        case 'Ignore'
            warning('Will delete the leftover slices of the master reference...');
            data.Master_Ref.Dapi ...
                = data.Master_Ref.Dapi(:,:,size(handles.MGH.data.Data_1.Dapi,3));
            data.Master_Ref.GFP ...
                = data.Master_Ref.GFP(:,:,size(handles.MGH.data.Data_1.Dapi,3));
            data.Master_Ref.mCherry ...
                = data.Master_Ref.mCherry(:,:,size(handles.MGH.data.Data_1.Dapi,3));
        case 'Cancel'
            return;
    end
elseif size(data.Master_Ref.Dapi,3) < size(handles.MGH.data.Data_1.Dapi,3)
    choice = questdlg(['The master reference data has less slices than the corresponding data set.'...
        ,'Do you want to pick another master reference or just ignore it?'],'Insufficient slices',...
        'Repick','Ignore','Cancel','Cancel');
    switch choice
        case 'Repick'
            btnMasterRef_Callback(hObject,eventdata,handles);
        case 'Ignore'
            diff = size(handles.MGH.data.Data_1.Dapi,3)-size(data.Master_Ref.Dapi,3);
            warning('Will add zero-slices at the end of the master reference data set...');
            data.Master_Ref.Dapi ...
                = padarray(data.Master_Ref.Dapi,[0,0,diff],'replicate','post');
            data.Master_Ref.GFP ...
                = padarray(data.Master_Ref.GFP,[0,0,diff],'replicate','post');
            data.Master_Ref.mCherry ...
                = padarray(data.Master_Ref.mCherry,[0,0,diff],'replicate','post');
        case 'Cancel'
            return;
    end
end

% Do segmentation

fprintf('Starting segmentation...');

samples = handles.MGH.samples;

% Sample the unit sphere
[alpha, beta] = meshgrid(linspace(pi,2*pi,samples/2), linspace(0,2*pi,samples));
Zs = cos(alpha) .* sin(beta);
Xs = sin(alpha) .* sin(beta);
Ys = cos(beta);

% Sample the unit cube
[Xc, Yc, Zc] = meshgrid(linspace(-1,1,samples), linspace(-1,1,samples), linspace(-1,1,samples));
segDataRef = genSegDataGUI(Xs,Ys,Zs,Xc,Yc,Zc,data,handles.MGH.resolution,handles.MGH.scale);



% Work it into the handles structure
handles.MGH.SegData.Master_Ref = segDataRef.Master_Ref;
handles.MGH.data.Master_Ref = data.Master_Ref;
set(handles.textRef,'String','Master_Ref');

handles.masterRef = 1;
if isempty(find(~cellfun(@isempty,strfind((handles.datanames),'Master_Ref')),1))
    handles.nRefData = size(handles.datanames,1)+1;
end

slice = 1;
if get(handles.rbGFP,'Value')== 1
    axes(handles.axes1),imagesc(handles.MGH.data.Master_Ref.GFP(:,:,slice));
elseif get(handles.rbSeg,'Value')==1
    axes(handles.axes1),imagesc(handles.MGH.SegData.Master_Ref.landmark(:,:,slice));
end
set(handles.axes1,'XTick','','YTick','');
handles.datanames = fieldnames(handles.MGH.data);
txDataChange(handles.txDataOf,'Master_Ref');
txSliceChange(handles.txSliceOf,slice,handles.numOfSlices);

% Update slider
set(handles.sliderData,...
    'Min',1,...
    'Max',handles.nRefData,...
    'Value',handles.nRefData,...
    'SliderStep', [1 ,1]/(size(handles.datanames,1)));

numOfSlices = size(handles.MGH.data.(char(handles.datanames(1))).GFP,3);
set(handles.sliderSlice,...
    'Min',1,...
    'Max',numOfSlices,...
    'Value',1,...
    'SliderStep', [1 ,1]/(numOfSlices-1));

guidata(hObject,handles);


% ---- OTHER FUNCTIONS ---- %
function d = showProcessing(h)
% Positioning it into the middle of the figure
posFig = get(h.figEmbrOrient,'Position');

posDiag = [posFig(1)+posFig(3)/2-20, posFig(2)+posFig(4)/2-3, 40, 10];
d = dialog('Units','characters','Position',round(posDiag),'Name','Wait');
uicontrol('Parent',d,...
    'Units','normalized',...
    'Style','text',...
    'Position',[0 0 01 0.6],...
    'String','Computing the segmentation...');

drawnow

function txDataChange(txObj,dataName)
set(txObj,'String',dataName)
drawnow

function txSliceChange(txObj,slice,total)
set(txObj,'String',['Slice ',num2str(slice),' of ',num2str(total)]);
