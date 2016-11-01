function [ stdFig ] = creatStdFigure_unscaled( numberOfResults, numOfAllCells,HMS, currentType,i,option)
% Creates standard figure

mycolormap = jet(256);
stdFig = figure('units','normalized','outerposition',[0.25 0.25 0.65 0.65]);
set(stdFig,'Name',['Heatmaps ',char(option.heatmaps.types(i)),' (unscaled)']);
set(stdFig,'Visible','off');
colormap(mycolormap);

sp1 = subplot(1,3,1);
imagesc(HMS.(currentType).Top);
set(sp1,'Tag','sp1');
axis square
xlabel(gca,'Head \leftarrow \rightarrow Tail','FontSize',13);
ylabel(gca,'Left \leftarrow \rightarrow Right','FontSize',13);
set(gca,'xtick',[],'ytick',[])
pca = get(sp1,'position');
colorbar;
set(sp1,'position',pca);

sp2 = subplot(1,3,2);
imagesc(HMS.(currentType).Head');
set(sp2,'Tag','sp2');
axis square
ylabel(gca,'Bottom \leftarrow \rightarrow Top','FontSize',13);
xlabel(gca,'Left \leftarrow \rightarrow Right','FontSize',13);
set(gca,'xtick',[],'ytick',[])
pca = get(sp2,'position');
colorbar;
set(sp2,'position',pca);

sp3 = subplot(1,3,3);
imagesc(HMS.(currentType).Side');
set(sp3,'Tag','sp3');
axis square
ylabel(gca,'Bottom \leftarrow \rightarrow Top','FontSize',13);
xlabel(gca,'Tail \leftarrow \rightarrow Head','FontSize',13);
set(gca,'xtick',[],'ytick',[])
pca = get(sp3,'position');
colorbar;
set(sp3,'position',pca);
annotation('textbox',[0,0.9,1,0.1],...
    'String',['Number of processed dataset: ',num2str(numberOfResults),', Total number of cells: ', num2str(numOfAllCells)],'EdgeColor', 'none', ...
    'FontSize',15,...
    'HorizontalAlignment', 'center')
colorbar

end

