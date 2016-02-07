% Function: f_GaborAWTransformMatlab.m
% 
% Description:
% This function calculates the Wavelet Transform using a Gaussian modulated
% window (Gabor Wavelet).
% The Sample Rate of the input signal is considered in order to compute
% the transform.
% 
% Parameters:
% pv_Signal(*): Signal to process
% ps_SampleRate(*): Sample rate
% ps_MinFreqHz: Min frequency (in Hz) to process from
% ps_MaxFreqHz: Max frequency (in Hz) to process to
% ps_FreqSeg: Number of segments used to calculate the size of the
% resulting matrix in the frequency direction
% 
% ps_StDevCycles: In the wavelet transform, the scale corresponding to each
% frequency (in v_FreqAxis) defines the value (in seconds) of the
% gaussian's standard deviation used for the calculation of the transform
% at every one of these frequencies. This standard deviation value must be
% big enough to cover at least one or more complete cycles (or periods) of
% the oscillation at each considered frequency. Thus, this parameter
% defines the number of cycles you want to include for the transform at
% every frequency.
% 
% ps_Magnitudes: Set to 1 (default) if the magnitudes of the coefficients
% must be returned; 0 for analytic values (complex values).
% 
% ps_SquaredMag: Set to 1 if the magnitudes of the coefficients divided by
% the squared of the corresponding scale must by power to 2
% 
% ps_MakeBandAve: Set to 1 if instead of returning a matrix with all values
% in the time-frequency map, the function returns just a vector with the
% average along all the frequency scales for each time moment.
% 
% ps_Phases: Set to 1 if the phases of the coefficients
% must be returned; 0 for analytic values (complex values).
% 
% ps_TimeStep: Time step between values that are going to be kept in the
% output matrix. Each time moment is the average of the previous values
% according to the size of the window defined by this parameter.
% 
% (*) Required parameters
% 
% Outputs:
% m_GaborWT: Matrix containing the scalogram. Time in rows, frequency in
% colums. Frequencies in descending order
% v_TimeAxis: Array containing the time axis values (second units)
% v_FreqAxis: Array containing the frequency axis values in descending
% order (Hz units)
% 
% Author: Mario Valderrama
%  
function [m_GaborWT, v_TimeAxis, v_FreqAxis] = ...
    f_GaborTransformWait(...
    pv_Signal, ...
    ps_SampleRate, ...
    ps_MinFreqHz, ...
    ps_MaxFreqHz, ...
    ps_FreqSeg, ...
    ps_StDevCycles, ...
    ps_Magnitudes, ...
    ps_SquaredMag, ...
    ps_MakeBandAve, ...
    ps_Phases, ...
    ps_TimeStep,...
    ps_WaitBar)

    if nargin < 2
        return;
    end
    
    if ~exist('ps_MinFreqHz', 'var') || isempty(ps_MinFreqHz) || ...
            ps_MinFreqHz == 0
        ps_MinFreqHz = 0.1;
    end
    
    if ~exist('ps_MaxFreqHz', 'var') || isempty(ps_MaxFreqHz) || ...
            ps_MaxFreqHz > ps_SampleRate / 2;
        ps_MaxFreqHz = ps_SampleRate / 2;
    end
    
    if ~exist('ps_FreqSeg', 'var') || isempty(ps_FreqSeg) || ...
            ps_FreqSeg <= 0
        ps_FreqSeg = round(ps_MaxFreqHz - ps_MinFreqHz);
    end
    
    if ~exist('ps_StDevCycles', 'var') || isempty(ps_StDevCycles)
        ps_StDevCycles = 3;
    end

    if ~exist('ps_Magnitudes', 'var') || isempty(ps_Magnitudes)
        ps_Magnitudes = 1;
    end
    
    if ~exist('ps_SquaredMag', 'var') || isempty(ps_SquaredMag)
        ps_SquaredMag = 0;
    end
    
    if ~exist('ps_MakeBandAve', 'var') || isempty(ps_MakeBandAve)
        ps_MakeBandAve = 0;
    end
    
    if ~exist('ps_Phases', 'var') || isempty(ps_Phases)
        ps_Phases = 0;
    end

    if ~exist('ps_TimeStep', 'var')
        ps_TimeStep = [];
    end
    
    if ~exist('ps_WaitBar', 'var')
        ps_WaitBar = 0;
    end
    
    
    pv_Signal = pv_Signal(:);
    
%     display('[f_GaborAWTransformMatlab] - Computing wavelet transform...');
%     tic
    
    %:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
    if ps_WaitBar
        hw_Bar          = waitbar(0,'Computing wavelet transform...');
        hw_Patch        = findobj(hw_Bar,'Type','Patch');
        set(hw_Bar,'WindowStyle','modal')
        set(hw_Patch,'EdgeColor','b','FaceColor','b')
        s_Counter = 0;
    end
    %:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

    s_FreqStep = (ps_MaxFreqHz - ps_MinFreqHz) / (ps_FreqSeg - 1);
    v_FreqAxis = ps_MinFreqHz:s_FreqStep:ps_MaxFreqHz;
    v_FreqAxis = fliplr(v_FreqAxis);
    
    if mod(numel(pv_Signal), 2) == 0
        pv_Signal = pv_Signal(1:end - 1);
    end
    
    v_TimeAxis = (0:numel(pv_Signal) - 1)./ ps_SampleRate;
    s_Len = numel(v_TimeAxis);
    s_HalfLen = floor(s_Len / 2) + 1;
    
    v_WAxis = (2.* pi./ s_Len).* ...
        (0:(s_Len - 1));
    v_WAxis = v_WAxis.* ps_SampleRate;
    v_WAxisHalf = v_WAxis(1:s_HalfLen);
    
    if isempty(ps_TimeStep)
        s_SampAve = 1;
    else
        s_SampAve = round(ps_TimeStep * ps_SampleRate);
        if s_SampAve < 1
            s_SampAve = 1;
        end
    end
    
    v_SampAveFilt = [];
    if s_SampAve > 1
        v_IndSamp = 1:s_SampAve:numel(v_TimeAxis);
        v_TimeAxis = v_TimeAxis(v_IndSamp);
        v_SampAveFilt = ones(s_SampAve, 1);
    end
    
    v_InputSignalFFT = fft(pv_Signal, numel(pv_Signal));
    
    clear m_GaborWT
    m_GaborWT = zeros(numel(v_FreqAxis), numel(v_TimeAxis));
    s_FreqInd = 0;
    for s_FreqCounter = v_FreqAxis
        
        %:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
        if ps_WaitBar
            waitbar(s_Counter/numel(v_FreqAxis))
            s_Counter = s_Counter + 1;
        end
        %:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
        
        s_StDevSec = (1 / s_FreqCounter) * ps_StDevCycles;
        
        clear v_WinFFT
        v_WinFFT = zeros(s_Len, 1);
        v_WinFFT(1:s_HalfLen) = exp(-0.5.* ...
            realpow(v_WAxisHalf - (2.* pi.* s_FreqCounter), 2).* ...
            (s_StDevSec.^ 2));
        v_WinFFT = v_WinFFT.* sqrt(s_Len)./ norm(v_WinFFT, 2);

        s_FreqInd = s_FreqInd + 1;
        
        if s_SampAve > 1
            clear v_GaborTemp
            v_GaborTemp = zeros(numel(v_InputSignalFFT) + (s_SampAve - 1), 1);
            v_GaborTemp(s_SampAve:end) =  ifft(v_InputSignalFFT.* v_WinFFT)./ ...
                sqrt(s_StDevSec);
            
            if ps_Magnitudes
                v_GaborTemp = abs(v_GaborTemp);
            end
            
            if ps_SquaredMag
                v_GaborTemp = v_GaborTemp.^2;
            end
            
            v_GaborTemp(1:(s_SampAve - 1)) = ...
                flipud(v_GaborTemp(s_SampAve + 1:2 * s_SampAve - 1));
            v_GaborTemp = filter(v_SampAveFilt, 1, v_GaborTemp)./ s_SampAve;
            v_GaborTemp = v_GaborTemp(s_SampAve:end);

            m_GaborWT(s_FreqInd, :) = v_GaborTemp(v_IndSamp);
        else
            m_GaborWT(s_FreqInd, :) = ifft(v_InputSignalFFT.* v_WinFFT)./ ...
                sqrt(s_StDevSec);
        end
    end
    if ps_WaitBar
        close(hw_Bar)
    end
    clear v_WinFFT v_GaborTemp v_SampAveFilt
    
%     toc
    
    if s_SampAve > 1
        return;
    end
    
    if ps_Phases
        m_GaborWT = angle(m_GaborWT);
        return;
    end
    
    if ps_Magnitudes ~= 1
        return;
    end
    
    m_GaborWT = abs(m_GaborWT);
    
    if ps_SquaredMag
        m_GaborWT = m_GaborWT.^2;
    end
    
    if ps_MakeBandAve
        m_GaborWT = mean(m_GaborWT, 2);
        m_GaborWT = flipud(m_GaborWT);
        v_TimeAxis = [];
        v_FreqAxis = fliplr(v_FreqAxis);
    end
  
return;
    
