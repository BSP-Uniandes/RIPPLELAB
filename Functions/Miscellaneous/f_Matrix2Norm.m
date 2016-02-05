% function f_Matrix2Norm.m
% 
function m_NormeMat = ...
    f_Matrix2Norm(...
    pm_InMatrix, ...
    ps_UseGlobalLims)

    if nargin < 1
        error('[f_Matrix2Norm] - ERROR: bad number of parameters!')
    end
    
    if ~exist('ps_UseGlobalLims', 'var') || isempty(ps_UseGlobalLims)
        ps_UseGlobalLims = 0;
    end

    m_NormeMat = pm_InMatrix;
    
    clear v_Min v_Max
    if ps_UseGlobalLims
        v_Min = min(m_NormeMat(:)) * ones(size(pm_InMatrix, 1), 1);
        v_Max = max(m_NormeMat(:)) * ones(size(pm_InMatrix, 1), 1);
    else
        v_Min = min(m_NormeMat, [], 2);
        v_Max = max(m_NormeMat, [], 2);
    end
    
    m_NormeMat = m_NormeMat - repmat(v_Min, 1, size(m_NormeMat, 2));
    m_NormeMat = m_NormeMat./ repmat(abs(v_Max - v_Min), 1, size(m_NormeMat, 2));
end
