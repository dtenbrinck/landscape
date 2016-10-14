function [c,ceq] = nonlconSR_new(C)
% C is a 3xN matrix with points on the great circle

ceq = zeros(size(C,2)+size(C,2)-2,1);
c = [];

ceq(1:size(C,2)) = sqrt(sum(C.^2,1))-1;

% Because there is a tolerance in the algorithm the vectors sometimes come
% up as not normalized. Then they would produce NaNs. So we will rescale
% them for this purpose
% 
% C = C./repmat(sqrt(sum(C.^2,1)),3,1);
p1 = C(:,1);
% Compute crossproduct of all vectors with p1
% vi = cross(cross(p1,pi),p1);
V = cross(cross(repmat(p1,1,size(C,2)),C),repmat(p1,1,size(C,2)));
% Find first cross product that is not zero. When the cross is zero it is
% an multiplication and can be set as zero at once.
nonzerocross = find(sum(V,1));
V(:,nonzerocross) ...
    = V(:,nonzerocross) ./repmat(sqrt(sum(V(:,nonzerocross) .^2,1)),3,1);
v2 = V(:,nonzerocross(1));

ceq(nonzerocross+size(C,2))...
    = dot(repmat(v2,1,size(nonzerocross,2)),V(:,nonzerocross))-1;

end