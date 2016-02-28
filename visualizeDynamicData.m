function visualizeDynamicData( data, repetitions )
%VISULAIZEDYNAMICDATA Summary of this function goes here
%   Detailed explanation goes here

% check if optional second argument is given, else set repetitions to two
if nargin == 1
  repetitions = 2;
end

% repeat movie as specified
for run=1:repetitions
  for frame=1:size(data,4)
    
    % visualize for each frame slice at the middle of 3D slice stack
    figure(12); imagesc(data(:,:,round(end/2),frame));
    pause(0.15);
    
  end
end