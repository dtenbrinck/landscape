function [c,ceq] = nonlconSR_new2(pvT)
% C is a 3xN matrix with points on the great circle

ceq = [0;0;0];

p = pvT(1:3);
v = pvT(4:6);
%T = pvT(7:size(pvT,1))';
ceq(1) = abs(p'*v);
ceq(2) = abs(norm(p)-1);
ceq(3) = abs(norm(v)-1);
c = [];


end