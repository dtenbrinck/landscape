%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Copyright 2013    Daniel Tenbrinck, Xiaoyi Jiang                      %
%   Institute of Computer Science                                         %
%   University of Muenster, Germany                                       %
%   email: daniel.tenbrinck@uni-muenster.de, xjiang@uni-muenster.de       %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function segmentation = segmentCell( roi, options, filename )

%%% extract parameters
lambda = options.lambda;
numberAngles = options.numberAngles;
numberRadii = options.numberRadii;
method = options.method;

%%% extract output settings
show_scale = options.show_scale_images;
save_rois = options.save_rois;
save_dpp = options.save_dp_result;
show_segmentation = options.show_segmentation_result;
save_segmentation = options.save_segmentation_result;
extension = options.file_format;

%%% save extracted roi for visual comparison
if save_rois == true
    h = figure(2); imshow(uint8(roi)); set(gcf, 'Color', 'w'); colormap gray;
    if show_scale == false
        set(gca, 'XTickLabel', '');
        set(gca, 'YTickLabel', '');
    end
    pause(0.1);
    export_filename = ['./results/' filename '_ROI' extension];
    export_fig(export_filename,'-q101');
    %close(h); 
    pause(0.1);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% IMAGE SEGMENTATION USING POLAR TRANSFORM AND DYNAMIC PROGRAMMING

%%% transform into polar coordinates
roiP = CartesianToPolar(roi, numberAngles, numberRadii, 'bilinear'); 

%%% segment image using dynamic programming
[PolarContour PolarSegmentation] = computeDPP(roiP,lambda,method);


%%% save dynamic programming result
if save_dpp == true
    rgbIm = zeros(size(roiP,1),size(roiP,2),3);
    rgbIm(:,:,1) = (1 - PolarContour) .* roiP + 255 * PolarContour;
    rgbIm(:,:,2) = (1 - PolarContour) .* roiP;
    rgbIm(:,:,3) = (1 - PolarContour) .* roiP;
    h=figure(3); imshow(uint8(rgbIm)); set(gcf, 'Color', 'w'); 
    if show_scale == false
        set(gca, 'XTickLabel', '');
        set(gca, 'YTickLabel', '');
    end
    pause(0.1);
    export_filename = ['./results/' filename '_DP' extension];
    export_fig(export_filename,'-q101');
    %close(h); 
    pause(0.1);
end

segmentation = PolarToCartesian(PolarSegmentation, size(roi,1), size(roi,2), 'nearest');

%%% show segmentation result
if show_segmentation == true    
    h = figure(4);
    set(h,'Units','normalized','Position',[0.2 0.2 0.5 0.5]);
    drawSegmentation(roi, segmentation, false); pause(0.1); set(gcf, 'Color', 'w');
end

%%% save segmentation result
if save_segmentation == true
    h = figure(5);
    set(h,'Units','normalized','Position',[0.2 0.2 0.5 0.5]);
    drawSegmentation(roi, segmentation, false); pause(0.1); set(gcf, 'Color', 'w');
    if show_scale == false
        set(gca, 'XTickLabel', '');
        set(gca, 'YTickLabel', '');
    end
    export_filename = ['./results/' filename '_SEGMENTATION' extension];
    export_fig(export_filename,'-q101');
    %close(h); 
    pause(0.1);
end

end



