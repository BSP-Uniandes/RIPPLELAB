% f_GetSignalsNico
% 
function [m_EEGSig m_ECGSig m_RespSig] = ...
    f_GetSignalsNico( ...
    pstr_FullPath, ...
    pstr_EEGSigStr, ...
    pstr_AveStr, ...
    pstr_ECGSigStr, ...
    pstr_RespSigStr, ...
    ps_FirstSam, ...
    ps_LastSam, ...
    ps_ScaleData)

    
    if nargin < 2
        error('[f_GetSignalsNico] - ERROR: bad number of arguments!')
    end
    
    if ~exist('pstr_AveStr', 'var')
        pstr_AveStr = [];
    end
    if ~exist('pstr_ECGSigStr', 'var')
        pstr_ECGSigStr = [];
    end
    if ~exist('pstr_RespSigStr', 'var')
        pstr_RespSigStr = [];
    end
    if ~exist('ps_FirstSam', 'var')
        ps_FirstSam = [];
    end
    if ~exist('ps_LastSam', 'var')
        ps_LastSam = [];
    end  
    if ~exist('ps_ScaleData', 'var') || isempty(ps_ScaleData)
        ps_ScaleData = 1;
    end
    
    if isempty(pstr_EEGSigStr) && isempty(pstr_ECGSigStr) && ...
            isempty(pstr_RespSigStr)
        display('[f_GetSignalsNico] - ERROR: no signals to load!');
        return;
    end
    
%     if ~exist(pstr_FullPath, 'file')
%         error(['[f_GetSignalsNico] - ERROR: the following file does not exist: ' ...
%             pstr_FullPath]);
%     end
    
    if strcmpi(pstr_FullPath(end - 3:end), 'data')
        s_IsBinType = 0;
        str_FullBniPath = sprintf('%s.head', pstr_FullPath(1:(end - 5)));
    else
        s_IsBinType = 1;
        if pstr_FullPath(end) == 'g'
            str_FullBniPath = sprintf('%s.bni', pstr_FullPath(1:(end - 4)));
        else
            str_FullBniPath = sprintf('%s.bni', pstr_FullPath);
        end
    end
    
%     if ~exist(str_FullBniPath, 'file')
%         error(['[f_GetSignalsNico] - ERROR: the following file does not exist: ' ...
%             str_FullBniPath]);
%     end
    
    [~, str_FileNamePrefix] = fileparts(pstr_FullPath);
    str_TempEEGFileNamePrefix = sprintf('%s_~eeg~temp~nico~mat', ...
        str_FileNamePrefix);
    str_TempEEGFileName = [];
%     str_TempEEGFileName = '~eeg~temp~nico~mat.tmp';
    str_TempECGFileName = '~ecg~temp~nico~mat.tmp';
    str_TempRespFileName = '~resp~temp~nico~mat.tmp';
    
    [str_BniSignalsStr s_BniSigNum s_BniScale] = f_GetBniSignals(str_FullBniPath, ...
        s_IsBinType);
    
    clear v_EEGSigCell v_BniSigCell v_ECGSigCell v_RespSigCell
    v_BniSigCell = f_GetSignalNamesArray(str_BniSignalsStr);
    if ~isempty(pstr_EEGSigStr)
        v_EEGSigCell = f_GetSignalNamesArray(pstr_EEGSigStr);
    else
        v_EEGSigCell = [];
    end
    if ~isempty(pstr_ECGSigStr)
        v_ECGSigCell = f_GetSignalNamesArray(pstr_ECGSigStr);
    else
        v_ECGSigCell = [];
    end
    if ~isempty(pstr_RespSigStr)
        v_RespSigCell = f_GetSignalNamesArray(pstr_RespSigStr);
    else
        v_RespSigCell = [];
    end

    s_MaxElem = f_MatrixMaxElemNum() / 2;
    s_MaxElem = floor(s_MaxElem / s_BniSigNum) * s_BniSigNum;

    clear v_AveIndices
    if ~isempty(pstr_AveStr)
        clear v_AveCell
        v_AveCell = f_GetSignalNamesArray(pstr_AveStr);
        v_AveIndices = zeros(1, s_BniSigNum);
        s_CounterSig = 0;
        for s_Counter = 1:length(v_BniSigCell)
            for s_Counter1 = 1:length(v_AveCell)
                if ~strcmpi(v_BniSigCell{s_Counter}, v_AveCell{s_Counter1})
                    continue;
                end
                s_CounterSig = s_CounterSig + 1;
                v_AveIndices(s_CounterSig) = s_Counter;
            end
        end
        v_AveIndices = v_AveIndices(1:s_CounterSig);
    end
    
    if isempty(ps_FirstSam)
        s_FirstInd = 1;
    else
        s_FirstInd = (ps_FirstSam - 1) * s_BniSigNum + 1;
    end
    s_Cycles = 0;
    while 1
        s_Cycles = s_Cycles + 1;
        if isempty(ps_LastSam)
            s_LastInd = s_FirstInd + s_MaxElem - 1;
        else
            s_LastInd = ps_LastSam * s_BniSigNum;
            if (s_LastInd - s_FirstInd) + 1 > s_MaxElem
                s_LastInd = s_FirstInd + s_MaxElem - 1;
            end
        end
        clear m_FileSig
        m_FileSig = f_LoadI16File(pstr_FullPath, s_FirstInd, s_LastInd);
        s_FirstInd = s_LastInd + 1;
        %::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
%         if mod(m_FileSig, s_BniSigNum) ~= 0
%             s_Temp      = floor(m_FileSig/s_BniSigNum);
%             m_FileSig   = m_FileSig(1:s_Temp * s_BniSigNum);
%             clear s_Temp
%         end
        %::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
        m_FileSig = reshape(m_FileSig, s_BniSigNum, []);
        if ps_ScaleData
            m_FileSig = m_FileSig.* s_BniScale;
        end

        clear v_Ave
        if exist('v_AveIndices', 'var')
            v_Ave = mean(m_FileSig(v_AveIndices, :));
        else
            v_Ave = [];
        end
        
        clear m_EEGSig
        if ~isempty(v_EEGSigCell)
            m_EEGSig = f_GetMatrixSig(m_FileSig, v_BniSigCell, ...
                v_EEGSigCell, v_Ave);
        else
            m_EEGSig = [];
        end
        
        clear m_ECGSig
        if ~isempty(v_ECGSigCell)
            m_ECGSig = f_GetMatrixSig(m_FileSig, v_BniSigCell, ...
                v_ECGSigCell, []);
        else
            m_ECGSig = [];
        end
    
        clear m_RespSig
        if ~isempty(v_RespSigCell)
            m_RespSig = f_GetMatrixSig(m_FileSig, v_BniSigCell, ...
                v_RespSigCell, []);
        else
            m_RespSig = [];
        end
        
        if numel(m_FileSig) < s_MaxElem && s_Cycles <= 1
            break;
        end
        
        s_Append = 0;
        if s_Cycles > 1
            s_Append = 1;
        end
        if ~isempty(m_EEGSig)
            if isempty(str_TempEEGFileName)
                s_ImgCounter = 1;
                str_TempEEGFileName = sprintf('%s.%03d.tmp', ...
                    str_TempEEGFileNamePrefix, s_ImgCounter);
                while exist(str_TempEEGFileName, 'file')
                    s_ImgCounter = s_ImgCounter + 1;
                    str_TempEEGFileName = sprintf('%s.%03d.tmp', ...
                        str_TempEEGFileNamePrefix, s_ImgCounter);
                end
            end
            
            f_SaveF64File(m_EEGSig(:), str_TempEEGFileName, [], [], s_Append);
        end
        if ~isempty(m_ECGSig)
            f_SaveF64File(m_ECGSig(:), str_TempECGFileName, [], [], s_Append);
        end
        if ~isempty(m_RespSig)
            f_SaveF64File(m_RespSig(:), str_TempRespFileName, [], [], s_Append);
        end
        clear m_EEGSig m_ECGSig m_RespSig
        
        if numel(m_FileSig) < s_MaxElem
            break;
        end        
    end
    
    clear m_FileSig v_Ave
    
    if s_Cycles > 1
        clear m_EEGSig m_ECGSig m_RespSig
        m_EEGSig = [];
        m_ECGSig = [];
        m_RespSig = [];

        if ~isempty(v_EEGSigCell)
            m_EEGSig = f_LoadF64File(str_TempEEGFileName);
            delete(str_TempEEGFileName);
            m_EEGSig = reshape(m_EEGSig, length(v_EEGSigCell), []);
        end
        
        if ~isempty(v_ECGSigCell)
            m_ECGSig = f_LoadF64File(str_TempECGFileName);
            delete(str_TempECGFileName);
            m_ECGSig = reshape(m_ECGSig, length(v_ECGSigCell), []);
        end

        if ~isempty(v_RespSigCell)
            m_RespSig = f_LoadF64File(str_TempRespFileName);
            delete(str_TempRespFileName);
            m_RespSig = reshape(m_RespSig, length(v_RespSigCell), []);
        end
    end

return;


function m_Sigs = ...
    f_GetMatrixSig(pm_OrgSignals, pv_BniSigs, pv_CurrSigs, pv_Ave)

    clear m_Sigs
    m_Sigs = zeros(length(pv_CurrSigs), size(pm_OrgSignals, 2));
    for s_Counter = 1:length(pv_CurrSigs)
        str_Sig1 = pv_CurrSigs{s_Counter};
        str_Sig2 = [];
        s_SigInd = 0;
        for s_Counter1 = 1:length(pv_BniSigs)
            if ~strcmpi(pv_BniSigs{s_Counter1}, str_Sig1)
                continue;
            end
            s_SigInd = s_Counter1;
            break;
        end

        if s_SigInd <= 0
            [str_Sig1 str_Sig2] = strtok(pv_CurrSigs{s_Counter}, '-');
            s_SigInd = 0;
            for s_Counter1 = 1:length(pv_BniSigs)
                if ~strcmpi(pv_BniSigs{s_Counter1}, str_Sig1)
                    continue;
                end
                s_SigInd = s_Counter1;
                break;
            end

            if s_SigInd <= 0
                continue;
            end
        end
        
        m_Sigs(s_Counter, :) = pm_OrgSignals(s_SigInd, :);
        if isempty(str_Sig2)
            if ~isempty(pv_Ave)
                m_Sigs(s_Counter, :) = m_Sigs(s_Counter, :) - pv_Ave;
            end
        else
            str_Sig2 = str_Sig2(2:end);
            s_SigInd = 0;
            for s_Counter1 = 1:length(pv_BniSigs)
                if ~strcmpi(pv_BniSigs{s_Counter1}, str_Sig2)
                    continue;
                end
                s_SigInd = s_Counter1;
                break;
            end

            if s_SigInd <= 0
                m_Sigs(s_Counter, :) = zeros(1, size(pm_OrgSignals, 2));
                continue;
            end

            m_Sigs(s_Counter, :) = m_Sigs(s_Counter, :) - ...
                pm_OrgSignals(s_SigInd, :);
        end
    end
    
return;
