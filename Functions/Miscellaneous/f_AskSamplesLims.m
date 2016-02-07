%   f_AskSamplesLims.m [Part of HFO Detection Project]
%   Written by:
%   Miguel G. Navarrete Mejia
%   Electrical Engineering MS candidate
%   UNIVERSIDAD DE LOS ANDES
%   Colombia, 2012
%   mnavarretem@gmail.com

function [ps_SampleIni ps_SampleEnd]= f_AskSamplesLims(ps_SampleRate,...
                                        s_TotalTimeMin,pv_LiMinutes)
    % Ask for an Initial and final sample
    s_SampligTime = 1/ps_SampleRate;
    if (pv_LiMinutes(2)-pv_LiMinutes(1)) == s_TotalTimeMin    
        ps_SampleIni = [];
        ps_SampleEnd = [];
        return
    else
        s_SecIni = pv_LiMinutes(1)*60;
        s_SecEnd = pv_LiMinutes(2)*60;

        s_InpIniMod = mod(s_SecIni,s_SampligTime);
        s_InpEndMod = mod(s_SecEnd,s_SampligTime);

        if s_InpIniMod ~= 0 || s_InpEndMod ~= 0
            s_SecIni = s_SecIni - s_InpIniMod;
            s_SecEnd = s_SecEnd - s_InpEndMod;
        end

        ps_SampleIni = s_SecIni*ps_SampleRate+1;
        ps_SampleEnd = s_SecEnd*ps_SampleRate+1;
    end
    
       
end