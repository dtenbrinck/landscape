clc; clear; close all;
tmp = load('./results/allCellCoords2.mat');
coordinates = tmp.allCellCoords';
coordinates = 2 * ((coordinates - min(coordinates(:))) ./ (max(coordinates(:)) - min(coordinates(:))) - 0.5);
coordinates(:,3) = -coordinates(:,3);

tmp = load('./results/landmarkOnSphere.mat');
landmark = tmp.landmarkCoordinates';
landmark(:,3) = -landmark(:,3);

all_coords = cat(1,landmark,coordinates);

number_of_layers = 20;
interest_area = 0.32;
samples = 32;

% visualize cell distribution and reference landmark
%figure; scatter3(coordinates(:,1), coordinates(:,2), coordinates(:,3),36,[0 0 0]);
%hold on; scatter3(landmark(:,1), landmark(:,2), landmark(:,3),36,[1 0 0]); hold off;
%saveas(gcf,'./results/shell_map/distribution.png');


% compute ball coordinates for cell coordinates
r = sqrt(sum(coordinates.^2,2));
theta = acos(coordinates(:,3) ./ r);
phi = atan2(coordinates(:,2),coordinates(:,1));

% compute ball coordinates for landmark
rL = sqrt(sum(landmark.^2,2));
thetaL = acos(landmark(:,3) ./ rL);
phiL = atan2(landmark(:,2),landmark(:,1));

% compute ball coordinates for all coordinates
rAll = sqrt(sum(all_coords.^2,2));
thetaAll = acos(all_coords(:,3) ./ rAll);
phiAll = atan2(all_coords(:,2),all_coords(:,1));

% compute shell thickness
thickness = interest_area / number_of_layers;

% set range for angles
top = [0, pi/2, -pi, pi];
front = [0, pi, -pi, 0];
back = [0, pi, 0, pi];
left = [0, pi, pi/2, -pi/2];
right = [0, pi, -pi/2, pi/2];

% set view angles
view_angles = [-30, 30; ...
  -50, 30; ...
  -150,30; ...
  -50, 30; ...
  130, 30;];


view_params = cat(1,top,front,back,left,right);
accumulator = zeros(cat(2,[samples samples],number_of_layers+1,size(view_params,1)));
accumulatorL = zeros(cat(2,[samples samples],size(view_params,1)));

statistics = zeros(5,number_of_layers);

for current_view=1:size(view_params,1)
  
  theta_start = view_params(current_view,1); theta_stop = view_params(current_view,2);
  phi_start = view_params(current_view,3); phi_stop = view_params(current_view,4);
  
  %[t, p] = meshgrid(linspace(theta_start,theta_stop,samples), ...
  %  mod(linspace(pi,abs(phi_stop - phi_start) + pi,samples) + phi_start, 2*pi+0.001) - pi ...
  % );
  
  % Landmark
  if (phi_start < phi_stop)
    valid_points_L = (rL >= 1-thickness & rL < 1+thickness ...
      & thetaL >= theta_start & thetaL <= theta_stop ...
      & phiL >= phi_start & phiL <= phi_stop);
    
    c1 = round( (thetaL(valid_points_L) - theta_start) * (samples-1) / ( theta_stop - theta_start ) + 1);
    c2 = round( (phiL(valid_points_L) - phi_start) * (samples-1) / (phi_stop - phi_start) + 1);
  else
    valid_points_L = find(rL >= 1-thickness & rL < 1+thickness ...
      & thetaL >= theta_start & thetaL <= theta_stop ...
      & abs(phiL) >= phi_start);
    
    c1 = round( (thetaL(valid_points_L) - theta_start) * (samples-1) / ( theta_stop - theta_start ) + 1);
    c2 = zeros(size(c1));
    valid2 = phiL(valid_points_L) > 0;
    valid3 = phiL(valid_points_L) < 0;
    c2( valid2 ) = round( (phiL(valid_points_L(valid2)) - phi_start) * (samples-1) / pi + 1);
    c2( valid3 ) = round( (phiL(valid_points_L(valid3)) + 3*pi/2) * (samples-1) / pi + 1);
    
    tmp = zeros(size(landmark,1),1);
    tmp(valid_points_L) = 1;
    valid_points_L = logical(tmp);
    %valid_points_L = length(c1);
  end
  for i=1:length(c1)
    accumulatorL(c1(i),c2(i),current_view) = min(accumulatorL(c1(i),c2(i),current_view) + 1,1);
  end
  if current_view == 1
    accumulatorL(:,:,1) = circshift(accumulatorL(:,:,1),[0 samples/4]);
  end
  
  %figure; imagesc(accumulatorL(:,:,current_view), [0 max(accumulatorL(:))]);
  %title(['Landmark from view ' num2str(current_view)]);
  %saveas(gcf,['./results/shell_map/landmark_view=' num2str(current_view) '.png']);
  
  %%%%%
  
  
  % Heatmap
  layer=1;
  for shell=1-interest_area:thickness:1
    
    if (phi_start < phi_stop)
      valid_points = r >= shell & r < shell+thickness ...
        & theta >= theta_start & theta <= theta_stop ...
        & phi >= phi_start & phi <= phi_stop;
      
      c1 = round( (theta(valid_points) - theta_start) * (samples-1) / ( theta_stop - theta_start ) + 1);
      c2 = round( (phi(valid_points) - phi_start) * (samples-1) / (phi_stop - phi_start) + 1);
    else
      valid_points = find(r >= shell & r < shell+thickness ...
        & theta >= theta_start & theta <= theta_stop ...
        & abs(phi) >= phi_start);
      
      c1 = round( (theta(valid_points) - theta_start) * (samples-1) / ( theta_stop - theta_start ) + 1);
      %c2 = round( (phi(valid_points) - phi_start) * (samples-1) / pi + 1);
      c2 = zeros(size(c1));
      valid2 = phi(valid_points) > 0;
      valid3 = phi(valid_points) < 0;
      c2( valid2 ) = round( (phi(valid_points(valid2)) - phi_start) * (samples-1) / pi + 1);
      c2( valid3 ) = round( (phi(valid_points(valid3)) + 3*pi/2) * (samples-1) / pi + 1);
      
      tmp = zeros(size(coordinates,1),1);
      tmp(valid_points) = 1;
      valid_points = logical(tmp);
      %valid_points = length(c1);
    end
    
    statistics(current_view, layer) = sum(valid_points);
    
    %figure; scatter3(coordinates(logical(1-valid_points(:)),1), coordinates(logical(1-valid_points(:)),2), coordinates(logical(1-valid_points(:)),3),36,[0 0 0]);
    %hold on; scatter3(landmark(valid_points_L,1), landmark(valid_points_L,2), landmark(valid_points_L,3),36,[1 0 0]);
    %scatter3(coordinates(valid_points,1), coordinates(valid_points,2), coordinates(valid_points,3),36,[0 1 0]); hold off;
    %view(view_angles(current_view,:));
    %title(['Considered points in layer ' num2str(layer) ' (' num2str(shell) '-' num2str(shell+thickness) ') from view ' num2str(current_view)]);
    %saveas(gcf,['./results/shell_map/consideredPoints_view=' num2str(current_view) '_layer=' num2str(layer) '.png']);
    
    for i=1:length(c1)
      accumulator(c1(i),c2(i),layer,current_view) = accumulator(c1(i),c2(i),layer,current_view) + 1;
    end
    if current_view == 1
      accumulator(:,:,layer,1) = circshift(accumulator(:,:,layer,1),[0 samples/4]);
    end
    
    %figure; imagesc(accumulator(:,:,layer,current_view), [0 max(max(accumulator(:)),1)]);
    %title(['Shell heatmap (polarcoordinates) in layer ' num2str(layer) ' (' num2str(shell) '-' num2str(shell+thickness) ') from view ' num2str(current_view)]);
    %saveas(gcf,['./results/shell_map/cells_view=' num2str(current_view) '_layer=' num2str(layer) '.png']);
    
    
    layer = layer + 1;
  end
  
figure; 
ax1 = axes('Position',[0 0 1 1],'Visible','off');
text(0.05,0.04,'Center','FontSize',26, 'FontWeight', 'bold');
text(0.9,0.04,'Border','FontSize',26, 'FontWeight', 'bold');
ax2 = axes('Position',[0.05 0.1 0.92 0.85]);
plot(ax2,statistics(1,:),'LineWidth',2); xlim([1 number_of_layers+1]);
%figure; plot(statistics(1,:),LineWidth,'2'); 
  
close all;
  
end
