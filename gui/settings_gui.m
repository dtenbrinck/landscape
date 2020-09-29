function settings_gui(f)
% SETTINGS_GUI the settings window for landscape

% Access the parameter variable used in the main gui
global p

% Clear the figure
clf(f);

%--------------------------------------------------------------------------
% Create all buttons and UI elements from top to bottom
%--------------------------------------------------------------------------
% Button that saves the current settings to a file
button_save = uicontrol('Style', 'pushbutton', ...
    'String', 'Save Settings', ...
    'FontName', 'Arial', ...
    'FontSize', 10, ...
    'Position', [150, 470, 100, 30], ...
    'Callback', @button_save_callback);
% Button that loads settings from a file
button_load = uicontrol('Style', 'pushbutton', ...
    'String', 'Load Settings', ...
    'FontName', 'Arial', ...
    'FontSize', 10, ...
    'Position', [250, 470, 100, 30], ...
    'Callback', @button_load_callback);


% Buttons to choose the type of input data
% This automatically sets all settings to the corresponding standard
% settings
box_data_type = uicontrol('Style', 'text', ...
    'String', 'Type of Input Data', ...
    'Position', [100, 415, 300, 30], ...
    'HorizontalAlignment', 'center', ...
    'FontName', 'Arial', ...
    'FontSize', 15);
button_type_zebrafish = uicontrol('Style', 'togglebutton', ...
    'FontName', 'Arial', ...
    'String', 'Zebrafish-like', ...
    'Position', [100, 380, 150, 30], ...
    'Value', isequal(p.datatype, 'Zebrafish'), ...
    'Callback', @button_type_zebrafish_callback);
button_type_drosophila = uicontrol('Style', 'togglebutton', ...
    'FontName', 'Arial', ...
    'String', 'Drosophila-like', ...
    'Position', [250, 380, 150, 30], ...
    'Value', isequal(p.datatype, 'Drosophila'), ...
    'Callback', @button_type_drosophila_callback);

% Buttons to choose the mapping type for the data
box_mapping_type = uicontrol('Style', 'text', ...
    'String', 'Type of Probe', ...
    'HorizontalAlignment', 'center', ...
    'FontName', 'Arial', ...
    'FontSize', 15, ...
    'Position', [100, 315, 300, 30]);
button_mappingtype_cells = uicontrol('Style', 'togglebutton', ...
    'FontName', 'Arial', ...
    'String', 'Cells', ...
    'Position', [100, 280, 150, 30], ...
    'Value', isequal(p.mappingtype, 'Cells'), ...
    'Callback', @button_mappingtype_cells_callback);
button_mappingtype_tissue = uicontrol('Style', 'togglebutton', ...
    'FontName', 'Arial', ...
    'String', 'Tissue', ...
    'Position', [250, 280, 150, 30], ...
    'Value', isequal(p.mappingtype, 'Tissue'), ...
    'Callback', @button_mappingtype_tissue_callback);

% Editboxes to set the resolution of the input data
box_resolution = uicontrol('Style', 'text', ...
    'String', ['Image Resolution (X,Y,Z) [' char(181) 'm]'], ...
    'HorizontalAlignment', 'center', ...
    'Position', [0, 210, 500, 30], ...
    'FontName', 'Arial', ...
    'FontSize', 15);
editbox_resolution_x = uicontrol('Style', 'edit', ...
    'String', p.original_resolution(1), ...
    'Position', [175,180,50,30], ...
    'Callback', @saving_callback);
editbox_resolution_y = uicontrol('Style', 'edit', ...
    'String', p.original_resolution(2), ...
    'Position', [225,180,50,30], ...
    'Callback', @saving_callback);
editbox_resolution_z = uicontrol('Style', 'edit', ...
    'String', p.original_resolution(3), ...
    'Position', [275,180,50,30], ...
    'Callback', @saving_callback);


% Button that opens the advanced settings
button_advanced_settings = uicontrol('Style', 'pushbutton', ...
    'FontName', 'Arial', ...
    'FontSize', 15, ...
    'String', 'Advanced Settings', ...
    'Position', [150, 30, 200, 50], ...
    'Callback', @button_advanced_settings_callback);


%--------------------------------------------------------------------------
%Functions
%--------------------------------------------------------------------------
    % Function that sets all settings to the standard zebrafish settings
    function button_type_zebrafish_callback(source, eventdata)
        button_type_zebrafish.Value = 1;
        button_type_drosophila.Value = 0;
        editbox_resolution_x.String = 1.29;
        editbox_resolution_y.String = 1.29;
        editbox_resolution_z.String = 10;
        
        p.original_resolution = [1.29,1.29,10];
        p.resolution = p.original_resolution;
        p.resolution(1:2) = p.resolution(1:2) / p.scale;
        p.datatype = 'Zebrafish';
        
        p.ellipsoidFitting.regularisationParams.mu0 = 10^-7;
        p.ellipsoidFitting.regularisationParams.mu1 = 10^-4;
        p.ellipsoidFitting.regularisationParams.mu2 = 1;
        p.ellipsoidFitting.pcaCentered = false;
        p.reg.characteristicWeight = 0;
        p.reg.angle = 0;
        p.reg.reference_point = [-1;0;0];
        p.reg.reference_vector = [0;0;-1];
        p.samples_cube = [256,256,256];
        
        p.sizeOfPixel = 1.29; %um 1.29 Zebrafish
        p.gridSize = [255;255;255];
        p.option.cellradius = 7;
        p.option.shellHeatmapResolution = [90,90];
    end

    % Function that sets all settings to the standard drosophila settings
    function button_type_drosophila_callback(source, eventdata)
        button_type_zebrafish.Value = 0;
        button_type_drosophila.Value = 1;
        editbox_resolution_x.String = 0.32;
        editbox_resolution_y.String = 0.32;
        editbox_resolution_z.String = 5;
        
        p.original_resolution = [0.32,0.32,5];
        p.resolution = p.original_resolution;
        p.resolution(1:2) = p.resolution(1:2) / p.scale;
        p.datatype = 'Drosophila';
        
        p.ellipsoidFitting.regularisationParams.mu0 = 10^-4;
        p.ellipsoidFitting.regularisationParams.mu1 = 0.008;
        p.ellipsoidFitting.regularisationParams.mu2 = 1;
        p.ellipsoidFitting.pcaCentered = true;
        p.reg.characteristicWeight = 0.5;
        p.reg.angle = 71.8051;
        p.reg.reference_point = [-0.3122;0;-0.95];
        p.reg.reference_vector = [0.95;0;-0.3122];
        p.samples_cube = [512,256,256];
        
        p.sizeOfPixel = 0.32;
        p.gridSize = [510;255;255];
        p.option.cellradius = 3;
        p.option.shellHeatmapResolution = [180,90];
    end

    % Function that sets all relevant settings for cell mapping
    function button_mappingtype_cells_callback(source, eventdata)
        button_mappingtype_cells.Value = 1;
        button_mappingtype_tissue.Value = 0;
        
        p.mappingtype = 'Cells';
        p.rmbg.mCherryDiskSize = 11;
        p.option.convolution = true;
    end
    
    % Function that sets all relevant settings for tissue mapping
    function button_mappingtype_tissue_callback(source, eventdata)
        button_mappingtype_cells.Value = 0;
        button_mappingtype_tissue.Value = 1;
        
        p.mappingtype = 'Tissue';
        p.rmbg.mCherryDiskSize = 50;
        p.option.convolution = false;
    end

    % Function that opens the advanced settings in this window
    function button_advanced_settings_callback(source, eventdata)
        settings_gui_advanced(f);
    end

    % Function that saves all changes in the settings
    function saving_callback(source, eventdata)
        p.original_resolution = [str2double(editbox_resolution_x.String), str2double(editbox_resolution_y.String), str2double(editbox_resolution_z.String)];
        p.resolution = p.original_resolution;
        p.resolution(1:2) = p.resolution(1:2) / p.scale;
        
    end

    % Function that saves the current settings to a file chosen by the user
    function button_save_callback(source, eventdata)
        try
            parameter_file_path = uigetdir('Please select folder for your parameter file');
            % If the path selection was canceled, stop the saving process
            if parameter_file_path == 0; return; end
            parameter_file_name = inputdlg('Please enter a name for your parameter file');
            % If the file naming was canceled, stop the saving process
            if isempty(parameter_file_name); return; end
            save([parameter_file_path '\' parameter_file_name{1} '.mat'], 'p');
        catch
            disp('Saving parameters was not successful')
        end
    end

    % Function that loads the settings from a file chosen by the user
    function button_load_callback(source, eventdata)
        try
            [parameter_file_name, parameter_file_path] = uigetfile;
            % If the file selection was canceled, stop the loading process
            if parameter_file_name == 0; return; end
            load([parameter_file_path '/' parameter_file_name]);
        catch
            disp('Loading parameters was not successful')
            return
        end
        % Update all UI elements for the new settings
        button_type_zebrafish.Value = isequal(p.datatype, 'Zebrafish');
        button_type_drosophila.Value = isequal(p.datatype, 'Drosophila');
        button_mappingtype_cells.Value = isequal(p.mappingtype, 'Cells');
        button_mappingtype_tissue.Value = isequal(p.mappingtype, 'Tissue');
        editbox_resolution_x.String = p.original_resolution(1);
        editbox_resolution_y.String = p.original_resolution(2);
        editbox_resolution_z.String = p.original_resolution(3);
    end
end
