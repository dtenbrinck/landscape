function convAcc = createSlicesPlots(accumulator, option, titleOfPlots,...
    referenceLandmark, fig_filename, weightingNormalizer )
    fprintf('Computing heatmaps...\n');
    gridSize = size(accumulator);
    
    
    % Convolve over the velocities and points -- %
    convAcc = convolveAccumulator(accumulator,option.cellradius,2*option.cellradius+1);
    
    % Normalize accumaltors
    % -- normalization due to summation artefacts after convolution
    convDim = 1/(2*option.cellradius +1);
    convAccWeighted = convDim * convAcc;
    % -- normalization with a given factor or matrix
    % e.g., counted cells per voxel when plotting speed values
    % replace 0 with 1 in normalizer to avoid deviding by 0!!
    weightingNormalizer(~weightingNormalizer)=1;
    convAccWeighted = convAccWeighted ./ weightingNormalizer; 
  
    f = figure('pos',[10 10 600 750], 'Name', titleOfPlots);

    zslices = 0:20:160; zslices(1) = 1;    
    numberOfSmallSubplots = 8;
    maxColormapValue = 0;
    minColormapIntervalLength = 1;
    for i=1:numberOfSmallSubplots
        sp(i) = subplot(4,2,i);
        % plot heatmap
        heatmapData = sum(convAccWeighted(:,:,zslices(i):zslices(i+1)),3);
        plotSingleHeatmap(heatmapData, ...
            [num2str(zslices(i)) ' - ' num2str(zslices(i+1)) ' px Top \rightarrow Bottom']);
        
        hold (sp(i), 'on');
        % plot reference landmark
        landmarkSlicePart = sum(referenceLandmark.coords(:,:,zslices(i):zslices(i+1)),3);
        indices = find(landmarkSlicePart > 0);
        [tmpy, tmpx] = ind2sub(size(landmarkSlicePart), indices);
        s =scatter(sp(i), tmpx, tmpy, 5, 'MarkerEdgeColor', 'none', 'MarkerFaceColor', [0.7 0.7 0.7]);
        alpha(s, 0.1);
        contour ( sp(i), referenceLandmark.MIP > 0, 2, 'color', [0.4 0.4 0.4]);
        hold(sp(i), 'off');  
        % keep information for later colormap generation
        if (~isempty(heatmapData(heatmapData>0)))
            minColormapIntervalLength = min( minColormapIntervalLength,...
            min(heatmapData(heatmapData>0) ) );
        end
        colorLimits = caxis;
        maxColormapValue = max( maxColormapValue, colorLimits(2) );
    end
    
    numberOfColorBlocks = ceil(maxColormapValue / minColormapIntervalLength);
    
    % colormap from white to blue
    cMin = [1 1 1];
    cMax = [0 0 1];
    cMap = zeros(numberOfColorBlocks,3);
    for i = 1:numberOfColorBlocks
        cMap(i,:) = cMin*(numberOfColorBlocks - i)/(numberOfColorBlocks - 1) + cMax*(i - 1)/(numberOfColorBlocks - 1);
    end

    colorLimits = [0; maxColormapValue];
    for j = 1:numberOfSmallSubplots
        colormap(sp(j), colormap(cMap));
        caxis(sp(j), colorLimits);
        hcb = colorbar(sp(j));
        hcb.Label.String = titleOfPlots;
    end
    
    if option.heatmaps.save == 1
        % save figure
        saveas(f, fig_filename, option.heatmaps.saveas{1});
    end
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
