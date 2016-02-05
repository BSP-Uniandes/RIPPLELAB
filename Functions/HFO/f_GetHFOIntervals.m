%   f_GetHFOIntervals.m [As a part of HFO Detection Project]
%   Written by:
%   Miguel G. Navarrete Mejia
%   Electrical Engineering MS candidate
%   UNIVERSIDAD DE LOS ANDES
%   Colombia, 2012
%   mnavarretem@gmail.com

function v_Intervals = f_GetHFOIntervals(pstr_SignalPath,ps_SignalIdx,pm_Lims)

load(pstr_SignalPath)
pv_Signal       = m_Data(:,ps_SignalIdx); %#ok<NODEF>
clear m_Data

v_Intervals     = cell(size(pm_Lims,1),1);
       
for kk = 1:size(pm_Lims,1)        
    v_Intervals(kk) = {pv_Signal(pm_Lims(kk,1):pm_Lims(kk,2))};
end