function settings_gui()
global changes

f = figure('Visible', 'on', 'Position', [200,400,500,500], 'MenuBar', 'None', 'NumberTitle', 'off', 'Name', 'Settings');

box_analysis_type = uicontrol('Style', 'text', ...
    'String', 'Type of input data', ...
    'Position', [150, 465, 200, 30], ...
    'FontName', 'Arial', ...
    'FontSize', 15);

button_type_zebrafish = uicontrol('Style', 'togglebutton', ...
    'FontName', 'Arial', ...
    'String', 'Zebrafish-like', ...
    'Position', [100, 430, 150, 30], ...
    'Value', isequal(changes.datatype, 'Zebrafish'), ...
    'Callback', @button_type_zebrafish_callback);
button_type_drosophila = uicontrol('Style', 'togglebutton', ...
    'FontName', 'Arial', ...
    'String', 'Drosophila-like', ...
    'Position', [250, 430, 150, 30], ...
    'Value', isequal(changes.datatype, 'Drosophila'), ...
    'Callback', @button_type_drosophila_callback);

box_mapping_type = uicontrol('Style', 'text', ...
    'String', 'Type of analysis', ...
    'FontName', 'Arial', ...
    'FontSize', 15, ...
    'Position', [150, 365, 200, 30]);

button_mappingtype_cells = uicontrol('Style', 'togglebutton', ...
    'FontName', 'Arial', ...
    'String', 'Cell mapping', ...
    'Position', [100, 330, 150, 30], ...
    'Value', isequal(changes.mappingtype, 'Cells'), ...
    'Callback', @button_mappingtype_cells_callback);
button_mappingtype_tissue = uicontrol('Style', 'togglebutton', ...
    'FontName', 'Arial', ...
    'String', 'Tissue mapping', ...
    'Position', [250, 330, 150, 30], ...
    'Value', isequal(changes.mappingtype, 'Tissue'), ...
    'Callback', @button_mappingtype_tissue_callback);


%box_type = uicontrol('Style', 'text', ...
%    'String', 'Type of data', ...
%    'Position', [50, 460, 200, 30], ...
%    'FontSize', 15);
%box_mappingtype = uicontrol('Style', 'text', ...
%    'String', 'Type of mapping', ...
%    'Position', [50,360, 200, 30], ...
%    'FontSize', 15);
box_resolution = uicontrol('Style', 'text', ...
    'String', ['Image Resolution (X,Y,Z) [' char(181) 'm]'], ...
    'Position', [50, 260, 350, 30], ...
    'FontName', 'Arial', ...
    'FontSize', 15);


editbox_resolution_x = uicontrol('Style', 'edit', ...
    'String', changes.resolution(1), ...
    'Position', [175,230,50,30], ...
    'Callback', @saving_callback);
editbox_resolution_y = uicontrol('Style', 'edit', ...
    'String', changes.resolution(2), ...
    'Position', [225,230,50,30], ...
    'Callback', @saving_callback);
editbox_resolution_z = uicontrol('Style', 'edit', ...
    'String', changes.resolution(3), ...
    'Position', [275,230,50,30], ...
    'Callback', @saving_callback);

%box_cellsize = uicontrol('Style', 'text', ...
%    'String', ['Cell size [' char(181) 'm]'], ...
%    'Position', [150, 160, 200, 30], ...
%    'FontSize', 15);
%editbox_cellsize = uicontrol('Style', 'edit', ...
%    'String', changes.mCherryseg.cellSize, ...
%    'Position', [200,130,100,30], ...
%    'Callback', @saving_callback, ...
%    'Enable', 'on');

%if isequal(changes.mappingtype, 'Tissue')
%    editbox_cellsize.Enable = 'off';
%end


    function button_type_zebrafish_callback(source, eventdata)
        button_type_zebrafish.Value = 1;
        button_type_drosophila.Value = 0;
        editbox_cellsize.String = 50;
        editbox_resolution_x.String = 1.29;
        editbox_resolution_y.String = 1.29;
        editbox_resolution_z.String = 10;
        
        changes.resolution = [1.29,1.29,10];
        changes.mCherryseg.cellSize = 50;
        changes.datatype = 'Zebrafish';
        
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
    end

    function button_type_drosophila_callback(source, eventdata)
        button_type_zebrafish.Value = 0;
        button_type_drosophila.Value = 1;
        editbox_cellsize.String = 15;
        editbox_resolution_x.String = 0.32;
        editbox_resolution_y.String = 0.32;
        editbox_resolution_z.String = 5;
        
        changes.resolution = [0.32,0.32,5];
        changes.mCherryseg.cellSize = 15;
        changes.datatype = 'Drosophila';
        
        changes.ellipsoidFitting.regularisationParams.mu0 = 10^-4;
        changes.ellipsoidFitting.regularisationParams.mu1 = 0.008;
        changes.ellipsoidFitting.regularisationParams.mu2 = 1;
        changes.ellipsoidFitting.pcaType = 'Drosophila';
        changes.reg.characteristicWeight = 0.5;
        changes.reg.reference_point = [-0.3122;0;-0.95];
        changes.reg.reference_vector = [0.95;0;-0.3122];
        changes.samples_cube = [512,256,256];
        
        changes.gridSize = [510;255;255];
        changes.option.cellradius = 3;
        changes.option.shellHeatmapResolution = [90,180];
    end

    function button_mappingtype_cells_callback(source, eventdata)
        button_mappingtype_cells.Value = 1;
        button_mappingtype_tissue.Value = 0;
        editbox_cellsize.Enable = 'on';
        
        changes.mappingtype = 'Cells';
        changes.rmgb.mCherryDiskSize = 11;
    end

    function button_mappingtype_tissue_callback(source, eventdata)
        button_mappingtype_cells.Value = 0;
        button_mappingtype_tissue.Value = 1;
        editbox_cellsize.Enable = 'off';
        
        changes.mappingtype = 'Tissue';
        changes.rmgb.mCherryDiskSize = 50;
    end

    function saving_callback(source, eventdata)
        changes.resolution = [str2double(editbox_resolution_x.String), str2double(editbox_resolution_y.String), str2double(editbox_resolution_z.String)];
        changes.mCherryseg.cellSize = str2double(editbox_cellsize.String);
    end
end