function [c,ceq] = normfunc(pv) 
    p = pv(1:3);
    c = [];
    ceq = sqrt(sum(p.^2))-1;
end