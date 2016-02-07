% f_GetBniSignals.m

function [str_SignalsStr s_SigNum s_Scale] = ...
    f_GetBniSignals( ...
    p_strBniName, ps_IsBinType)

    if nargin < 1
        return;
    end
    
    if ~exist('ps_IsBinType', 'var') || isempty(ps_IsBinType)
        ps_IsBinType = 1;
    end

    if ps_IsBinType
        str_NChanFile = 'NCHANFILE';
        str_UVPerBit = 'UVPERBIT';
        str_MontageRaw = 'MONTAGERAW';
        str_Delimiter = ' ';
    else
        str_NChanFile = 'NUM_CHANNELS';
        str_UVPerBit = 'CONVERSION_FACTOR';
        str_MontageRaw = 'ELEC_NAMES';
        str_Delimiter = '=';
    end
    
    str_SignalsStr = [];
    s_SigNum = [];
    s_Scale = [];
    
    s_File = fopen(p_strBniName, 'r');
    if s_File == -1
        display(['[f_GetBniSignals] - ERROR opening file: ' p_strBniName])
        return;
    end

    str_Line = fgetl(s_File);
    while ischar(str_Line)
        str_Line = fgetl(s_File);
        [str_Token, str_Remain] = strtok(str_Line, str_Delimiter);
        if strcmp(upper(str_Token), str_NChanFile)
            [str_Token, str_Remain] = strtok(str_Remain, str_Delimiter);
            if ~isempty(str_Remain)
                s_SigNum = str2num(str_Remain);
            else
                s_SigNum = str2num(str_Token);
            end
        end
        if strcmp(upper(str_Token), str_UVPerBit)
            [str_Token, str_Remain] = strtok(str_Remain, str_Delimiter);
            if ~isempty(str_Remain)
                s_Scale = str2num(str_Remain);
            else
                s_Scale = str2num(str_Token);
            end
        end
        if strcmp(upper(str_Token), str_MontageRaw)
            [str_Token, str_Remain] = strtok(str_Remain, str_Delimiter);
            if ~isempty(str_Remain)
                str_SignalsStr = strtrim(str_Remain);
            else
                str_SignalsStr = strtrim(str_Token);
            end            
            if ~ps_IsBinType
                if str_SignalsStr(1) == '['
                    str_SignalsStr = str_SignalsStr(2:end);
                end
                if str_SignalsStr(end) == ']'
                    str_SignalsStr = str_SignalsStr(1:end - 1);
                end
            end
        end
        if ~isempty(s_SigNum) && ~isempty(s_Scale) && ~isempty(str_SignalsStr)
            break;
        end
    end
    fclose(s_File);
return;
