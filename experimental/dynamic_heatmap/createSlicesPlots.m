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
    contourslice(convAcc(:,:,1:160), [],[], 0:20:160);
    colorbar;
end
