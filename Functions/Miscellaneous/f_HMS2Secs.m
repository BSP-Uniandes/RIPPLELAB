%   f_Secs2hms.m [As a part of HFO Detection Project]
%   Written by:
%   Miguel G. Navarrete Mejia
%   Electrical Engineering MS candidate
%   UNIVERSIDAD DE LOS ANDES
%   Colombia, 2012
%   mnavarretem@gmail.com

function v_secs = f_HMS2Secs(pv_HMS)

if ~isvector(pv_HMS) && numel(pv_HMS)~=3
    v_secs	= 0;
    return
end

v_secs  = sum(pv_HMS.*[3600 60 1]);