function v_SumHMS   = f_AddTimeHMS(pv_HMS1,pv_HMS2)

v_SumHMS	= [0 0 0];

for kk=1:3
    v_SumHMS(kk)    = pv_HMS1(kk) + pv_HMS2(kk);
    
    if kk==2 && (pv_HMS1(2)+pv_HMS2(2)) >= 60
        v_SumHMS(1) = v_SumHMS(1)+1;  %This adds 1 hour
        v_SumHMS(2) = v_SumHMS(2)-60;	%this gives the correct minutes
    end
        
    if kk==3 && (pv_HMS1(3)+pv_HMS2(3)) >= 60 
        v_SumHMS(2) = v_SumHMS(2)+1;  %This adds 1 min
        v_SumHMS(3) = v_SumHMS(3)-60; %This gives the correct seconds
    end
end

