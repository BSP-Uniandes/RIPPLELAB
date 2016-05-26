
% function f_Matrix2RelAmplitud.m
% 
function m_RelPowAmp = ...
    f_Matrix2RelAmplitud(...
    pm_InMatrix)

    if nargin < 1
        error('[f_Matrix2RelAmplitud] - ERROR: bad number of parameters!')
    end

    m_RelPowAmp = pm_InMatrix;
    
    clear v_SumArray
    v_SumArray = sum(pm_InMatrix, 2);
    
    for s_Counter = 1:size(m_RelPowAmp, 1)
        m_RelPowAmp(s_Counter, :) = m_RelPowAmp(s_Counter, :)./ ...
                                    v_SumArray(s_Counter);
    end
end
