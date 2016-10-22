function [vstar,Tstar] = evaluateDirection(pstar,vstar,Tstar,v0)
if pstar(3)>0
    if sign(vstar(1))== sign(v0(1))
        vstar = -vstar;
        disp('Changed vstar direction')
        % When vstar changes direction Tstar changes too
        Tstar = -Tstar;
    end
elseif pstar(3)<=0
    if sign(vstar(1))~=sign(v0(1))
        vstar = -vstar;
        disp('Changed vstar direction')
        % When vstar changes direction Tstar changes too
        Tstar = -Tstar;
    end
end
end