function [v_PowSpec v_Freq s_TotalPow] = ...
    f_PowSpec(...
    pv_Sig, ...
    ps_SamRate, ...
    ps_ARMethod, ...
    ps_AROrder)
% 
% Function: f_PowSpec.m
% 
% Description: 
% This function computes the power spectrum of the input signal.
% 
% Inputs:
% pv_Sig: input signal
% ps_SamRate: sample rate in Hz
% ps_ARMethod (optional): set to 1 to compute the power spectral density
% via an AR (Autoregressive) model estimator. Default: 0 (FFT squared
% modulus estimator) 
% ps_AROrder (optional): set the order of the AR model. Default: 100
% 
% Outputs:
% v_PowSpec: array containing the power spectrum for frequencies from 0 to
% the half of the sample rate
% v_Freq: array containing the frequency values from 0 to the half of the
% sample rate
% s_TotalPow: sum of the power for frequencies from 0 to half of the sample
% rate
% 
% MATLAB Version: R2007b
% 
% Team: LENA
% Author: Mario Valderrama
%
    
    if nargin < 2
        error('[v_RelPow] - ERROR: bad number of inputs!');
    end    
    
    if ~exist('ps_ARMethod', 'var') || isempty(ps_ARMethod)
        ps_ARMethod = 0;
    end
    
    if ~exist('ps_AROrder', 'var') || isempty(ps_AROrder)
        ps_AROrder = 100;
    end
    
    s_Version	= version;
    s_Version	= eval(s_Version(1:3));
    
    if s_Version < 8.5
        pv_Sig  = double(pv_Sig);
    end
    
    switch ps_ARMethod,
        case 0, % FFT squared modulus
            v_PowSpec = fft(pv_Sig);
            v_PowSpec = v_PowSpec.* conj(v_PowSpec);
            v_PowSpec = v_PowSpec./ ps_SamRate;
            v_Freq = (0:length(v_PowSpec) - 1).* (ps_SamRate / length(v_PowSpec));
            s_LenHalf = floor(length(v_Freq)./ 2);
            v_PowSpec = v_PowSpec(1:s_LenHalf);
            v_Freq = v_Freq(1:s_LenHalf);
            
        case 1, % Burg method
            if length(pv_Sig) < ps_AROrder * 5
                ps_AROrder = round(length(pv_Sig) / 5);
            end
            [v_PowSpec, v_Freq] = pburg(pv_Sig, ps_AROrder, ...
                length(pv_Sig), ps_SamRate);
            
        otherwise,
            return;
            
    end

    if nargout >= 3
        s_TotalPow = sum(v_PowSpec);
    end
    if nargout < 2
        clear v_Freq
    end
    
    
    