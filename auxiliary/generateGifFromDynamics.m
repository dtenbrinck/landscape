function [ output_args ] = generateGifFromDynamics( data, filename )
%GENERATEGIFFROMDYNAMICS Summary of this function goes here
%   Detailed explanation goes here

% extract number of timepoints
numberOfTimepoints = size(data,4);

h = figure;

for t = 1:numberOfTimepoints

      imagesc(max(data(:,:,:,t),[],3),[min(data(:)) max(data(:))]);

      drawnow

      frame = getframe(1);

      im = frame2im(frame);

      [imind,cm] = rgb2ind(im,256);

      if t == 1;

          imwrite(imind,cm,filename,'gif', 'Loopcount',inf);

      else

          imwrite(imind,cm,filename,'gif','WriteMode','append');

      end

end

close(h);



end

