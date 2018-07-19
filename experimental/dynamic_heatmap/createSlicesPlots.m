function createSlicesPlots(accumulator, option)
    fprintf('Computing heatmaps...\n');
    
    % -- Convolve over the points -- %
    convAcc = convolveAccumulator(accumulator,option.cellradius,2*option.cellradius+1);

%     figure; colormap jet; 
%     subplot(1,3,1);
%     contourslice(convAcc, [],[], 0:20:256); 
%     axis equal;colorbar;
%     view(-11,14);
%     subplot(1,3,2);
%     contourslice(convAcc, [], 0:20:256,[]);
%     view(-62,43);
%     axis equal;colorbar;
%     subplot(1,3,3);
%     contourslice(convAcc, 0:20:256,[], []);
%     view(-62,43);
%     axis equal;colorbar;

    figure; colormap jet;
    subplot(1,2,1);
    contourslice(convAcc(:,:,1:160), [],[], 0:10:160);
    colorbar; view(3);
    hold on;
    [x,y,z] = sphere;
    surf(128*x + 128, 128*y + 128, 128*z+ 128,'FaceAlpha',0.1, 'FaceColor', 'm', 'EdgeColor', 'none');
    title('contour slices with transparent spherical surface');
    subplot(1,2,2);
    contourslice(convAcc(:,:,1:160), [],[], 0:10:160);
    colorbar; view(3);
    
%     for i=1:10
%         figure
%         subplot(2,1,1)
%         contour(convAcc(:,:,(10*(i-1)+1):10*i));
%         axis equal
%         title('Contour Plot on Tilted Plane')
%         xlabel('x')
%         ylabel('y')
%         colorbar
%         subplot(2,1,2)
%         surf(convAcc(:,:,(10*(i-1)+1):10*i),'LineStyle','none');
%         axis equal
%         view(0,90)
%         title('Colored Plot on Tilted Plane')
%         xlabel('x')
%         ylabel('y')
%         colorbar
%     end
end
