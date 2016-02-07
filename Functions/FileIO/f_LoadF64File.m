function v_Data = f_LoadF64File(pstr_FileName, ps_FirstIndex, ps_LastIndex)

    if nargin < 1
        return;
    end
    
    s_FirstIndex = 1;
    s_LastIndex = -1;
    if nargin >= 2 && ~isempty(ps_FirstIndex)
        s_FirstIndex = ps_FirstIndex;
    end    
    if nargin >= 3 && ~isempty(ps_LastIndex)
        s_LastIndex = ps_LastIndex;
    end  
    
    clear v_Data;
    s_Size = (s_LastIndex - s_FirstIndex) + 1;
    if s_FirstIndex < 1 || (s_LastIndex > 0 && s_Size < 1)
        return;
    end
    s_File = fopen(pstr_FileName, 'r');
    if s_File == -1
        return;
    end
    if s_FirstIndex > 1
        fseek(s_File, 8 * (s_FirstIndex - 1), 'bof');
    end
    if s_LastIndex > 0
        v_Data = fread(s_File, s_Size, 'float64');
    else
        v_Data = fread(s_File, 'float64');
    end
    fclose(s_File);
end

