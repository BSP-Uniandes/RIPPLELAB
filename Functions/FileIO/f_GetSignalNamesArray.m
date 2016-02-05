% f_GetSignalNamesArray(pstr_ChannStr)
% 
function [v_SignalNamesCell] = ...
    f_GetSignalNamesArray(...
    pstr_SignalStr, ...
    ps_MakeUpper)

    if nargin < 1
        return;
    end
    
    if ~exist('ps_MakeUpper', 'var') || isempty(ps_MakeUpper)
        ps_MakeUpper = 1;
    end
    
    clear v_SignalNamesCell
    v_SignalNamesCell = [];
    str_Remain = pstr_SignalStr;
    while true
        [str_Token, str_Remain] = strtok(str_Remain, ',');
        
        if length(str_Token) < 1
            break;
        end
        clear v_TempCell
        v_TempCell = v_SignalNamesCell;
        s_NewSize = length(v_TempCell) + 1;
        clear v_SignalNamesCell
        v_SignalNamesCell = cell(1, s_NewSize);
        v_SignalNamesCell(1:s_NewSize - 1) = v_TempCell;
        if ps_MakeUpper
            str_Token = upper(str_Token);
        end
        v_SignalNamesCell(s_NewSize) = {str_Token};
        
        if isempty(str_Remain)
            break;
        end
    end
    clear v_TempCell
    
return;