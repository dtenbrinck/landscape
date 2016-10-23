function [pnew,vnew] = getCharPos_daniel(p,v,coordinates,type)
%GETCHARPOS: This function will give you the position of the characteristic
%depanding on the input type. It can give you the head, tail, weight and
%middle (between head and tail) position. It will also compute the new
%vector on this point and the new regression line
%% INPUT: %%
% p:        pstar of the regression line.
% v:        vstar of the regression line.
% regData:  The points of the segmentation of the embryo projected onto the
%           sphere.
% type:     String with the values:
%           'head':     set characteristic to head
%           'tail':     set characteristic to tail
%           'weight':   set characteristic to  the weight of nearest points
%           'middle':     set characteristic to middle between head and tail
%% OUTPUT: %%
% pnew:     The new p corresponding to the selected type.
% vnew:     The new v corresponding to the new p.
% regLine:  The new regression line corresponding to the new p and v.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% PARAMETER
weightingRatio = 0.5; % For 0.5 it will pick the midpoint on the line, 
                        % For <0.5 it will pick a point nearer to the tail
                        % For >0.5 it will pick a point nearer to the head
                        % 0.45 is a good ratio

%% MAIN CODE %%

% -- Compute points on regressionline for Tstar -- %
G = geodesicFun(p,v);
T = linspace(0,2*pi,700);
rL = G(T);
values = zeros(1,numel(T));

threshold = 0.1;

for t=1:numel(T)
   
    for point = 1:size(coordinates,2)
        if sphericalDistancePoints(rL(:,t),coordinates(:,point)) < threshold
            values(t) = 1;
            break; 
        end
        
    end
    
end

cumulator = zeros(1,numel(T));
for t=1:2*numel(T)
   
    index = mod(t-1,numel(T))+1;
   if values(index) == 0
       cumulator(index) = cumulator(mod(t-2,numel(T))+1) + 1;
   end
    
end

max_index = find(cumulator == max(cumulator(:)));

begin_index = mod(max_index, numel(T)) + 1;

end_index = begin_index;
for t=begin_index-1:-1:begin_index-numel(T)
  index = mod(t-1,numel(T))+1;
    
  if values(index) > 0
      end_index = index;
      break;
  end

end

if end_index < begin_index
    end_index = end_index + numel(T);
end

new_index =  mod( round(end_index * weightingRatio + begin_index *  (1-weightingRatio)) - 1, numel(T)) + 1;
pnew = rL(:,new_index);


 V = cross(p,pnew);
    s = norm(V);
    c = p'*pnew;
    V = [0,-V(3),V(2);V(3),0,-V(1);-V(2),V(1),0];
    % Compute the rotation matrix of p
    Rp = eye(3)+V+V*V*(1-c)/s^2;
% Rotate v
vnew = Rp*v;

% for debugging
%visualizeRegression(coordinates', pnew, vnew, pnew, vnew)

% -- Compute the angles between the neighbours -- %
% angles = real(acos(dot(rL,circshift(rL,1,2))));
% 
% % Get the neighbours with the greatest angle between them
% [~,indi] = max(angles(:));
% 
% % Compute new G for the point p=rL(:,indi);
% % Map pstar onto refpstar
% b = cross(p,rL(:,indi));
% s = norm(b);
% c = p'*rL(:,indi);
% V = [0,-b(3),b(2);b(3),0,-b(1);-b(2),b(1),0];
% % 
% Rp_indi = eye(3)+V+V*V*(1-c)/s^2;
% v_indi = Rp_indi*v;
% 
% % New regressionline from rL(:,indi) with equidistant points
% G = geodesicFun(rL(:,indi),v_indi);
% ending = 2*pi-t(indi)+t(indi-1);
% T = 0:ending/(size(t,2)-1):ending;
% rL = G(T);
% 
% % -- Compute coordinates of the new p -- %
% if strcmp(type,'tail')
%     pnew = rL(:,1);
% elseif strcmp(type,'head')
%     pnew = rL(:,size(Tstar,2));
% elseif strcmp(type,'middle')
%     t = T(round(size(Tstar,2)*weightingRatio));
%     pnew = G(t);
% end
% 
% if sum(pnew==p)/3
%     Rp = eye(3);
% else
%     % -- Compute the corresponding v to the new p -- %
%     V = cross(p,pnew);
%     s = norm(V);
%     c = p'*pnew;
%     V = [0,-V(3),V(2);V(3),0,-V(1);-V(2),V(1),0];
%     
%     % Compute the rotation matrix of p
%     Rp = eye(3)+V+V*V*(1-c)/s^2;
% end
% % Rotate v
% vnew = Rp*v;
end

