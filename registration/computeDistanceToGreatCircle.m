function regression = computeDistanceToGreatCircle( p_gc, v_gc, data )
%COMPUTEDISTANCETOGREATCIRCLE Summary of this function goes here
%   Detailed explanation goes here

% we are interested in computing the minimal distance of each point to the
% given great circle by exploiting the following rule on spheres:
%
% sin distance = sin c * sin beta
%

%great_circle = geodesicFun(p_gc, v_gc);

regression = 0;
for point = 1:size(data,2)

    % compute distance c between points
    c = sphericalDistancePoints(p_gc, data(:,point));
    
    % compute great circle through p_gc and data point
    [gc, tangential] = computeGreatCircle(p_gc, data(:,point));
    
    % compute angle between points
    beta = acos(tangential' * v_gc); %/ (2*pi) * 360;
    
    
    distance = asin( sin(c) * sin(beta));
    if(distance <= 0)
        stop = 1;
        %dc = gc(0:0.01:2*pi);
        %figure(1); scatter3(p_gc(1), p_gc(2), p_gc(3)); hold on; scatter3(data(1,point), data(2,point), data(3,point)); plot3(dc(1,:), dc(2,:), dc(3,:)); 
        %arrow(p_gc, p_gc + tangential, 'Color', 'g');
        %xlim([-1,1]);
        %ylim([-1,1]);
        %zlim([-1,1]);
        %hold off
    end
    
    regression = regression + distance;

end

end

