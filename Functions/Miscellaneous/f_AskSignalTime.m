%   f_AskSignalTime.m [Part of HFO Detection Project]
%   Written by:
%   Miguel G. Navarrete Mejia
%   Electrical Engineering MS candidate
%   UNIVERSIDAD DE LOS ANDES
%   Colombia, 2012
%   mnavarretem@gmail.com

function [s_TotalTimeMin s_TotalSamples] = f_AskSignalTime(ps_SampleRate,...
                                        ps_Bytes,ps_Channels)
    % Ask for an Initial and final sample
    
    s_SampligTime = 1/ps_SampleRate;
    s_TotalSamples = ps_Bytes/(ps_Channels*2);
    s_TotalTimeSec = (s_TotalSamples-1)*s_SampligTime;
    s_TotalTimeMin = s_TotalTimeSec/60; 
        
end