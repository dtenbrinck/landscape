function createSlicesPlots(accumulator1, accumulator2, option)
    fprintf('Computing heatmaps...\n');
    
    % -- Convolve over the velocities and points -- %
    convAcc1 = convolveAccumulator(accumulator1,option.cellradius,2*option.cellradius+1);
    convAcc2 = convolveAccumulator(accumulator2,option.cellradius,2*option.cellradius+1);
    
    zDirBlockVector = 0:10:160;
    [x_sphere,y_sphere,z_sphere] = sphere;
    
    figure('pos',[10 10 900 900]);
    subplot(5,4,[1 2 5 6]);
    plot3dVisualizationOfAccumlator(convAcc1, zDirBlockVector, ...
    'Average velocities');
    colorbar; 
    surf(128*x_sphere + 128, 128*y_sphere + 128, 128*z_sphere+ 128,'FaceAlpha',0.1, 'FaceColor', 'm', 'EdgeColor', 'none');
    cmp1 = colormap;
    
    subplot(5,4,[3 4 7 8]);
    plot3dVisualizationOfAccumlator(convAcc2, zDirBlockVector, ...
    'Number of found PGCs');
    colorbar; 
    surf(128*x_sphere + 128, 128*y_sphere + 128, 128*z_sphere+ 128,'FaceAlpha',0.1, 'FaceColor', 'm', 'EdgeColor', 'none');
    cmp2 = colormap;
    for i=1:6
        zDirBlockVector = (i-1)*40+1:10:40*i;
        subplot(5, 4, 8+i);
        plot3dVisualizationOfAccumlator(convAcc1, zDirBlockVector, ...
            ['slice block ' num2str(i)]);
        colormap(cmp1);
        subplot(5, 4, 8+i+2);
        plot3dVisualizationOfAccumlator(convAcc2, zDirBlockVector, ...
            ['slice block ' num2str(i)]);
        colormap(cmp2);
    end
end

function plot3dVisualizationOfAccumlator(convAcc, zDirBlockVector, ...
    titleOfPlot)
    contourslice(convAcc(:,:,1:160), [],[], zDirBlockVector);
    colormap jet; view(3); hold on; view(3);
    title(titleOfPlot);
end
