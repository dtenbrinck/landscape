function CheckCellCoords(cells,cellCoords)

for i=1:size(cells,3)
    disp(['Slice #',num2str(i)]);
    figure(1),cla,imagesc(cells(:,:,i));
    hold on
    cellsInSlice = cellCoords(:,cellCoords(3,:)==i);
    scatter(cellsInSlice(1,:),cellsInSlice(2,:),'*');
    pause();
end

end