function [ p ] = initializeScript( scriptType, root_dir )
% Initializes the scripts

% add necessary folders
addpath([root_dir '/auxiliary/']);
addpath([root_dir '/fitting/']);
addpath([root_dir '/gui/']);
addpath([root_dir '/heatmaps/']);
addpath([root_dir '/io/']);
addpath([root_dir '/preprocessing/']);
addpath([root_dir '/registration/']);
addpath(genpath([root_dir '/segmentation/']));
addpath([root_dir '/visualization/']);


% set default search path for data
if exist('/media/piradmin/4TB/data/Landscape/Static','dir') == 7
  dataPath = '/media/piradmin/4TB/data/Landscape/Static';
else % in case the above folders don't exist take the current directory
  dataPath = [root_dir '/data'];
end
% set default search path for results
if exist('/media/piradmin/4TB/data/Landscape/Static','dir') == 7
  resultsPath = '/media/piradmin/4TB/data/Landscape/Static/results';
else % in case the above folders don't exist take the current directory
  resultsPath = [root_dir '/results'];
end

if strcmp(scriptType,'processing')
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
elseif strcmp(scriptType,'processing_dynamic')
  % Load parameters from file
  p = ParameterProcessingDynamic();
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
  checkDirectory(resultsPath);
  if exist([resultsPath,'/accepted/ParameterProcessing.mat'],'file') == 2
    load([resultsPath,'/accepted/ParameterProcessing.mat']);
  else
    p = ParameterProcessing();
  end
  p.resultsPath = resultsPath;
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
  
  if ~exist([p.resultsPath,'/heatmaps'],'dir')
    mkdir([p.resultsPath,'/heatmaps']);
  end
  
elseif strcmp(scriptType,'heatmapComparison')
  
  % get first directory
  resultsPath1 = uigetdir(resultsPath,'Please select first results folder to generate heatmap!');
  if exist([resultsPath1,'/accepted/ParameterProcessing.mat'],'file') == 2
    load([resultsPath1,'/accepted/ParameterProcessing.mat']);
    p1 = p;
  else
    p1 = ParameterProcessing();
  end
  
  p1.resultsPath = [resultsPath1 '/heatmaps'];
  if(exist(p1.resultsPath,'dir') ~= 7)
    error('Chosen directory does not contain subfolder named ''heatmaps''!');
  end
  %     p_heat = ParameterHeatmap();
  %     merge = [fieldnames(p)', fieldnames(p_heat)';...
  %         struct2cell(p)',struct2cell(p_heat)'];
  %     p = struct(merge{:});
  %p1.resultsPathAccepted1 = [p1.resultsPath1,'/accepted'];
  %save([p1.resultsPath1,'/accepted/ParameterHeatmap.mat'],'p_heat');
  
  % get second directory
  resultsPath2 = uigetdir(resultsPath,'Please select second results folder to generate heatmap!');
  if exist([resultsPath2,'/accepted/ParameterProcessing.mat'],'file') == 2
    load([resultsPath2,'/accepted/ParameterProcessing.mat']);
    p2 = p;
  else
    p2 = ParameterProcessing();
  end
  
  p2.resultsPath = [resultsPath2 '/heatmaps'];
  if(exist(p2.resultsPath,'dir') ~= 7)
    error('Chosen directory does not contain subfolder named ''heatmaps''!');
  end
  %p.resultsPathAccepted2 = [p1.resultsPath2,'/accepted'];
  %save([p1.resultsPath2,'/accepted/ParameterHeatmap.mat'],'p_heat');
  
  % ask for results folder
  btn = questdlg('Do you want to use an existing results folder or create a new one?','New folder?','Create new','Use existing','Create new');
  if strcmp(btn,'Create new')
    p3.resultsPath = uigetdir(resultsPath,'Please select a directory for the new folder!');
    answ = inputdlg('Enter a name for the new folder!');
    p3.resultsPath = [p3.resultsPath,'/',answ{1}];
    mkdir(p3.resultsPath);
  else
    p3.resultsPath = uigetdir(resultsPath,'Please select a folder for the results!');
  end
  
  % wrap variables for output
  clear p;
  p.p1 = p1;
  p.p2 = p2;
  p.p3 = p3;
end

end