function v_Data = ...
    f_LoadI16File( ...
    pstr_FileName, ...
    ps_FirstIndex, ...
    ps_LastIndex, ...
    ps_FileHdl)
% 
% Function: f_LoadI16File.m
% 
% Description: 
% This function loads an integer signal from a file where each data value
% is stored in 2 bytes.
% 
% Inputs:
% pstr_FileName: name of the file
% ps_FirstIndex (optional): number of the first sample to load from.
% Default: 1
% ps_LastIndex (optional): number of the last sample to load to. Default:
% end of the file
% ps_FileHdl (optional): handle of an existing file when the file already
% open. In this case the fopen will be replaced by a fseek in order to move
% the file pointer to the beginning of the file.
% 
% Outputs:
% v_Data: loaded data
% 
% MATLAB Version: R2007b
% 
% Team: LENA
% Author: Mario Valderrama
%
    if nargin < 1
        error('[f_RWaveDet] - ERROR: bad number of inputs!');
    end

    s_FirstIndex = 1;
    s_LastIndex = -1;
    if nargin >= 2 && ~isempty(ps_FirstIndex)
        s_FirstIndex = ps_FirstIndex;
    end    
    if nargin >= 3 && ~isempty(ps_LastIndex)
        s_LastIndex = ps_LastIndex;
    end    
    
    if ~exist('ps_FileHdl', 'var')
        ps_FileHdl = [];
    end
    
    clear v_Data;
    s_Size = (s_LastIndex - s_FirstIndex) + 1;
    if s_FirstIndex < 1 || (s_LastIndex > 0 && s_Size < 1)
        return;
    end
    if ~isempty(ps_FileHdl)
        s_File = ps_FileHdl;
        fseek(s_File, 0, 'bof');
    else
        s_File = fopen(pstr_FileName, 'r');
        if s_File == -1
            return;
        end
    end
    if s_FirstIndex > 1
        fseek(s_File, 2 * (s_FirstIndex - 1), 'bof');
    end
    if s_LastIndex > 0
        v_Data = fread(s_File, s_Size, 'int16');
    else
        v_Data = fread(s_File, 'int16');
    end
    if isempty(ps_FileHdl)
        fclose(s_File);
    end
end