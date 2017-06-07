%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Copyright 2017    Daniel Tenbrinck                                    %
%   Institute of Applied and Computational Mathematics                    %
%   University of Muenster, Germany                                       %
%   email: daniel.tenbrinck@uni-muenster.de                               %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function image_handle = drawSegmentation(u0, phi) 
    image_handle = imagesc(u0, [0 max(u0(:))/2]);
        
    axis image;
    colormap(gray);
    hold on;
    [~,handle] = contour(phi, [0.5,0.5], 'r');
    set(handle, 'LineWidth', 2);
    set(gca,'YDir','reverse');
    drawnow;
    hold off;
end