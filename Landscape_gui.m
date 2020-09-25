function Landscape_gui
%LANDSCAPE_GUI create the gui window for landscape

clear all;

% Create the window figure
gui_figure = figure('Visible', 'off', 'Position', [200,400,900,500], 'MenuBar', 'None', 'NumberTitle', 'off');

% Assign the a name to appear in the window title
gui_figure.Name = 'Landscape';

% Move the window to the center of the screen
movegui(gui_figure,'center')

% Add necessary folders and subfolders
root_dir = pwd;
addpath([root_dir '/auxiliary/']);
addpath([root_dir '/fitting/']);
addpath([root_dir '/gui/']);
addpath([root_dir '/heatmaps/']);
addpath([root_dir '/io/']);
addpath([root_dir '/parameter_setup/']);
addpath([root_dir '/preprocessing/']);
addpath([root_dir '/registration/']);
addpath(genpath([root_dir '/segmentation/']));
addpath([root_dir '/visualization/']);

% Set up standard parameters
global p
p = ParameterTotal();

% Set default search path for data
dataPath = [root_dir '/data'];

% Set default search path for results
resultsPath = [root_dir '/results'];



% Buttons and UI elements from top to bottom
% Button that opens the settings window
button_settings = uicontrol('Style', 'pushbutton', ...
    'String', 'Settings', ...
    'FontName', 'Arial', ...
    'FontSize', 15, ...
    'BackgroundColor', [0.5,0.5,0.5], ...
    'Position', [350, 350, 200, 100], ...
    'Callback', @button_settings_callback);

% Button that starts the processing
button_processing = uicontrol('Style', 'pushbutton', ...
    'String', 'Registration', ...
    'Position', [50,200,200,100], ...
    'FontName', 'Arial', ...
    'FontSize', 15, ...
    'BackgroundColor', [0.6,0.7,1], ...
    'Callback', {@button_processing_callback});

% Arrow to indicate the order of steps
annotation('arrow', [0.3 0.37], [0.5 0.5])

% Button that starts the evaluation
button_evaluation = uicontrol('Style', 'pushbutton', ...
    'String', 'Evaluation', ...
    'Position', [350,200,200,100], ...
    'FontName', 'Arial', ...
    'FontSize', 15, ...
    'BackgroundColor', [0.6,0.7,1], ...
    'Callback', {@button_evaluation_callback});

% Arrow to indicate the order of steps
annotation('arrow', [0.63 0.7], [0.5 0.5])

% Button that starts the heatmap creation
button_heatmap = uicontrol('Style', 'pushbutton', ...
    'String', 'Visualization', ...
    'Position', [650,200,200,100], ...
    'FontName', 'Arial', ...
    'FontSize', 15, ...
    'BackgroundColor', [0.6,0.7,1], ...
    'Callback', {@button_heatmap_callback});

% Text that indicates the current status of the program
box_status = uicontrol('Style', 'text', ...
    'String', 'Ready', ...
    'Position', [250, 100, 400, 50], ...
    'FontName', 'Arial', ...
    'FontSize', 30); 


% Show the window
gui_figure.Visible = 'on';


%--------------------------------------------------------------------------
%Button Functions
%--------------------------------------------------------------------------
    % Function that starts the processing
    function button_processing_callback(source, eventdata)
        % Update status
        box_status.String = 'Registering...';
        
        try
            % Get the required data location and results path from the user
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
        
            % Start the processing script
            processing_gui(p);
        catch ME
            disp(ME);
        end
        
        % Update status
        box_status.String = 'Ready';
    end

    % Function that starts the evaluation
    function button_evaluation_callback(source, eventdata)
        % Update status
        box_status.String = 'Evaluating...';
        
        try
            % Get the results location from the user
            p.resultsPath = uigetdir(resultsPath,'Please select a results folder to evaluate');
            checkDirectory(p.resultsPath);
            
            % Start the evaluation script
            evaluation_gui(p);
        catch ME
            disp(ME)
        end
        
        % Update status
        box_status.String = 'Ready';
    end

    % Function that starts the heatmap creation
    function button_heatmap_callback(source, eventdata)
        % Update status
        box_status.String = 'Visualizing...';
        
        try
            % Get the results location from the user
            p.resultsPath = uigetdir(resultsPath,'Please select a results folder to generate heatmap');
            p.resultsPathAccepted = [p.resultsPath,'/accepted'];
            if ~exist([p.resultsPath,'/heatmaps'],'dir')
                mkdir([p.resultsPath,'/heatmaps']);
            end
            
            % Start the heatmap script
            generateHeatmaps(p);
        catch ME
            disp(ME)
        end
        
        % Update status
        box_status.String = 'Ready';
    end

    % Function that opens the settings window
    function button_settings_callback(source, eventdata)
        % Create the window and pass it on to the settings script
        f = figure('Visible', 'off', 'Position', [400,400,500,500], 'MenuBar', 'None', 'NumberTitle', 'off', 'Name', 'Settings');
        movegui(f, 'center');
        f.Visible = 'on';
        settings_gui(f);
    end

end
