function settings_gui_advanced(f)
%settings_gui_main 
clf(f);

button_general = uicontrol('Style', 'pushbutton', ...
    'FontName', 'Arial', ...
    'FontSize', 15, ...
    'String', 'General', ...
    'Position', [150, 430, 200, 50], ...
    'Callback', @button_general_callback);

button_preprocessing = uicontrol('Style', 'pushbutton', ...
    'FontName', 'Arial', ...
    'FontSize', 15, ...
    'String', 'Preprocessing', ...
    'Position', [150, 370, 200, 50], ...
    'Callback', @button_preprocessing_callback);

button_segmentation = uicontrol('Style', 'pushbutton', ...
    'FontName', 'Arial', ...
    'FontSize', 15, ...
    'String', 'Segmentation', ...
    'Position', [150, 310, 200, 50], ...
    'Callback', @button_segmentation_callback);

button_ellipsoid_fitting = uicontrol('Style', 'pushbutton', ...
    'FontName', 'Arial', ...
    'FontSize', 15, ...
    'String', 'Ellipsoid Fitting', ...
    'Position', [150, 250, 200, 50], ...
    'Callback', @button_ellipsoid_fitting_callback);

button_registration = uicontrol('Style', 'pushbutton', ...
    'FontName', 'Arial', ...
    'FontSize', 15, ...
    'String', 'Registration', ...
    'Position', [150, 190, 200, 50], ...
    'Callback', @button_registration_callback);

button_heatmaps = uicontrol('Style', 'pushbutton', ...
    'FontName', 'Arial', ...
    'FontSize', 15, ...
    'String', 'Heatmaps', ...
    'Position', [150, 130, 200, 50], ...
    'Callback', @button_heatmaps_callback);

button_back = uicontrol('Style', 'pushbutton', ...
    'FontName', 'Arial', ...
    'FontSize', 15, ...
    'String', 'Back', ...
    'Position', [150, 50, 200, 50], ...
    'Callback', @button_back_callback);
%---------------------
%BUTTONS

    function button_general_callback(source, eventdata)
        settings_gui_general(f);
    end

    function button_preprocessing_callback(source, eventdata)
        settings_gui_preprocessing(f);
    end

    function button_segmentation_callback(source, eventdata)
        settings_gui_segmentation(f);
    end

    function button_ellipsoid_fitting_callback(source, eventdata)
        settings_gui_ellipsoid_fitting(f);
    end

    function button_registration_callback(source, eventdata)
        settings_gui_registration(f);
    end

    function button_heatmaps_callback(source, eventdata)
        settings_gui_heatmaps(f);
    end

    function button_back_callback(source, eventdata)
        settings_gui(f);
    end
end

