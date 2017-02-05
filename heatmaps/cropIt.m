function croppedCellNum = cropIt(h,event,I,accumulator,depth,tbResult,tbPercent,img)
I = imagesc(img);
title(['Select interesting region! Depth is set to ',num2str(depth)]);
axis square
[~,rect2] = imcrop(I);
rect2 = round(rect2);
rectangle('Position',rect2,'EdgeColor','r');
drawnow;
croppedAcc = accumulator((rect2(2)):(rect2(2)+rect2(4)),...
    (rect2(1)):(rect2(1)+rect2(3)),1:depth);
croppedCellNum = sum(croppedAcc(:));
set(tbResult,'String',['Number of cells in region: ',num2str(croppedCellNum)]);
set(tbPercent,'String',['Percentage of cells in region: ',...
    num2str(croppedCellNum/sum(accumulator(:))*100),'%']);
end

