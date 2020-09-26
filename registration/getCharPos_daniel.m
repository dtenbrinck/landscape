function [pnew,vnew] = getCharPos_daniel(p,v,coordinates,weightingRatio)
%GETCHARPOS computes the new starting point pnew of the regression line
%given by p and v. pnew will correspond to the desired location on the
%landmark that is calculated from the weighting ratio. 
%% INPUT: %%
% p:        pstar of the regression line.
% v:        vstar of the regression line.
% regData:  The points of the segmentation of the landmark projected onto the
%           sphere.
%% OUTPUT: %%
% pnew:     The new p corresponding to the weighting ratio.
% vnew:     The new v corresponding to the new p.
%% PARAMETER
%weightingRatio         % Ratio that picks a point between the start (0) and the end (1) of the landmark. 
                        % For 0.5 it will pick the midpoint on the line, 
                        % For <0.5 it will pick a point nearer to the start of the landmark
                        % For >0.5 it will pick a point nearer to the end of the landmark
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
%% MAIN CODE %%

% -- Compute points on regression line -- %
G = geodesicFun(p,v); % regression line (great circle)
T = linspace(0,2*pi,2100); % define desired amount of dicrete points on great circle
rL = G(T); % discrete great circle

% -- Goal -- %
% We want to find positions on discrete great circle G(T) with close landmark coordinates.
% These positions will be assigned to value 1. This will give us information where the great 
% circle enters the landmark and where it leaves the landmark.

values = zeros(1,numel(T));

threshold = 0.025; % Heuristic(!!) Defines which distance will still be considered 'close' to landmark. Small values will be more accurate but will not work for landmarks that are not dense enough.

for t=1:numel(T)
   
    for point = 1:size(coordinates,2)
        if sphericalDistancePoints(rL(:,t),coordinates(:,point)) < threshold %check if position on great circle is close to a landmark coordinate
            values(t) = 1; % assign close positions with value 1
            break; 
        end
        
    end
    
end

% -- Goal -- %
% Find the positions on the great circle where it enters and leaves the
% landmark. 
%Problem: Landmark might have some small gaps inside.
%Solution: The 'cumulator' will count how many points lie bewteen a specific position
%and the last recognised position with value 1 (close to landmark). Larger cumulator values correspond 
%to larger gaps in the landmark. The entering point will follow after the largest gap, which is expressed 
%by the highest cumulator value.

cumulator = zeros(1,numel(T));
for t=1:2*numel(T)
   
    index = mod(t-1,numel(T))+1;
   if values(index) == 0
       cumulator(index) = cumulator(mod(t-2,numel(T))+1) + 1;
   end
    
end

max_index = find(cumulator == max(cumulator(:))); 

begin_index = mod(max_index, numel(T)) + 1; %The next index corresponds to the beginning of the landmark

% calculate end point of the landmark
% start from the beginning of the landmark and go backwards through the
% largest gap until find a position with value 1 again. 
end_index = begin_index;
for t=begin_index-1:-1:begin_index-numel(T)
  index = mod(t-1,numel(T))+1;
    
  if values(index) > 0
      end_index = index;
      break;
  end

end

% Index shift might be needed
if end_index < begin_index
    end_index = end_index + numel(T);
end

% -- Calculate pnew and vnew -- %

% calculate pnew to be located at the desired position defined by weightingRatio 
new_index =  mod( round(end_index * weightingRatio + begin_index *  (1-weightingRatio)) - 1, numel(T)) + 1;
pnew = rL(:,new_index);

% calculate vnew corresponding to pnew
 V = cross(p,pnew);
    s = norm(V);
    c = p'*pnew;
    V = [0,-V(3),V(2);V(3),0,-V(1);-V(2),V(1),0];
    % Compute the rotation matrix of p
    Rp = eye(3)+V+V*V*(1-c)/s^2;
% Rotate v
vnew = Rp*v;

end
