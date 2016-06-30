function [handles] = compRegistrationGUI(handles)
%COMPREGISTRATIONGUI:  This function computes the registration for the
% segmentation data handles.SegData. The reference data set is given bei
% handles.nRefData. 

%% Input:
% handles:      data structure. 

%% Output:
% handles:      updated data structure.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Initialization

% Sample the unit sphere
samples = handles.samples;
[alpha, beta] = meshgrid(linspace(pi,2*pi,samples/2), linspace(0,2*pi,samples));
Zs = cos(alpha) .* sin(beta);
Xs = sin(alpha) .* sin(beta);
Ys = cos(beta);

% Sample the unit cube
[Xc, Yc, Zc] = meshgrid(linspace(-1,1,samples), linspace(-1,1,samples), linspace(-1,1,samples));

%% Main Code

% Set the sRefData
sRefData = char(handles.filenames(handles.nRefData));
sRefData = sRefData(1:end-4);

fprintf('Starting registration: \n');
fprintf(['Initializing the reference data set Data_',sRefData,'... \n']);

% Initialize the reference data set.
[refpstar, refvstar,regData] ...
    = computeRegression(handles.SegData.(['Data_',sRefData]).GFPOnSphere, Xs, Ys, Zs, 'false');

fprintf('Setting the reference p* and v*.\n');

% Update handles.SegData
handles.SegData.(['Data_',sRefData]).pstar = refpstar;
handles.SegData.(['Data_',sRefData]).vstar = refvstar;
handles.SegData.(['Data_',sRefData]).regData = regData;

fprintf('Initialization done!\n');
% Compute the spherical regression for the rest of the datasets and
% register them.

fprintf(['Starting registration of the data sets to the reference dataset: Data_',sRefData,'... \n'])

% Delete the reference data from the filenames.
filenames = handles.filenames;
filenames(handles.nRefData) = [];
for i=1:size(filenames,1)
    fprintf(['Computing regression for dataset ',num2str(i),' of ',num2str(size(filenames,1)),'...']);
    
    % Get the data that is projected onto the sphere
    dataName = char(filenames(i));
    dataName = dataName(1:end-4);
    fieldname = ['Data_',dataName];
    
    % Compute regression
    [pstar,vstar, regData] ...
        = computeRegression(handles.SegData.(fieldname).GFPOnSphere, Xs,Ys,Zs,'false');
    fprintf('Done!\n');
    
    % Registration of the data set
    fprintf('Register data set onto reference dataset.\n');
    
    % Rotationmatrix: Rotate the great circle s.t. pstar is on refpstar
    [Rp,Rv,pstar_r,vstar_r,vAngle]...
        = rotateGreatCircle(pstar,vstar,refpstar,refvstar);
    
    % Rotationmatrix: Rotates the regression line onto the reference line
    Ra = rotAboutAxis(vAngle,refpstar);
    
    % Rotate data set and cell coordinates
    regData_r = Ra*Rp*regData;
    handles.SegData.(fieldname).centCoords ...
        = Ra*Rp*handles.SegData.(fieldname).centCoords;
    
    % Update field
    handles.SegData.(fieldname).Rp = Rp;
    handles.SegData.(fieldname).Rv = Rv;
    handles.SegData.(fieldname).Ra = Ra;
    handles.SegData.(fieldname).pstar = pstar;
    handles.SegData.(fieldname).vstar = vstar;
    handles.SegData.(fieldname).pstar_r = pstar_r;
    handles.SegData.(fieldname).vstar_r = vstar_r;
    handles.SegData.(fieldname).vAngle = vAngle;
    handles.SegData.(fieldname).regData = regData;
    handles.SegData.(fieldname).regData_r = regData_r;
    
    % Visualize Registration
    if handles.vis_regist
        showRegist(handles.SegData.(['Data_',sRefData]),...
            handles.SegData.(fieldname),['Data_',sRefData],fieldname);
    end
end
set(handles.textField,'String','Registration Done!');
fprintf('Registration Done!\n');



end

