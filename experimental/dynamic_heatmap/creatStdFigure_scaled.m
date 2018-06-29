function [ stdFig, pca] = creatStdFigure_scaled( numberOfResults, numOfAllCells,HMS, currentType, climMax)
% Creates standard figure

if climMax < 0
    climMax = max([max(HMS.(currentType).Top(:)),max(HMS.(currentType).Head(:)),...
    max(HMS.(currentType).Side(:))]);
end

mycolormap = jet(256);
stdFig = figure('units','normalized','outerposition',[0.25 0.25 0.65 0.65]);
set(stdFig,'Name',['Heatmaps ',currentType,' (scaled)']);
set(stdFig,'Visible','off');
colormap(mycolormap);

sp1 = subplot(1,3,1);
imagesc(HMS.(currentType).Top,[0,climMax]);
set(sp1,'Tag','sp1');
axis square
xlabel(gca,'Head \leftarrow \rightarrow Tail','FontSize',13);
ylabel(gca,'Right \leftarrow \rightarrow Left','FontSize',13);
set(gca,'xtick',[],'ytick',[])

sp2 = subplot(1,3,2);
imagesc(HMS.(currentType).Head',[0,climMax]);
set(sp2,'Tag','sp2');
axis square
ylabel(gca,'Bottom \leftarrow \rightarrow Top','FontSize',13);
xlabel(gca,'Left \leftarrow \rightarrow Right','FontSize',13);
set(gca,'xtick',[],'ytick',[])

sp3 = subplot(1,3,3);
imagesc(HMS.(currentType).Side',[0,climMax]);
set(sp3,'Tag','sp3');
axis square
ylabel(gca,'Bottom \leftarrow \rightarrow Top','FontSize',13);
xlabel(gca,'Head \leftarrow \rightarrow Tail','FontSize',13);
set(gca,'xtick',[],'ytick',[])
pca = get(sp3,'position');
colorbar;
set(sp3,'position',pca);

annotation('textbox',[0,0.9,1,0.1],...
    'String',['Time step: ',num2str(numberOfResults),', Total number of cells: ', num2str(numOfAllCells)],'EdgeColor', 'none', ...
    'FontSize',15,...
    'HorizontalAlignment', 'center')

end

