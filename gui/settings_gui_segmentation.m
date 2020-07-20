function settings_gui_segmentation(f)

clf(f);
f.Position(4) = 700;
f.Position(2) = f.Position(2)-200;
global p;
box_title = uicontrol('Style', 'text', ...
    'String', 'Segmentation', ...
    'HorizontalAlignment', 'center', ...
    'FontName', 'Arial', ...
    'FontSize', 20, ...
    'Position', [150, 660, 200, 30]);

%Nuclei ------------------------------------------------------------------
box_k1 = uicontrol('Style', 'text', ...
    'String', 'Nuclei k-means k:', ...
    'HorizontalAlignment', 'left', ...
    'FontName', 'Arial', ...
    'FontSize', 15, ...
    'Position', [10, 600, 350, 30]);
editbox_k1 = uicontrol('Style', 'edit', ...
    'String', p.DAPIseg.k, ...
    'Position', [350,600,50,30], ...
    'Callback', @saving_callback);

box_min_nucleus = uicontrol('Style', 'text', ...
    'String', 'Nuclei Min Amount Voxel:', ...
    'HorizontalAlignment', 'left', ...
    'FontName', 'Arial', ...
    'FontSize', 15, ...
    'Position', [10, 550, 350, 30]);
editbox_min_nucleus = uicontrol('Style', 'edit', ...
    'String', p.DAPIseg.minNucleusSize, ...
    'Position', [350,550,50,30], ...
    'Callback', @saving_callback);

%Landmark ----------------------------------------------------------------
box_k2 = uicontrol('Style', 'text', ...
    'String', 'Landmark k-means k:', ...
    'HorizontalAlignment', 'left', ...
    'FontName', 'Arial', ...
    'FontSize', 15, ...
    'Position', [10, 500, 350, 30]);
editbox_k2 = uicontrol('Style', 'edit', ...
    'String', p.GFPseg.k, ...
    'Position', [350,500,50,30], ...
    'Callback', @saving_callback);

box_min_voxels_gfp = uicontrol('Style', 'text', ...
    'String', 'Landmark Min Amount Voxel:', ...
    'HorizontalAlignment', 'left', ...
    'FontName', 'Arial', ...
    'FontSize', 15, ...
    'Position', [10, 450, 350, 30]);
editbox_min_voxels_gfp = uicontrol('Style', 'edit', ...
    'String', p.GFPseg.minNumberVoxels, ...
    'Position', [350,450,50,30], ...
    'Callback', @saving_callback);

box_filter_opening_gfp = uicontrol('Style', 'text', ...
    'String', 'Landmark Filtersize Opening:', ...
    'HorizontalAlignment', 'left', ...
    'FontName', 'Arial', ...
    'FontSize', 15, ...
    'Position', [10, 400, 350, 30]);
editbox_filter_opening_gfp = uicontrol('Style', 'edit', ...
    'String', p.GFPseg.size_opening, ...
    'Position', [350,400,50,30], ...
    'Callback', @saving_callback);

box_filter_closing_gfp = uicontrol('Style', 'text', ...
    'String', 'Landmark Filtersize Closing:', ...
    'HorizontalAlignment', 'left', ...
    'FontName', 'Arial', ...
    'FontSize', 15, ...
    'Position', [10, 350, 350, 30]);
editbox_filter_closing_gfp = uicontrol('Style', 'edit', ...
    'String', p.GFPseg.size_closing, ...
    'Position', [350,350,50,30], ...
    'Callback', @saving_callback);

%Cell Probe --------------------------------------------------------------
box_k3 = uicontrol('Style', 'text', ...
    'String', 'Cell Probe k-means k:', ...
    'HorizontalAlignment', 'left', ...
    'FontName', 'Arial', ...
    'FontSize', 15, ...
    'Position', [10, 300, 350, 30], ...
    'Enable', intern_function_bool_to_on_off(strcmp(p.mappingtype,'Cells')));
editbox_k3 = uicontrol('Style', 'edit', ...
    'String', p.mCherryseg.k, ...
    'Position', [350,300,50,30], ...
    'Enable', intern_function_bool_to_on_off(strcmp(p.mappingtype,'Cells')), ...
    'Callback', @saving_callback);

%Tissue Probe ------------------------------------------------------------
box_k4 = uicontrol('Style', 'text', ...
    'String', 'Tissue Probe k-means k:', ...
    'HorizontalAlignment', 'left', ...
    'FontName', 'Arial', ...
    'FontSize', 15, ...
    'Position', [10, 250, 350, 30], ...
    'Enable', intern_function_bool_to_on_off(strcmp(p.mappingtype,'Tissue')));
editbox_k4 = uicontrol('Style', 'edit', ...
    'String', p.TISSUEseg.k, ...
    'Position', [350,250,50,30], ...
    'Enable', intern_function_bool_to_on_off(strcmp(p.mappingtype,'Tissue')), ...
    'Callback', @saving_callback);

box_min_voxels_tissue = uicontrol('Style', 'text', ...
    'String', 'Tissue Probe Min Amount Voxel:', ...
    'HorizontalAlignment', 'left', ...
    'FontName', 'Arial', ...
    'FontSize', 15, ...
    'Position', [10, 200, 350, 30], ...
    'Enable', intern_function_bool_to_on_off(strcmp(p.mappingtype,'Tissue')));
editbox_min_voxels_tissue = uicontrol('Style', 'edit', ...
    'String', p.TISSUEseg.minNumberVoxels, ...
    'Position', [350,200,50,30], ...
    'Enable', intern_function_bool_to_on_off(strcmp(p.mappingtype,'Tissue')), ...
    'Callback', @saving_callback);

box_filter_opening_tissue = uicontrol('Style', 'text', ...
    'String', 'Tissue Probe Filtersize Opening:', ...
    'HorizontalAlignment', 'left', ...
    'FontName', 'Arial', ...
    'FontSize', 15, ...
    'Position', [10, 150, 350, 30], ...
    'Enable', intern_function_bool_to_on_off(strcmp(p.mappingtype,'Tissue')));
editbox_filter_opening_tissue = uicontrol('Style', 'edit', ...
    'String', p.TISSUEseg.size_opening, ...
    'Position', [350,150,50,30], ...
    'Enable', intern_function_bool_to_on_off(strcmp(p.mappingtype,'Tissue')), ...
    'Callback', @saving_callback);

box_filter_closing_tissue = uicontrol('Style', 'text', ...
    'String', 'Tissue Probe Filtersize Closing:', ...
    'HorizontalAlignment', 'left', ...
    'FontName', 'Arial', ...
    'FontSize', 15, ...
    'Position', [10, 100, 350, 30], ...
    'Enable', intern_function_bool_to_on_off(strcmp(p.mappingtype,'Tissue')));
editbox_filter_closing_tissue = uicontrol('Style', 'edit', ...
    'String', p.TISSUEseg.size_closing, ...
    'Position', [350,100,50,30], ...
    'Enable', intern_function_bool_to_on_off(strcmp(p.mappingtype,'Tissue')), ...
    'Callback', @saving_callback);


button_back = uicontrol('Style', 'pushbutton', ...
    'FontName', 'Arial', ...
    'FontSize', 15, ...
    'String', 'Back', ...
    'Position', [150, 30, 200, 50], ...
    'Callback', @button_back_callback);

%--------------------------------------------
%BUTTON FUNCTIONS
%--------------------------------------------
    function button_back_callback(source, eventdata)
        f.Position(4) = 500;
        f.Position(2) = f.Position(2) + 200;
        settings_gui_advanced(f);
    end

    function saving_callback(source, eventdata)
        p.DAPIseg.k = str2double(editbox_k1.String);
        p.GFPseg.k = str2double(editbox_k2.String);
        p.mCherryseg.k = str2double(editbox_k3.String);
        p.TISSUEseg.k = str2double(editbox_k4.String);
        p.DAPIseg.minNucleusSize = str2double(editbox_min_nucleus.String);
        p.GFPseg.minNumberVoxels = str2double(editbox_min_voxels_gfp.String);
        p.GFPseg.size_opening = str2double(editbox_filter_opening_gfp.String);
        p.GFPseg.size_closing = str2double(editbox_filter_closing_gfp.String);
        p.TISSUEseg.minNumberVoxels = str2double(editbox_min_voxels_tissue.String);
        p.TISSUEseg.size_opening = str2double(editbox_filter_opening_tissue.String);
        p.TISSUEseg.size_closing = str2double(editbox_filter_closing_tissue.String);
    end

    function s = intern_function_bool_to_on_off(x)
        if x
            s = 'on';
        else
           s = 'off';
        end
    end
end

