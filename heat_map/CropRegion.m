function [] = CropRegion( accumulator, HMTop, depth )

if ischar(depth)
    if strcmp(depth,'all')
        depth = size(accumulator,3);
    else 
        error('Wrong string input');
    end
elseif isnumeric(depth)
    if depth > 0 && depth <= size(accumulator,3)
    else 
        error('depth to big or small');
    end
end

f1 = figure('Position',[400,350,600,650],'Units','normalized');

I = imagesc(HMTop);
axis square
title(['Select interesting region! Depth is set to ',num2str(depth)]);
totalCellNum = sum(accumulator(:));
tbResult = uicontrol('Style','text','Tag','tbResult','Position',[300,40,300,20],...
    'FontSize',10,'String','Number of cells in region:');
uicontrol('Style','text','Tag','tbTotal','Position',[300,60,300,20],...
    'FontSize',10,'String',['Total number of cells: ',num2str(totalCellNum)]);
tbPercent = uicontrol('Style','text','Tag','tbPercent','Position',[300,20,300,20],...
    'FontSize',10,'String','Percentage of cells in region:');
uicontrol('Style','pushbutton',...
    'String','Crop',...
    'Position',[80,20,150,60],...
    'Callback',{@cropIt,I,accumulator,depth,tbResult,tbPercent,HMTop});



end

