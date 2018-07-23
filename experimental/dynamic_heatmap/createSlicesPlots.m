function createSlicesPlots(accumulator1, option, titleOfPlots)
    fprintf('Computing heatmaps...\n');
    
    % -- Convolve over the velocities and points -- %
    convAcc = convolveAccumulator(accumulator1,option.cellradius,2*option.cellradius+1);
    [x_sphere,y_sphere,z_sphere] = sphere;
    
    numberOfSmallSubplots = 9;
    
    figure('pos',[10 10 900 1100]);
    sp(1) = subplot(5,3,[1 2 3 4 5 6]);
    contourslice(convAcc(:,:,1:160), [],[], 0:10:160);
    title(titleOfPlots);
    xlim([0 260]); ylim([0 260]); zlim([0 260]);
    colorbar; view(3); hold on; 
    surf(128*x_sphere + 128, 128*y_sphere + 128, 128*z_sphere+ 128,...
    'FaceAlpha',0.1, 'FaceColor', [0.6 0.6 0.6], 'EdgeColor', 'none');
    colorLimits = caxis;
    
    zslices = [ 1; 40; 60; 80; 100; 120; 130; 140; 150; 160];
    
    for i=1:numberOfSmallSubplots
        sp(i+1) = subplot(5, 3, 6+i);
        plotContourLines(sum(convAcc(:,:,zslices(i):zslices(i+1)),3), ...
            [num2str(zslices(i)) ' - ' num2str(zslices(i+1)) ' pixel in z-dir.']);
        caxisCurrent = caxis;
        colorLimits = [colorLimits(1), ceil(max(colorLimits(2), caxisCurrent(2)))];
        caxis('manual');
    end
    
    colorMapWithWhiteZero = jet(max(colorLimits));
    colorMapWithWhiteZero(1,:) = [1 1 1];
    
    for j = 1:numberOfSmallSubplots+1
        colormap(sp(j), colorMapWithWhiteZero);
        caxis(sp(j), colorLimits);
    end
end
    
function plotContourLines(V, titleOfPlot)
    imagesc(V)
    title(titleOfPlot);
    view(0,90);
    xlim([0 260]); ylim([0 260]); 
end
