%   f_GetIdxPosition.m [As a part of HFO Detection Project]
%   Written by:
%   Miguel G. Navarrete Mejia
%   Electrical Engineering MS candidate
%   UNIVERSIDAD DE LOS ANDES
%   Colombia, 2012
%   mnavarretem@gmail.com

function pst_Pos   = f_GetIdxPosition(pst_Pos,pst_Data)

pst_Pos.s_IdxIni     = f_GetIdx(pst_Pos.s_TimeIni);
pst_Pos.s_IdxEnd     = f_GetIdx(pst_Pos.s_TimeIni + pst_Pos.s_Timelength);

if pst_Pos.s_IdxIni < 1
    pst_Pos.s_IdxIni = 1;
end
    function s_Idx = f_GetIdx(s_Time)
        s_Idx   = numel(pst_Data.v_Time(1):1/pst_Data.s_Sampling:s_Time);
    end

end