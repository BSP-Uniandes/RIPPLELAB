% f_GetBniSignals.m

function [str_SignalsStr s_SigNum s_Scale s_SRate v_IniTime] = ...
    f_GetiSignalHeader( ...
    p_strBniName, ps_IsBinType)

    if nargin < 1
        return;
    end
    
    if ~exist('ps_IsBinType', 'var') || isempty(ps_IsBinType)
        
        ps_IsBinType = 0;
        
    end

    if ~ps_IsBinType
        
        str_Time        = 'TIME';
        str_NChanFile   = 'NCHANFILE';
        str_UVPerBit    = 'UVPERBIT';
        str_MontageRaw  = 'MONTAGERAW';
        str_Rate        = 'RATE';
        str_Delimiter   = ' ';
        
    else
        
        str_Time        = 'START_TS';
        str_NChanFile   = 'NUM_CHANNELS';
        str_UVPerBit    = 'CONVERSION_FACTOR';
        str_MontageRaw  = 'ELEC_NAMES';
        str_Rate        = 'SAMPLE_FREQ';
        str_Delimiter   = '=';
        
    end
    
    str_SignalsStr  = [];
    s_SigNum        = [];
    s_Scale         = [];
    v_IniTime       = [];
    
    s_File          = fopen(p_strBniName, 'rt');
    
    if s_File == -1
        
        display(['[f_GetiSignalHeader] - ERROR opening file: %s' p_strBniName])
        return;
        
    end

    str_Line = fgetl(s_File);
    
    while ischar(str_Line)
        
        [str_Token, str_Remain] = strtok(str_Line, str_Delimiter);
        
        if strcmpi(str_Token, str_Time)
            
            [str_Token, str_Remain] = strtok(str_Remain, str_Delimiter);
            
            if ~isempty(str_Remain)
                v_IniTimeTemp = str_Remain;
            else
                v_IniTimeTemp = str_Token;
            end
            
            if ps_IsBinType
                [str_Token, str_Remain] = strtok(v_IniTimeTemp, ' ');
                v_IniTimeTemp = str_Remain(2:end);
            end
            
            v_IniTime   = zeros(1,3);
            for kk=1:3
                [str_Token, v_IniTimeTemp] = strtok(v_IniTimeTemp, ':');
                v_IniTime(kk)           = str2double(str_Token);
            end
            
            
        end
        
        if strcmpi(str_Token, str_NChanFile)
            
            [str_Token, str_Remain] = strtok(str_Remain, str_Delimiter);
            
            if ~isempty(str_Remain)
                s_SigNum = str2double(str_Remain);
            else
                s_SigNum = str2double(str_Token);
            end
            
        end
        
        if strcmpi(str_Token, str_UVPerBit)
            
            [str_Token, str_Remain] = strtok(str_Remain, str_Delimiter);
            
            if ~isempty(str_Remain)
                s_Scale = str2double(str_Remain);
            else
                s_Scale = str2double(str_Token);
            end
            
        end
        
        if strcmpi(str_Token, str_Rate)
            
            [str_Token, str_Remain] = strtok(str_Remain, str_Delimiter);
            
            if ~isempty(str_Remain)
                [str_Token, str_Remain] = strtok(str_Remain, ' ');
                s_SRate = str2double(str_Token);
            else
                s_SRate = str2double(str_Token);
            end
            
        end
        
        if strcmpi(str_Token, str_MontageRaw)
            
            [str_Token, str_Remain] = strtok(str_Remain, str_Delimiter);
            
            if ~isempty(str_Remain)
                str_SignalsStr = strtrim(str_Remain);
            else
                str_SignalsStr = strtrim(str_Token);
            end            
            
            if ps_IsBinType
                
                if str_SignalsStr(1) == '['
                    str_SignalsStr = str_SignalsStr(2:end);
                end
                
                if str_SignalsStr(end) == ']'
                    str_SignalsStr = str_SignalsStr(1:end - 1);
                end
                
            end
            
        end
        
        if ~isempty(s_SigNum) && ~isempty(s_Scale) && ...
                ~isempty(str_SignalsStr) && ~isempty(v_IniTime)
            
            break;

        end
        
        str_Line = fgetl(s_File);
        
    end
    
    fclose(s_File);

return;
