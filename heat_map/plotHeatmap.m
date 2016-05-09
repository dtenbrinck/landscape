function plotHeatmap(CoMs)

    projected_CoMs = max(CoMs,[],3);

    % Create a figure and axes
    f = figure('Visible','off');
    ax = axes('Units','pixels');
    imagesc(max(CoMs,[],3));
    colorbar;
    
    % Create pop-up menu
    popup = uicontrol('Style', 'popup',...
           'String', {'jet','hsv','hot','cool','gray'},...
           'Position', [20 340 100 50],...
           'Callback', @setmap);    
    
   % Create push button
   % btn = uicontrol('Style', 'pushbutton', 'String', 'Clear',...
   %     'Position', [20 20 50 20],...
   %     'Callback', 'cla');       

   % Create slider
    slider = uicontrol('Style', 'slider',...
             'Min',0.1,'Max',10,'Value',1.0,...
             'Position', [400 20 120 20],...
             'Callback', @convData); 
					
    % Add a text uicontrol to label the slider.
    txt = uicontrol('Style','text',...
        'Position',[400 45 120 20],...
        'String','Sigma');
    
    % Make figure visble after adding all components
    set(f,'Visible','on');
    
    % listener for continuous slider feedback
    hLstn = handle.listener(slider,'ActionEvent',@convData); %#ok<NASGU>
    
    % change colormap
    function setmap(source,callbackdata)
         val = get(source,'Value');
         maps = get(source,'String'); 

        newmap = maps{val};
        colormap(newmap);
    end

    function convData(source,callbackdata)
        sigma = get(slider,'Value');
        k = fspecial('gaussian',round(2.5*sigma)*2+1, sigma);
        heat = convn(projected_CoMs, k, 'same');
        imagesc(max(heat,[],3));
        colorbar;
    end
end