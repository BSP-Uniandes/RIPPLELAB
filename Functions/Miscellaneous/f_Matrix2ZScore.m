% function f_Matrix2ZScore.m
% 
function m_ZScoreMat = ...
    f_Matrix2ZScore(...
    pm_InMatrix, ...
    ps_FirstIndRef, ...
    ps_LastIndRef)

    if nargin < 1
        error('[f_Matrix2ZScore] - ERROR: bad number of parameters!')
    end

    m_ZScoreMat = pm_InMatrix;
    
    if ~exist('ps_FirstIndRef', 'var') || isempty(ps_FirstIndRef)
        ps_FirstIndRef = 1;
    end
    if ~exist('ps_LastIndRef', 'var') || isempty(ps_LastIndRef)
        ps_LastIndRef = size(m_ZScoreMat, 2);
    end
    
    if ps_FirstIndRef < 1
        ps_FirstIndRef = 1;
    end
    if ps_LastIndRef > size(m_ZScoreMat, 2);
        ps_LastIndRef = size(m_ZScoreMat, 2);
    end

    clear v_Mean v_Std
    v_Mean = mean(m_ZScoreMat(:, ps_FirstIndRef:ps_LastIndRef), 2);
    v_Std = std(m_ZScoreMat(:, ps_FirstIndRef:ps_LastIndRef), 0, 2);
    
    m_ZScoreMat = m_ZScoreMat - repmat(v_Mean, 1, size(m_ZScoreMat, 2));
    m_ZScoreMat = m_ZScoreMat./ repmat(v_Std, 1, size(m_ZScoreMat, 2));
end
