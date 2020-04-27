function Landscape_gui
clear;
close all;

gui_figure = figure('Visible', 'off', 'Position', [200,400,900,500], 'MenuBar', 'None', 'NumberTitle', 'off');

%set the standard settings here
global changes
changes.datatype = 'Zebrafish';
changes.resolution = [1.29,1.29,10];
changes.mCherryseg.cellSize = 50;

changes.ellipsoidFitting.regularisationParams.mu0 = 10^-7;
changes.ellipsoidFitting.regularisationParams.mu1 = 10^-4;
changes.ellipsoidFitting.regularisationParams.mu2 = 1;
changes.ellipsoidFitting.pcaType = 'Zebrafish';
changes.reg.characteristicWeight = 0;
changes.reg.reference_point = [-1;0;0];
changes.reg.reference_vector = [0;0;-1];
changes.samples_cube = [256,256,256];

changes.gridSize = [255;255;255];
changes.option.cellradius = 7;
changes.option.shellHeatmapResolution = [90,90];
changes.option.heatmaps.disp = 0;

changes.mappingtype = 'Cells';
changes.rmgb.mCherryDiskSize = 11;


root_dir = pwd;
addpath([root_dir '/parameter_setup/']);
addpath([root_dir '/gui/']);


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



   %functions for the buttons
    function button_processing_callback(source, eventdata)
        box_status.String = 'Registering...';
        
        try
            p = initializeScript('processing', root_dir);
        
            p = adjustParameters(p, changes);
            p = rmfield(p, 'gridSize');
            p = rmfield(p, 'option');
            p = rmfield(p, 'sizeOfPixel');
        
        
            processing_gui(p);
        catch ME
            disp(ME);
        end
        
        box_status.String = 'Ready';
    end

    function button_evaluation_callback(source, eventdata)
        box_status.String = 'Evaluating...';
        
        try
            p = initializeScript('evaluate', root_dir);
            old_resolution = p.resolution;
            p = adjustParameters(p, changes);
            p.resolution = old_resolution;
        
            evaluation_gui(p);
        catch ME
            disp(ME)
        end
        
        box_status.String = 'Ready';
    end

    function button_heatmap_callback(source, eventdata)
        box_status.String = 'Visualizing...';
        
        try
            p = initializeScript('heatmap', root_dir);
        
            p = adjustParameters(p, changes);
        
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
        system('evince gui/manual.pdf');
    end

end
