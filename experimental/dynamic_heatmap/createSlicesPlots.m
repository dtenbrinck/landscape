function convAcc = createSlicesPlots(accumulator, option, titleOfPlots,...
    referenceLandmark, fig_filename, weightingNormalizer, sphere_center, sphere_radii)
    fprintf('Computing heatmaps...\n');
    gridSize = size(accumulator);
    zslices = [ 0:20:160];
    
    % Convolve over the velocities and points -- %
    convAcc = convolveAccumulator(accumulator,option.cellradius,2*option.cellradius+1);
    
    % Normalize accumaltors
    % -- normalization due to summation artefacts after convolution
    convDim = 1/(2*option.cellradius +1);
    convAccWeighted = convDim * convAcc;
    % -- normalization with, e.g., counted cells per voxel
    % replace 0 with 1 in normalizer to avoid deviding by 0!!
    weightingNormalizer(~weightingNormalizer)=1;
    convAccWeighted = convAccWeighted ./ weightingNormalizer; 
    [x_sphere,y_sphere,z_sphere] = sphere;
  
    f = figure('pos',[10 10 600 1100]);
    sp(1) = subplot(6,2,[1 2 3 4]);
    contourslice(convAccWeighted(:,:,1:160), [],[], zslices);
    colorLimits = caxis;
    maxColormapValue = colorLimits(2);
    title(titleOfPlots);
    xlim([0 gridSize(1)]); ylim([0 gridSize(2)]); zlim([0, gridSize(3)]);
    
    % get same orientation as in microscopy and following heatmap subplots
    set(gca,'Zdir','reverse'); 
    set(gca,'Ydir','reverse');
    set(gca,'xtick',[],'ytick',[], 'ztick', []);
    hLabel = get(gca,'XLabel');
    set(hLabel, 'Position', get(hLabel, 'Position') + [50 0 -50], 'Units', 'pixels');
    hLabel = get(gca,'YLabel');
    set(hLabel, 'Position', get(hLabel, 'Position') + [0 50 -50], 'Units', 'pixels');
    
    % plot reference unit sphere
    colorbar; view(-27.9, 78); hold on;
    surf(sphere_radii(1)*x_sphere + sphere_center(1),...
        sphere_radii(1)*y_sphere + sphere_center(2),...
        sphere_radii(1)*z_sphere+ sphere_center(3),...
    'FaceAlpha',0.1, 'FaceColor', [0.6 0.6 0.6], 'EdgeColor', 'none');
    % plot reference landmark
        indices = find(referenceLandmark.coords > 0);
    [tmpy, tmpx, tmpz] = ind2sub(size(referenceLandmark.coords), indices);
    scatter3(sp(1), tmpx, tmpy, tmpz, '.', 'MarkerEdgeColor', [0.7 0.7 0.7]);
    
    xlabel(gca,'Head \leftarrow \rightarrow Tail','FontSize',13);
    ylabel(gca,'Right \leftarrow \rightarrow Left','FontSize',13);
    zlabel('Bottom \leftarrow \rightarrow Top','FontSize',13);
    
    minColormapInterval = 1;
    zslices(1) = 1;    
    numberOfSmallSubplots = 8;
    for i=1:numberOfSmallSubplots
        sp(i+1) = subplot(6,2, 4+i);
        heatmapData = sum(convAccWeighted(:,:,zslices(i):zslices(i+1)),3);
        plotSingleHeatmap(heatmapData, ...
            [num2str(zslices(i)) ' - ' num2str(zslices(i+1)) ' px Top \rightarrow Bottom']);
          
        % keep information for later colormap generation
        minColormapIntervalLength = min( minColormapInterval,...
            min(heatmapData(heatmapData>0) ) );
        colorLimits = caxis;
        maxColormapValue = max( maxColormapValue, colorLimits(2) );
    end
    
    numberOfColorBlocks = ceil(maxColormapValue / minColormapIntervalLength);
    colorMapWithWhiteZero = jet( numberOfColorBlocks );
    colorMapWithWhiteZero(1, :) = [1 1 1];

    % add reference landmark and unify colormap
    colormap(sp(1), colorMapWithWhiteZero);
    caxis(sp(1), colorLimits);
    for j = 2:numberOfSmallSubplots+1
        colormap(sp(j), colorMapWithWhiteZero);
        caxis(sp(j), colorLimits);
        hold(sp(j), 'on');
        imagesc(sp(j), maxColormapValue*referenceLandmark.MIP, 'AlphaData', 0.1);
        hold(sp(j),'off');
    end
    
    % save figure
    saveas(f, fig_filename, option.heatmaps.saveas{1});
end
    
function plotSingleHeatmap(data, titleOfPlot)
    imagesc(data)
    title(titleOfPlot, 'FontSize',10);
    xlabel(gca,'Head \leftarrow \rightarrow Tail','FontSize',9);
    ylabel(gca,'Right \leftarrow \rightarrow Left','FontSize',9);
    axis square;
    set(gca,'xtick',[],'ytick',[]);
    caxis('manual'); %disable automatic limit updates in colormap
end
