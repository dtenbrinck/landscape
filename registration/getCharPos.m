function [pnew,vnew,regLine] = getCharPos(p,v,regData,type)
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

%% MAIN CODE %%

% -- Compute original regression line -- %
T = 0:0.01:2*pi;
G = geodesicFun(p,v);
rL = G(T);

%-- Compute the nearest points on the regression line -- %
ind = ones(1,size(regData,2));

% Compute the smallest difference of each regData point to the
% regressionLine. ind is the position on the regression line.
for i=1:size(regData,2)
    diffSum = ...
      abs(rL(1,:)-ones(1,size(rL,2))*regData(1,i))...
    + abs(rL(2,:)-ones(1,size(rL,2))*regData(2,i))...
    + abs(rL(3,:)-ones(1,size(rL,2))*regData(3,i));
    [~,ind(i)] = min(diffSum);
    
end

% -- Rearrange the indices into the interval -314:314 -- %
ind(ind>629/2) = ind(ind>629/2)-629;

% -- Find the weight of the indices -- %
indweight = sum(ind)/size(ind,2);

% -- Rearrange the indices -- %
ind = ind-indweight;

% -- Get the characteristic point depending on the selected type -- %
charInd = 0;    %This is a trick so we don't need the if for type 'weight'.
if strcmp(type,'head')
    charInd = max(ind);
elseif strcmp(type,'tail')
    charInd = min(ind);
elseif strcmp(type,'middle')
    charInd = (min(ind)+(max(ind)-min(ind))/2);
end

% -- Rearrange back to the original interval
charInd = charInd+indweight;
charInd(charInd<0) = charInd(charInd<0)+629;
charInd = round(charInd);

% -- Compute the coordinates of the new p -- %
pnew = rL(:,charInd);

if sum(pnew==p)/3
    Rp = eye(3);
else
    % -- Compute the corresponding v to the new p -- %
    V = cross(p,pnew);
    s = norm(V);
    c = p'*pnew;
    V = [0,-V(3),V(2);V(3),0,-V(1);-V(2),V(1),0];
    
    % Compute the rotation matrix of p
    Rp = eye(3)+V+V*V*(1-c)/s^2;
end
% Rotate v
vnew = Rp*v;

% -- Compute the new regression line for pnew and vnew - %
G = geodesicFun(pnew,vnew);
regLine = G(T);
end

