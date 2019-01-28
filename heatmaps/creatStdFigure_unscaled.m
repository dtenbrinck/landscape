function [ stdFig ] = creatStdFigure_unscaled( numberOfResults, numOfAllCells,HMS, currentType)
% Creates standard figure

mycolormap = jet(256);
stdFig = figure('units','normalized','outerposition',[0.25 0.25 1 0.65]);
set(stdFig,'Name',['Heatmaps ',currentType,' (unscaled)']);
set(stdFig,'Visible','off');
colormap(mycolormap);

sp1 = subplot(1,5,1);
imagesc(HMS.(currentType).Top);
set(sp1,'Tag','sp1');
axis square
xlabel(gca,'Head \leftarrow \rightarrow Tail','FontSize',13);
ylabel(gca,'Right \leftarrow \rightarrow Left','FontSize',13);
set(gca,'xtick',[],'ytick',[])
pca = get(sp1,'position');
colorbar;
set(sp1,'position',pca);

sp2 = subplot(1,5,2);
imagesc(HMS.(currentType).Head');
set(sp2,'Tag','sp2');
axis square
ylabel(gca,'Bottom \leftarrow \rightarrow Top','FontSize',13);
xlabel(gca,'Left \leftarrow \rightarrow Right','FontSize',13);
set(gca,'xtick',[],'ytick',[])
pca = get(sp2,'position');
colorbar;
set(sp2,'position',pca);

sp3 = subplot(1,5,3);
imagesc(HMS.(currentType).Tail');
set(sp3,'Tag','sp3');
axis square
ylabel(gca,'Bottom \leftarrow \rightarrow Top','FontSize',13);
xlabel(gca,'Right \leftarrow \rightarrow Left','FontSize',13);
set(gca,'xtick',[],'ytick',[])
pca = get(sp3,'position');
colorbar;
set(sp3,'position',pca);

sp4 = subplot(1,5,4);
imagesc(HMS.(currentType).Side1');
set(sp4,'Tag','sp4');
axis square
ylabel(gca,'Bottom \leftarrow \rightarrow Top','FontSize',13);
xlabel(gca,'Head \leftarrow \rightarrow Tail','FontSize',13);
set(gca,'xtick',[],'ytick',[])
pca = get(sp4,'position');
colorbar;
set(sp4,'position',pca);

sp5 = subplot(1,5,5);
imagesc(HMS.(currentType).Side2');
set(sp5,'Tag','sp5');
axis square
ylabel(gca,'Bottom \leftarrow \rightarrow Top','FontSize',13);
xlabel(gca,'Head \leftarrow \rightarrow Tail','FontSize',13);
set(gca,'xtick',[],'ytick',[])
pca = get(sp5,'position');
colorbar;
set(sp5,'position',pca);

annotation('textbox',[0,0.9,1,0.1],...
    'String',['Number of processed dataset: ',num2str(numberOfResults),', Total number of cells: ', num2str(numOfAllCells)],'EdgeColor', 'none', ...
    'FontSize',15,...
    'HorizontalAlignment', 'center')
colorbar

end

