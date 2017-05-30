%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Copyright 2013    Daniel Tenbrinck, Xiaoyi Jiang                      %
%   Institute of Computer Science                                         %
%   University of Muenster, Germany                                       %
%   email: daniel.tenbrinck@uni-muenster.de, xjiang@uni-muenster.de       %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function drawSegmentation(u0, phi, blood_segmentation, writeToDisk, picNumber)


    %if necessary initialize with default values
    if ~exist('writeToDisk') 
       writeToDisk = false; 
    end;

    %draw segmentation into the image
    %figure(1)
    %subplot(2,1,1); 
    imagesc(u0)
    axis image;
    colormap(gray);
    hold on;
    if blood_segmentation == true
        [contourMatrix,handle] = contour(phi, [-0.5,-0.5], 'r');
    else
        [contourMatrix,handle] = contour(phi, [0.5,0.5], 'r');
    end
    set(handle, 'LineWidth', 2);
    set(gca,'YDir','reverse');
    drawnow;
    hold off;
%     
%     subplot(2,1,2); imagesc(PSI)
%     axis image;
%     colormap(jet);
%     title('PSI')
    
       
    %optionally write image to disk
    if (writeToDisk)
        set(gcf, 'Color', 'w');  set(gca, 'XTickLabel', ''); set(gca, 'YTickLabel', ''); colormap gray;
        if picNumber < 10
            export_filename_png = ['./results/LV_Patient1_Otsu_DICE1+2_00',num2str(picNumber),'.png'];
        elseif picNumber < 100
                export_filename_png = ['./results/LV_Patient1_Otsu_DICE1+2_0',num2str(picNumber),'.png'];
        else
            export_filename_png = ['./results/LV_Patient1_Otsu_DICE1+2_',num2str(picNumber),'.png'];
        end
        export_fig(export_filename_png,'-q101');
    end;
     