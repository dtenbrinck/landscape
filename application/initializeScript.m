function [ p ] = initializeScript( scriptType )
% Initializes the scripts

% add current folder and subfolders to path variable
addpath(genpath(pwd));

% set default search path for data
if exist('/4TB/data/SargonYigit/','dir') == 7
    dataPath = '/4TB/data/SargonYigit/';
elseif exist('E:/Embryo_Registration/data/SargonYigit/','dir') == 7
    dataPath = 'E:/Embryo_Registration/data/SargonYigit/';
else % in case the above folders don't exist take the current directory
    dataPath = './data';
end
% set default search path for results
if exist('/4TB/data/SargonYigit/','dir') == 7
    resultsPath = '/media/piradmin/4TB/Results/results';
else % in case the above folders don't exist take the current directory
    resultsPath = './results';
end

if strcmp(scriptType,'process')
    % Load parameters from file
    p = ParameterProcessing();

    % Select data path
    p.dataPath = uigetdir(dataPath,'Please select a folder with the data!');
    btn = questdlg('Do you want to use an existing results folder or create a new one?','New folder?','Create new','Use existing','Create new');
    
    if strcmp(btn,'Create new')
        p.resultsPath = uigetdir(resultsPath,'Please select a directory for the new folder!');
        answ = inputdlg('Enter a name for the new folder!');
        p.resultsPath = [p.resultsPath,'/',answ{1}];
        mkdir(p.resultsPath);
    else
        p.resultsPath = uigetdir(resultsPath,'Please select a folder for the results!');
    end
    
    
elseif strcmp(scriptType,'evaluate')
    resultsPath = uigetdir(resultsPath,'Please select a results folder to evaluate!');
    load([resultsPath,'/accepted/ParameterProcessing.mat']);
elseif strcmp(scriptType,'heatmap')
    resultsPath = uigetdir(resultsPath,'Please select a results folder to generate heatmap!');
    if exist([resultsPath,'/accepted/ParameterProcessing.mat'],'file') == 2
        load([resultsPath,'/accepted/ParameterProcessing.mat']);
    else
        p = ParameterProcessing();
    end
    p.resultsPath = resultsPath;
    p_heat = ParameterHeatmap();
    merge = [fieldnames(p)', fieldnames(p_heat)';...
        struct2cell(p)',struct2cell(p_heat)']; 
    p = struct(merge{:});
    p.resultsPathAccepted = [p.resultsPath,'/accepted'];
    save([p.resultsPath,'/accepted/ParameterHeatmap.mat'],'p_heat');
    mkdir([p.resultsPath,'/heatmaps']);
end

end

