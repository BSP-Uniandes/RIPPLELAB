function f_SaveF64File(pv_Data, pstr_FileName, ...
    ps_FirstIndex, ps_LastIndex, ps_Append)

    if nargin < 2
        return;
    end
    
    s_FirstIndex = 1;
    s_LastIndex = length(pv_Data);
    s_Append = 0;
    if nargin >= 3 && ~isempty(ps_FirstIndex)
        s_FirstIndex = ps_FirstIndex;
    end    
    if nargin >= 4 && ~isempty(ps_LastIndex)
        s_LastIndex = ps_LastIndex;
    end  
    if nargin >= 5 && ~isempty(ps_Append)
        s_Append = ps_Append;
    end  
    
    if s_Append
        s_File = fopen(pstr_FileName, 'a');
    else
        s_File = fopen(pstr_FileName, 'w');
    end
    if s_File == -1
        return;
    end
    fwrite(s_File, pv_Data(s_FirstIndex:s_LastIndex), 'double');
    fclose(s_File);
end

