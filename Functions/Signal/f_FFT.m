% Function f_FFT.m
% 
% Description:
% This function computes the FFT of a signal or matrix of signals.
% 
% Inputs:
% pm_ColInMat: input signal or signals (data in columns)
% ps_SampleFreq: data sample frequency
% ps_ZeroMean: set to 1 if the frequency=0 must contain the signal average
% (default: 1)
% ps_TwoSides: set to 1 if the output must contain frequencies from 0 to pi
% or 0 to 2pi (0 to ps_SampleFreq/2 or 0 to ps_SampleFreq) (default: 0)
% 
% Outputs:
% m_ColMatFFT: FFT signal or signals
% v_Freq: frequency array 
% 
% Author: Mario Valderrama
% Date: Oct. 2011
%  
function [m_ColMatFFT v_Freq] = ...
    f_FFT( ...
    pm_ColInMat, ...
    ps_SampleFreq, ...
    ps_ZeroMean, ...
    ps_TwoSides)

    if nargin < 1
        return;
    end
    
    if ~exist('ps_SampleFreq', 'var') || isempty(ps_SampleFreq)
        ps_SampleFreq = 1;
    end
    
    if ~exist('ps_ZeroMean', 'var') || isempty(ps_ZeroMean)
        ps_ZeroMean = 1;
    end
    
    if ~exist('ps_TwoSides', 'var') || isempty(ps_TwoSides)
        ps_TwoSides = 0;
    end    
    
    if size(pm_ColInMat, 1) == 1
        pm_ColInMat = pm_ColInMat(:);
    end
    
    m_ColMatFFT = fft(pm_ColInMat, size(pm_ColInMat, 1));
    if ps_ZeroMean
        m_ColMatFFT = m_ColMatFFT./ size(pm_ColInMat, 1);
    end
    if ~ps_TwoSides
        m_ColMatFFT = m_ColMatFFT(1:floor(size(m_ColMatFFT, 1) / 2) + 1, :);
        v_Freq = (ps_SampleFreq / 2).* linspace(0, 1, size(m_ColMatFFT, 1));
    else
        v_Freq = ps_SampleFreq.* linspace(0, 1, size(m_ColMatFFT, 1));
    end
    v_Freq = v_Freq(:);
end
