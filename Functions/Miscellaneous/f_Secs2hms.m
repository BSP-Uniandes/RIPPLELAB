%   f_Secs2hms.m [As a part of HFO Detection Project]
%   Written by:
%   Miguel G. Navarrete Mejia
%   Electrical Engineering MS candidate
%   UNIVERSIDAD DE LOS ANDES
%   Colombia, 2012
%   mnavarretem@gmail.com

function v_HMS = f_Secs2hms(ps_secs)

if ~isscalar(ps_secs) && ~isreal(ps_secs)
    v_HMS   = [0 0 0];
    return
end

s_hh    = 0;
s_mm    = 0;

if ps_secs > 3599.99
    s_hh    = floor(ps_secs/3600);
    ps_secs = ps_secs - s_hh * 3600;
end

if ps_secs >= 59.9
    s_mm    = floor(ps_secs/60);
    ps_secs = ps_secs - s_mm * 60;
    
    if ps_secs >= 59.99
        s_mm    = s_mm + 1;
        ps_secs = abs(ps_secs - 60);
    end
end

v_HMS = [s_hh s_mm ps_secs];

end