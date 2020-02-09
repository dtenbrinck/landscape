function gui
clear;

f = figure('Visible', 'off', 'Position', [200,400,900,500], 'MenuBar', 'None', 'NumberTitle', 'off');

global changes
changes.resolution = [1.29,1.29,10];
changes.mCherryseg.cellSize = 50;
changes.datatype = 'Zebrafish';
changes.mappingtype = 'Cells';

root_dir = pwd;
addpath([root_dir '/parameter_setup/']);
addpath([root_dir '/gui/']);

button_processing = uicontrol('Style', 'pushbutton', ...
    'String', 'Registration', ...
    'Position', [50,200,200,100], ...
    'FontSize', 15, ...
    'BackgroundColor', [0.6,0.7,1], ...
    'Callback', {@button_processing_callback});

button_evaluation = uicontrol('Style', 'pushbutton', ...
    'String', 'Evaluation', ...
    'Position', [350,200,200,100], ...
    'FontSize', 15, ...
    'BackgroundColor', [0.6,0.7,1], ...
    'Callback', {@button_evaluation_callback});

button_heatmap = uicontrol('Style', 'pushbutton', ...
    'String', 'Visualization', ...
    'Position', [650,200,200,100], ...
    'FontSize', 15, ...
    'BackgroundColor', [0.6,0.7,1], ...
    'Callback', {@button_heatmap_callback});

button_help = uicontrol('Style', 'pushbutton', ...
    'String', '?', ...
    'FontSize', 15, ...
    'Position', [825, 25,50,50], ...
    'Callback', @button_help_callback);

button_settings = uicontrol('Style', 'pushbutton', ...
    'String', 'Settings', ...
    'FontSize', 15, ...
    'BackgroundColor', [0.5,0.5,0.5], ...
    'Position', [350, 350, 200, 100], ...
    'Callback', @button_settings_callback);


box_status = uicontrol('Style', 'text', ...
    'String', 'Ready', ...
    'Position', [250, 100, 400, 50], ...
    'FontSize', 30); 


% Assign the a name to appear in the window title.
f.Name = 'PROGRAM NAME';

% Move the window to the center of the screen.
movegui(f,'center')

f.Visible = 'on';



   %functions for the buttons
    function button_processing_callback(source, eventdata)
        box_status.String = 'Registrating...';
        
        p = initializeScript('processing', root_dir);
        
        p = adjustParameters(p, changes);
        
        processing_gui(p);
        
        box_status.String = 'Ready';
    end

    function button_evaluation_callback(source, eventdata)
        box_status.String = 'Evaluating...';
        
        p = initializeScript('evaluate', root_dir);

        p = adjustParameters(p, changes);
        
        evaluation_gui(p);
        
        box_status.String = 'Ready';
    end

    function button_heatmap_callback(source, eventdata)
        box_status.String = 'Visualizing...';
        
        p = initializeScript('heatmap', root_dir);
        
        p = adjustParameters(p, changes);
        
        generateHeatmaps(p);
        
        box_status.String = 'Ready';
    end

    function button_settings_callback(source, eventdata)
        settings_gui();
    end

    function button_help_callback(source, eventdata)
        disp('NOT YET ADDED');
    end

end