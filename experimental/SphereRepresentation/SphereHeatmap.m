function varargout = SphereHeatmap(varargin)
% SPHEREHEATMAP MATLAB code for SphereHeatmap.fig
%      SPHEREHEATMAP, by itself, creates a new SPHEREHEATMAP or raises the
%      existingErez
%      singleton*.
%
%      H = SPHEREHEATMAP returns the handle to a new SPHEREHEATMAP or the handle to
%      the existing singleton*.
%
%      SPHEREHEATMAP('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SPHEREHEATMAP.M with the given input arguments.
%
%      SPHEREHEATMAP('Property','Value',...) creates a new SPHEREHEATMAP or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before SphereHeatmap_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to SphereHeatmap_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help SphereHeatmap

% Last Modified by GUIDE v2.5 12-Mar-2017 13:27:17

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @SphereHeatmap_OpeningFcn, ...
    'gui_OutputFcn',  @SphereHeatmap_OutputFcn, ...
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


% --- Executes just before SphereHeatmap is made visible.
function SphereHeatmap_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to SphereHeatmap (see VARARGIN)

% Choose default command line output for SphereHeatmap
handles.output = hObject;
% Display loading function
% set default search path for data
if exist('/4TB/data/SargonYigit/','dir') == 7
    dataPath = '/media/piradmin/4TB/data/Landscape/Static';
elseif exist('E:/Embryo_Registration/data/SargonYigit/','dir') == 7
    dataPath = 'E:/Embryo_Registration/data/SargonYigit/';
else % in case the above folders don't exist take the current directory
    dataPath = '/home/fjedor/Uni/Sciebo/Uni/SHK/SphereRepresentation/data';
end
% path = uigetdir(dataPath,'Please select a accepted results folder to generate spherical heatmap!');
path = '/media/piradmin/4TB/data/Landscape/Static/ody/10hpf/raw_data/pooled_data_sets/Results_AP_oriented_criteria_minimum_1_PGC_detected_all_601_embryos/accepted';
% path = '/media/piradmin/4TB/data/Landscape/Static/ody/10hpf/raw_data/pooled_data_sets/Results_AP_oriented_criteria_minimum_1_PGC_870_datasets_20170412/accepted';
%--  GET FILES TO PROCESS -- %

% Get filenames of MAT files in selected folder
fileNames = getMATfilenames(path);
fileNames(find(strcmp(fileNames,'ParameterProcessing.mat'))) = [];
fileNames(find(strcmp(fileNames,'ParameterHeatmap.mat'))) = [];
fileNames(find(strcmp(fileNames,'HeatmapAccumulator.mat'))) = [];

% Get number of experiments
numberOfResults = size(fileNames,1);
handles.numOfRes = numberOfResults;
% Check if any results have been found

% Get all cell coordinates
handles.cellCoords = getAllValidCellCoords_woAcc(fileNames,numberOfResults,0.1,path)';

% SET IT ON WHEN THE CONVOLUTION IS WORKING IN SOME WAY
set(handles.upConv,'Visible','off')
% Mouse over function
set(findobj('Name','SphereHeatmap(Prototype)'),'windowbuttonmotionfcn',@mousemove);

% Set Defaults-

% Set default sampling
handles.sampling = 100;
handles.samp2D = 200;


set(handles.edSampling,'Value',handles.sampling,'String',num2str(handles.sampling));
% Set the sampling points
[handles.xs,handles.ys,handles.zs] = sphere(handles.sampling);

% Set default convolution size
handles.convSize=3;
set(handles.edConvSize,'Value',handles.convSize,'String',num2str(handles.convSize));

% Set shell defaults
handles.minShellValue = 0.6;
handles.maxShellValue = 1;
set(handles.minShell,'Value',handles.minShellValue,'String',num2str(handles.minShellValue));
set(handles.maxShell,'Value',handles.maxShellValue,'String',num2str(handles.maxShellValue));
ableConv(handles);

% -- Compute main results for visualization -- %

% Flip z coordinate
handles.cellCoords(:,3) = -handles.cellCoords(:,3);

% Coordinates for 2D heatmap
handles = evaluateFor2Dheatmap(handles);


% Sample cells
[handles.sampledCells, handles.sampledCounts, handles.sampledIndices] = ...
    sampleCells(handles.cellCoords, handles.xs, handles.ys, handles.zs, ...
    [handles.maxShellValue,handles.minShellValue]);
% Set Colors
handles = samplePointsColor(handles);
% Visualize
visualization(handles);
% Update handles structure
guidata(hObject, handles);


% UIWAIT makes SphereHeatmap wait for user response (see UIRESUME)
% uiwait(handles.figure1);


%% -- GENERAL FUNCTIONS -- %%

function handles = evaluateFor2Dheatmap(handles)
cellRad = 7;
handles.cellCoordsHM = handles.cellCoords;
handles.cellCoordsHM(:,3) = -handles.cellCoordsHM(:,3);
%Throw all points that are outside of the shells aways
normCellCoords = sqrt(sum(handles.cellCoords.^2,2));
handles.cellCoordsHM((normCellCoords > handles.maxShellValue|normCellCoords < handles.minShellValue),:)=[];
handles.cellCoordsHM = round((handles.cellCoordsHM+1)/2*(handles.samp2D-1))+1;
handles.Accumulator = computeAccumulator(handles.cellCoordsHM',handles.samp2D);
handles.Accumulator = convolveAccumulator(handles.Accumulator,cellRad,2*cellRad+1);
% Compute heatmaps
handles.heatmaps = compHeatmaps(handles.Accumulator);



    function heatmaps = compHeatmaps(accumulator)
        heatmaps.MIP.Top = max(accumulator,[],3);
        heatmaps.MIP.Head = reshape(max(accumulator,[],2),[size(accumulator,1),size(accumulator,3)]);
        heatmaps.MIP.Side = reshape(max(accumulator,[],1),[size(accumulator,2),size(accumulator,3)]);
        heatmaps.SUM.Top = sum(accumulator,3);
        heatmaps.SUM.Head = reshape(sum(accumulator,2),[size(accumulator,1),size(accumulator,3)]);
        heatmaps.SUM.Side = reshape(sum(accumulator,1),[size(accumulator,2),size(accumulator,3)]);
    


function handles = doConvolution(handles)
handles =  samplePointsColor(handles);

if handles.rbGaussian.Value == 1
    kern = fspecial('gaussian',handles.convSize,0.5);
    kern = kern/max(kern(:));
    convmat = convn(padarray(handles.spc,[(size(kern,1)-1)/2,(size(kern,1)-1)/2],'circular'),kern,'same');
    handles.spc = convmat((size(kern,1)-1)/2+1:end-(size(kern,1)-1)/2,(size(kern,1)-1)/2+1:end-(size(kern,1)-1)/2);
elseif handles.rbCircular.Value == 1
    kern = fspecial('disk',(handles.convSize-1)/2);
    kern(kern>0) = kern(kern>0)./(kern(kern>0));
    convmat = convn(padarray(handles.spc,[(size(kern,1)-1)/2,(size(kern,1)-1)/2],'circular'),kern,'same');
    handles.spc = convmat((size(kern,1)-1)/2+1:end-(size(kern,1)-1)/2,(size(kern,1)-1)/2+1:end-(size(kern,1)-1)/2);
end
visualization(handles);

function handles = newSampling(handles)
% Compute the new sampling
if handles.rbSampNotEqui.Value == 1
    [handles.xs,handles.ys,handles.zs] = sphere(handles.sampling);
elseif handles.rbSampEqui.Value == 1
    NOfCells = (handles.sampling+1)^2;
    [handles.xs,handles.ys,handles.zs] = equidistSampledSphere(NOfCells,1);
end

% Sample the points onto sampling points
[handles.sampledCells, handles.sampledCounts, handles.sampledIndices] = ...
    sampleCells(handles.cellCoords, handles.xs, handles.ys, handles.zs, ...
    [handles.maxShellValue,handles.minShellValue]);
handles =  samplePointsColor(handles);

visualization(handles);

function mousemove(hObject,eventdata)
% CB %
h_axes = findobj(get(findobj('Name','SphereHeatmap(Prototype)'),'Children'),'Tag','cbAxis');
l1 = findobj(get(findobj('Name','SphereHeatmap(Prototype)'),'Children'),'Tag','line1');
delete(l1);
C = get(h_axes,'currentpoint');
if iscell(C)
    C = C{1,1};
end

cb = findobj(hObject.Children,'Type','Colorbar');
xlim = h_axes.XLim;
ylim = h_axes.YLim;
outX = ~any(diff([xlim(1) C(1,1) xlim(2)])<0);
outY = ~any(diff([ylim(1) C(1,2) ylim(2)])<0);
if outX&outY
    level = C(1,2);
    l1 = line([xlim(1),xlim(2)], level*[1 1], 'color', 'black', 'parent', h_axes,'ButtonDownFcn',@btndown);
    set(l1,'Tag','line1');
else
    
end

% ROTATION %
handles = guidata(hObject);
C = get(handles.axes,'currentpoint');
if iscell(C)
    C = C{:,2,1};
end
xlim = get(handles.axes,'xlim');
ylim = get(handles.axes,'ylim');
outX = ~any(diff([xlim(1) C(1,1) xlim(2)])<0);
outY = ~any(diff([ylim(1) C(1,2) ylim(2)])<0);
if outX&outY
    rotate3d on
else
    rotate3d off
end

function handles =  samplePointsColor(handles)
handles.spc = zeros(size(handles.xs));
handles.spc(handles.sampledIndices) = handles.sampledCounts;


function ableConv(handles)
if handles.tbConv.Value == 0
    set(handles.edConvSize,'enable','off')
    set(handles.rbGaussian,'enable','off')
    set(handles.rbCircular,'enable','off')
else
    set(handles.edConvSize,'enable','on')
    set(handles.rbGaussian,'enable','on')
    set(handles.rbCircular,'enable','on')
end


function handles = updateFigure2DHM(handles)
    
numOfAllCells = size(handles.cellCoords,1);
delete(findobj('Tag','f2'));
handles.f2 =  copyobj(creatStdFigure_scaled(handles.numOfRes,numOfAllCells...
    ,handles.heatmaps,'MIP'),0); 
set(handles.f2,'Visible','on','Tag','f2');    
    
delete(findobj('Tag','f3'));
handles.f3 = copyobj(creatStdFigure_unscaled(handles.numOfRes,numOfAllCells...
    ,handles.heatmaps,'MIP'),0); 
set(handles.f3,'Visible','on','Tag','f3');

delete(findobj('Tag','f4'));
handles.f4 = copyobj(creatStdFigure_scaled(handles.numOfRes,numOfAllCells...
    ,handles.heatmaps,'SUM'),0);      
set(handles.f4,'Visible','on','Tag','f4');    
        
delete(findobj('Tag','f5'));
handles.f5 = copyobj(creatStdFigure_unscaled(handles.numOfRes,numOfAllCells...
    ,handles.heatmaps,'SUM'),0); 
set(handles.f5,'Visible','on','Tag','f5');




function visualization(handles)
cla(handles.axes);
if isfield(handles,'cellCoords')
handles = evaluateFor2Dheatmap(handles);
handles = updateFigure2DHM(handles);
end
hold(handles.axes,'on');
% Visualize sphere
if handles.tbSphere.Value == 1
    [X,Y,Z] = sphere(handles.sampling);
    surf(handles.axes,X,Y,Z,...
        'FaceColor','blue','EdgeColor','none','FaceAlpha',0.3),
end



% Visualize shape of embryo
if handles.tbShapeEmb.Value == 1
    
end

% Visualize zeros
lines = findobj('Tag','setline');
if handles.tbVisZeros.Value == 1
    % Ignore outsiders
    if handles.tbIgnore.Value == 1
        if size(lines,1) == 0
            disp('You need to set an interval on the colorbar first.');
        elseif size(lines,1) == 1
            maxlevel = lines.Ydata(2);
            minlevel = 0;
            scatter3(handles.axes,handles.xs(handles.spc>minlevel),...
            handles.ys(handles.spc>minlevel),...
            handles.zs(handles.spc>minlevel),...
            20,handles.spc(:),'filled');
        elseif size(lines,1) == 2
            [minlevel,~] = min([lines(1).YData(2),lines(2).YData(2)]);
            [maxlevel,~] = max([lines(1).YData(2),lines(2).YData(2)]);
            scatter3(handles.axes,handles.xs(handles.spc>minlevel),...
                handles.ys(handles.spc>minlevel),...
                handles.zs(handles.spc>minlevel),...
                20,handles.spc(:),'filled');
        end
    else
        scatter3(handles.axes,handles.xs(:),handles.ys(:),handles.zs(:),...
            20,handles.spc(:),'filled');
    end
elseif handles.tbVisZeros.Value == 0
    % Get the min level that is set on CB
    if handles.tbIgnore.Value == 1
        if size(lines,1) == 0
            disp('You need to set an interval on the colorbar first.');
        elseif size(lines,1) == 1
            maxlevel = lines.Ydata(2);
            minlevel = 0;
            xs1 = handles.xs(handles.spc>minlevel&handles.spc<maxlevel);
            ys1 = handles.ys(handles.spc>minlevel&handles.spc<maxlevel);
            zs1 = handles.zs(handles.spc>minlevel&handles.spc<maxlevel);
            if ~isempty(xs1+ys1+zs1)
                scatter3(handles.axes,xs1,ys1,zs1,20,handles.spc(:),'filled');
            end
        elseif size(lines,1) == 2
            [minlevel,~] = min([lines(1).YData(2),lines(2).YData(2)]);
            [maxlevel,~] = max([lines(1).YData(2),lines(2).YData(2)]);
            xs1 = handles.xs(handles.spc>minlevel&handles.spc<maxlevel);
            ys1 = handles.ys(handles.spc>minlevel&handles.spc<maxlevel);
            zs1 = handles.zs(handles.spc>minlevel&handles.spc<maxlevel);
            if ~isempty(xs1+ys1+zs1)
                scatter3(handles.axes,xs1,ys1,zs1,20,...
                    handles.spc(handles.spc>minlevel&handles.spc<maxlevel),'filled');
            end
        end
        
    else
        xs1 = handles.xs(handles.spc>0);
        ys1 = handles.ys(handles.spc>0);
        zs1 = handles.zs(handles.spc>0);
        spc1 = handles.spc(handles.spc>0);
        if ~isempty(xs1+ys1+zs1)
            scatter3(handles.axes,xs1,ys1,zs1,20,spc1,'filled');
        end
    end
end

set(handles.axes,'XLim',[-1,1],'YLim',[-1,1],'ZLim',[-1,1]);
colormap(handles.axes,'jet')
updateCB(handles);

% -- functions for colorbar -- %



function maline = maxline(xlim,ylim,level,h_axes)
maline = line([xlim(1),xlim(1),xlim(2),xlim(2)], ...
    [level-0.02*ylim(2),level*[1 1],level-0.02*ylim(2)],...
    'color', 'black', 'parent', h_axes,'ButtonDownFcn',@linedown,...
    'LineWidth',1,...
    'Tag','setline');


function miline = minline(xlim,ylim,level,h_axes)
miline = line([xlim(1),xlim(1),xlim(2),xlim(2)], ...
    [level+0.02*ylim(2),level*[1 1],level+0.02*ylim(2)],...
    'color', 'black', 'parent', h_axes,'ButtonDownFcn',@linedown,...
    'LineWidth',1,...
    'Tag','setline');


function btndown(hObject,b)
h_axes = findobj(get(findobj('Name','SphereHeatmap(Prototype)'),'Children'),'Tag','cbAxis');
handles = guidata(hObject);
f_axes = handles.axes;
C = get(h_axes,'currentpoint');
xlim = h_axes.XLim;
ylim = h_axes.YLim;
level = C(1,2);
% -- SET LINES -- %
% If more than two delete one of them
lines = findobj('Tag','setline');
if size(lines,1)==0
    ml = maxline(xlim,ylim,level,h_axes);
    caxis(f_axes,[ylim(1),ml.YData(1)]);
elseif size(lines,1)==1
    if level < lines(1).YData(1)
        ml = minline(xlim,ylim,level,h_axes);
        caxis(f_axes,[ml.YData(1),lines(1).YData(1)]);
    elseif level > lines(1).YData(1)
        ml1 = maxline(xlim,ylim,level,h_axes);
        ml2 = minline(xlim,ylim,lines(1).YData(1),h_axes);
        caxis(f_axes,[ml2(1).YData(1),ml1.YData(1)]);
        delete(lines)
    end
elseif size(lines,1)==2
    % Compare the levels
    [maxlevel,maxind] = max([lines(1).YData(1),lines(2).YData(1)]);
    [minlevel,minind] = min([lines(1).YData(1),lines(2).YData(1)]);
    if level>maxlevel
        delete(lines(maxind));
        maxline(xlim,ylim,level,h_axes);
        caxis(f_axes,[minlevel,level]);
    elseif level<minlevel
        delete(lines(minind));
        minline(xlim,ylim,level,h_axes);
        caxis(f_axes,[level,maxlevel]);
    elseif level > minlevel && level < maxlevel
        dist = maxlevel-minlevel;
        if level >=minlevel+dist/2
            delete(lines(maxind));
            maxline(xlim,ylim,level,h_axes);
            caxis(f_axes,[minlevel,level]);
        elseif level < minlevel+dist/2
            delete(lines(minind));
            minline(xlim,ylim,level,h_axes);
            caxis(f_axes,[level,maxlevel]);
        end
    end
    
else
    line([xlim(1),xlim(2)], ...
        level*[1 1],...
        'color', 'black', 'parent', h_axes,'ButtonDownFcn',@linedown,'Tag','setline');
end

function updateCB(handles,clear)
if nargin == 1
    clear = 'blabla';
end
axis = findobj('Tag','cbAxis');
if size(axis,1) == 0 || strcmp(clear,'clear')
    % build cb if not present jet
    delete(findobj('Tag','cbAxis'));
    caxis(handles.axes,[0,max(handles.spc(:))]);
    cb = colorbar(handles.axes,'Limits',[0,max(handles.spc(:))]);
    h_axes = axes(findobj('Name','SphereHeatmap(Prototype)'),...
        'position', cb.Position, 'ylim', cb.Limits,...
        'Units','normalize','color', 'none', 'visible','off',...
        'Tag','cbAxis','ButtonDownFcn',@btndown,'PickableParts','all');
elseif size(axis,1) == 1
    lines = findobj('Tag','setline');
    if size(lines,1)==0
        delete(axis)
        caxis(handles.axes,[0,max(handles.spc(:))]);
        cb = colorbar(handles.axes,'Limits',[0,max(handles.spc(:))]);
        h_axes = axes(findobj('Name','SphereHeatmap(Prototype)'),...
            'position', cb.Position, 'ylim', cb.Limits,...
            'Units','normalize','color', 'none', 'visible','off',...
            'Tag','cbAxis','ButtonDownFcn',@btndown,'PickableParts','all');
    elseif size(lines,1)==1
        xlim = axis.XLim;
        ylim = axis.YLim;
        maxlevel = lines(1).YData(1);
        delete(findobj('Tag','cbAxis'));
        cb = colorbar(handles.axes,'Limits',[0,max(handles.spc(:))]);
        h_axes = axes(findobj('Name','SphereHeatmap(Prototype)'),...
            'position', cb.Position, 'ylim', cb.Limits,...
            'Units','normalize','color', 'none', 'visible','off',...
            'Tag','cbAxis','ButtonDownFcn',@btndown,'PickableParts','all');
        ml = maxline(xlim,ylim,maxlevel,h_axes);
        caxis(handles.axes,[ylim(1),ml.YData(2)]);
    elseif size(lines,1)==2
        xlim = axis.XLim;
        ylim = axis.YLim;
        [maxlevel,maxind] = max([lines(1).YData(2),lines(2).YData(2)]);
        [minlevel,minind] = min([lines(1).YData(2),lines(2).YData(2)]);
        delete(findobj('Tag','cbAxis'));
        cb = colorbar(handles.axes,'Limits',[0,max(handles.spc(:))]);
        h_axes = axes(findobj('Name','SphereHeatmap(Prototype)'),...
            'position', cb.Position, 'ylim', cb.Limits,...
            'Units','normalize','color', 'none', 'visible','off',...
            'Tag','cbAxis','ButtonDownFcn',@btndown,'PickableParts','all');
        ml1 = maxline(xlim,ylim,maxlevel,h_axes);
        ml2 = minline(xlim,ylim,minlevel,h_axes);
        caxis(handles.axes,[minlevel,maxlevel]);
    end
    
    
end


function togglebutton(hObject)
if hObject.Value == 1
    set(hObject,'FontWeight','bold');
    set(hObject,'BackgroundColor',[0.8,0.8,0.8]);
    
else
    set(hObject,'BackgroundColor',[0.94,0.94,0.94]);
    set(hObject,'FontWeight','normal');
end


%% -- HANDLE FUNCTIONS -- %%

% --- Outputs from this function are returned to the command line.
function varargout = SphereHeatmap_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



function minShell_Callback(hObject, eventdata, handles)
% hObject    handle to minShell (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of minShell as text
%        str2double(get(hObject,'String')) returns contents of minShell as a double
handles.minShellValue = str2double(get(hObject,'String'));
handles = newSampling(handles);
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function minShell_CreateFcn(hObject, eventdata, handles)
% hObject    handle to minShell (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function maxShell_Callback(hObject, eventdata, handles)
% hObject    handle to maxShell (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of maxShell as text
%        str2double(get(hObject,'String')) returns contents of maxShell as a double
handles.maxShellValue = str2double(get(hObject,'String'));
handles = newSampling(handles);
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function maxShell_CreateFcn(hObject, eventdata, handles)
% hObject    handle to maxShell (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in tbSphere.
function tbSphere_Callback(hObject, eventdata, handles)
% hObject    handle to tbSphere (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
togglebutton(hObject);
visualization(handles);

% --- Executes on button press in tbVisZeros.
function tbVisZeros_Callback(hObject, eventdata, handles)
% hObject    handle to tbVisZeros (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
togglebutton(hObject);
visualization(handles);

% --- Executes on button press in tbIgnore.
function tbIgnore_Callback(hObject, eventdata, handles)
% hObject    handle to tbIgnore (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of tbIgnore
togglebutton(hObject);
visualization(handles);

% --- Executes on button press in tbShapeEmb.
function tbShapeEmb_Callback(hObject, eventdata, handles)
% hObject    handle to tbShapeEmb (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
togglebutton(hObject);
visualization(handles);

% --- Executes on button press in tbSample.
function tbSample_Callback(hObject, eventdata, handles)
% hObject    handle to tbSample (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of tbSample


function edSampling_Callback(hObject, eventdata, handles)
% hObject    handle to edSampling (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edSampling as text
%        str2double(get(hObject,'String')) returns contents of edSampling as a double
% Compute the new sampling
handles.sampling = str2double(get(hObject,'String'));
handles = newSampling(handles);
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function edSampling_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edSampling (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in tbConv.
function tbConv_Callback(hObject, eventdata, handles)
% hObject    handle to tbConv (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of tbConv
ableConv(handles);
handles = doConvolution(handles);

% --- Executes on button press in pbLoadResults.
function pbLoadResults_Callback(hObject, eventdata, handles)
% hObject    handle to pbLoadResults (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



function edConvSize_Callback(hObject, eventdata, handles)
% hObject    handle to edConvSize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edConvSize as text
%        str2double(get(hObject,'String')) returns contents of edConvSize as a double
handles.convSize = str2double(get(hObject,'String'));
set(hObject,'Value',handles.convSize);
handles = doConvolution(handles);
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function edConvSize_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edConvSize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes when selected object is changed in ubgSampling.
function ubgSampling_SelectionChangedFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in ubgSampling
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% Compute the new sampling
handles = newSampling(handles);
guidata(hObject, handles);


% --- Executes when selected object is changed in ubgConvType.
function ubgConvType_SelectionChangedFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in ubgConvType
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles = doConvolution(handles);
guidata(hObject,handles);


% --- Executes when figure1 is resized.
function figure1_SizeChangedFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% We need to update the axes for the colorbar.
handles = guidata(hObject);
if ~strcmp(handles.maxShell.String,'maxShell')
visualization(handles);
end


% --- Executes on button press in pbClearCB.
function pbClearCB_Callback(hObject, eventdata, handles)
% hObject    handle to pbClearCB (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
updateCB(handles,'clear')


