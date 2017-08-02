%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Copyright 2013    Daniel Tenbrinck, Xiaoyi Jiang                      %
%   Institute of Computer Science                                         %
%   University of Muenster, Germany                                       %
%   email: daniel.tenbrinck@uni-muenster.de, xjiang@uni-muenster.de       %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function segmentation = segmentCell( roi, options )

%%% extract parameters
lambda = options.lambda;
numberAngles = options.numberAngles;
numberRadii = options.numberRadii;
method = options.method;

%%% extract output settings
show_segmentation = options.show_segmentation_result;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% IMAGE SEGMENTATION USING POLAR TRANSFORM AND DYNAMIC PROGRAMMING

%%% transform into polar coordinates
roiP = CartesianToPolar(roi, numberAngles, numberRadii, 'bilinear'); 

%%% segment image using dynamic programming
[PolarContour PolarSegmentation] = computeDPP(roiP,lambda,method);

segmentation = PolarToCartesian(PolarSegmentation, size(roi,1), size(roi,2), 'nearest');

%%% show segmentation result
if show_segmentation == true    
    h = figure(4);
    set(h,'Units','normalized','Position',[0.2 0.2 0.5 0.5]);
    drawSegmentation(roi, segmentation); pause(0.1); set(gcf, 'Color', 'w');
end

end



