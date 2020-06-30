function Landscape_gui
clear;
close all;

gui_figure = figure('Visible', 'off', 'Position', [200,400,900,500], 'MenuBar', 'None', 'NumberTitle', 'off');


root_dir = pwd;
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

addpath([root_dir '/parameter_setup/']);
addpath([root_dir '/gui/']);

%set up standard parameters
global p
p = ParameterTotal();

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


%%Buttons and UI Elements
button_settings = uicontrol('Style', 'pushbutton', ...
    'String', 'Settings', ...
    'FontName', 'Arial', ...
    'FontSize', 15, ...
    'BackgroundColor', [0.5,0.5,0.5], ...
    'Position', [350, 350, 200, 100], ...
    'Callback', @button_settings_callback);


button_processing = uicontrol('Style', 'pushbutton', ...
    'String', 'Registration', ...
    'Position', [50,200,200,100], ...
    'FontName', 'Arial', ...
    'FontSize', 15, ...
    'BackgroundColor', [0.6,0.7,1], ...
    'Callback', {@button_processing_callback});

annotation('arrow', [0.3 0.37], [0.5 0.5])

button_evaluation = uicontrol('Style', 'pushbutton', ...
    'String', 'Evaluation', ...
    'Position', [350,200,200,100], ...
    'FontName', 'Arial', ...
    'FontSize', 15, ...
    'BackgroundColor', [0.6,0.7,1], ...
    'Callback', {@button_evaluation_callback});

annotation('arrow', [0.63 0.7], [0.5 0.5])

button_heatmap = uicontrol('Style', 'pushbutton', ...
    'String', 'Visualization', ...
    'Position', [650,200,200,100], ...
    'FontName', 'Arial', ...
    'FontSize', 15, ...
    'BackgroundColor', [0.6,0.7,1], ...
    'Callback', {@button_heatmap_callback});

button_help = uicontrol('Style', 'pushbutton', ...
    'String', 'Manual', ...
    'FontName', 'Arial', ...
    'FontSize', 15, ...
    'Position', [750, 25,100,50], ...
    'Callback', @button_help_callback);


box_status = uicontrol('Style', 'text', ...
    'String', 'Ready', ...
    'Position', [250, 100, 400, 50], ...
    'FontName', 'Arial', ...
    'FontSize', 30); 


% Assign the a name to appear in the window title.
gui_figure.Name = 'Landscape';

% Move the window to the center of the screen.
movegui(gui_figure,'center')

gui_figure.Visible = 'on';


%%Functions for buttons
    function button_processing_callback(source, eventdata)
        box_status.String = 'Registering...';
        
        try
            p.dataPath = uigetdir(dataPath,'Please select a folder with the data');
            btn = questdlg('Do you want to use an existing results folder or create a new one?','New folder?','Create new','Use existing','Create new');
  
            if strcmp(btn,'Create new')
                p.resultsPath = uigetdir(resultsPath,'Please select a directory for the new folder');
                answ = inputdlg('Please enter a name for the new folder');
                p.resultsPath = [p.resultsPath,'/',answ{1}];
                mkdir(p.resultsPath);
            else
                p.resultsPath = uigetdir(resultsPath,'Please select a folder for the results');
            end
        
        
            processing_gui(p);
        catch ME
            disp(ME);
        end
        
        box_status.String = 'Ready';
    end

    function button_evaluation_callback(source, eventdata)
        box_status.String = 'Evaluating...';
        
        try
            p.resultsPath = uigetdir(resultsPath,'Please select a results folder to evaluate');
            checkDirectory(p.resultsPath);
        
            evaluation_gui(p);
        catch ME
            disp(ME)
        end
        
        box_status.String = 'Ready';
    end

    function button_heatmap_callback(source, eventdata)
        box_status.String = 'Visualizing...';
        
        try
            p.resultsPath = uigetdir(resultsPath,'Please select a results folder to generate heatmap');
            p.resultsPathAccepted = [p.resultsPath,'/accepted'];
            if ~exist([p.resultsPath,'/heatmaps'],'dir')
                mkdir([p.resultsPath,'/heatmaps']);
            end
        
            generateHeatmaps(p);
        catch ME
            disp(ME)
        end
        
        box_status.String = 'Ready';
    end

    function button_settings_callback(source, eventdata)
        settings_gui();
    end

    function button_help_callback(source, eventdata)
        if ismac %Mac
            open('gui/manual.pdf');
        elseif isunix %Linux
            system('evince gui/manual.pdf');
        elseif ispc %Windows
            open('gui/manual.pdf');
        end
    end

end
