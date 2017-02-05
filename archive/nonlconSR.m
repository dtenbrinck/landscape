function [c,ceq] = nonlconSR(pv) 
    ceq = [0;0];
    p = pv(1:3);
    v = pv(4:6);
    c = [];
    ceq(1) = sqrt(sum(p.^2))-1;
    ceq(2) = p'*v;
end