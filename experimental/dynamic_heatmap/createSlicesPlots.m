function convAcc = createSlicesPlots(accumulator1, option, titleOfPlots,...
    referenceLandmark, fig_filename, weightingNormalizer )
    fprintf('Computing heatmaps...\n');
    
    % Convolve over the velocities and points -- %
    convAcc = convolveAccumulator(accumulator1,option.cellradius,2*option.cellradius+1);
    
    % Normalize accumaltors
    % -- normalization due to summation artefacts after convolution
    convDim = 1/(2*option.cellradius +1);
    convAccWeighted = convDim * convAcc;
    % -- normalization with, e.g., counted cells per voxel
    % replace 0 with 1 in normalizer to avoid deviding by 0!!
    weightingNormalizer(~weightingNormalizer)=1;
    convAccWeighted = convAccWeighted ./ weightingNormalizer; 
    
    % -- replace zero values by -1
    convAccWeighted(convAccWeighted == 0) = -1;
    min(min(min(convAccWeighted)))
    [x_sphere,y_sphere,z_sphere] = sphere;
    
    numberOfSmallSubplots = 9;
    
    f = figure('pos',[10 10 900 1100]);
    sp(1) = subplot(5,3,[1 2 3 4 5 6]);
    contourslice(convAccWeighted(:,:,1:160), [],[], 0:10:160);
    colorLimits = caxis;
    colorLimits = [floor(min(-2, colorLimits(1))), colorLimits(2)];
    title(titleOfPlots);
    xlim([0 260]); ylim([0 260]); zlim([0, 260]);
    set(gca,'Zdir','reverse');
    colorbar; view(-27.9, 78); hold on; 
    surf(128*x_sphere + 128, 128*y_sphere + 128, 128*z_sphere+ 128,...
    'FaceAlpha',0.1, 'FaceColor', [0.6 0.6 0.6], 'EdgeColor', 'none');
    xlabel(gca,'Head \leftarrow \rightarrow Tail','FontSize',13);
    ylabel(gca,'Right \leftarrow \rightarrow Left','FontSize',13);
    zlabel('Bottom \leftarrow \rightarrow Top','FontSize',13);
    hLabel = get(gca,'XLabel');
    set(hLabel, 'Position', get(hLabel, 'Position') + [50 0 -50]);
    set(hLabel, 'Units', 'pixels'); 
    hLabel = get(gca,'YLabel');
    set(hLabel, 'Position', get(hLabel, 'Position') + [0 50 -50]);
    set(hLabel, 'Units', 'pixels'); 
    zslices = [ 1; 40; 60; 80; 100; 120; 130; 140; 150; 160];
    
    for i=1:numberOfSmallSubplots
        sp(i+1) = subplot(5, 3, 6+i);
        plotContourLines(sum(convAccWeighted(:,:,zslices(i):zslices(i+1)),3), ...
            [num2str(zslices(i)) ' - ' num2str(zslices(i+1)) ' px Top \rightarrow Bottom']);
        caxisCurrent = caxis;
        colorLimits = [floor(min(-2,caxisCurrent(1))), ceil(max(colorLimits(2), caxisCurrent(2)))];
        caxis('manual');
        hold on;
        imagesc(-2*referenceLandmark, 'AlphaData', 0.1);
        xlabel(gca,'Head \leftarrow \rightarrow Tail','FontSize',13);
        ylabel(gca,'Right \leftarrow \rightarrow Left','FontSize',13);
    end
    
    colorMapWithWhiteZero = jet(max(colorLimits));
%     colorMapWithWhiteZero(1,:) = [1 1 1];
    colorLimits
    for j = 1:numberOfSmallSubplots+1
        colormap(sp(j), colorMapWithWhiteZero);
        caxis(sp(j), colorLimits);
    end
    
    % save figure
    saveas(f, fig_filename, option.heatmaps.saveas{1});
end
    
function plotContourLines(V, titleOfPlot)
    imagesc(V)
    title(titleOfPlot);
    view(0,90);
    xlim([0 260]); ylim([0 260]); 
end
