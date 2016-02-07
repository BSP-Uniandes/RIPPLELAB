% Function f_EqualizerFreqFilter.m
% 
% Description:
% This function performs a kind of spectral equalization by removing a
% polynomial tendency to the magnitude of the signal spectrum estimated via
% the FFT. The procedure changes the FFT magnitude but conserves the
% original phase.
% 
% Inputs:
% pv_InSignal: input signal 
% ps_SampleFreq: signal sample frequency
% ps_PolyOrder: the order of polynomial to fit to the magnitude spectrum (in
% log10-log10). If empty the function attempts to find an optimum order.
% pv_FreqLims: if no empty, the polynomial tendency will be estimated and
% removed only for the frequencies comprised between the limits defined by
% this argument.
% 
% Outputs:
% v_OutSignal: filtered signal
% 
% Author: Mario Valderrama
% Date: Nov. 2011
% 
function m_WhiMat = ...
    f_EqualizerFreqFilter( ...
    pm_ColMatIn, ...
    ps_SampleFreq, ...
    ps_PolyOrd, ...
    pv_FreqLims)

    if nargin < 1
        return;
    end
    
    if ~exist('ps_PolyOrd', 'var')
        ps_PolyOrd = [];
    end
    
    if ~exist('pv_FreqLims', 'var')
        pv_FreqLims = [];
    end
    
    if size(pm_ColMatIn, 1) == 1
        pm_ColMatIn = pm_ColMatIn(:);
    end
    
    s_UnionLenPer = 0.01;
        
    m_WhiMat = zeros(size(pm_ColMatIn));
    for s_ColCount = 1:size(pm_ColMatIn, 2)
        
        clear v_YPSD v_Freq v_HPSD v_LogFreq v_Y v_PolVal v_Poly
        v_Y = pm_ColMatIn(:, s_ColCount);
        if mod(numel(v_Y), 2) == 0
            v_Y = v_Y(1:end - 1, :);
        end
        
        [v_YFFT, v_Freq] = f_FFT(v_Y, ps_SampleFreq, 0);
% %         v_LogYFFT = log10(abs(v_YFFT(2:end)));
% % %         v_LogYFFT = [(v_LogYFFT(1) + abs(diff(v_LogYFFT(1:2))) / 2);v_LogYFFT];
% %         v_LogFreq = log10(v_Freq(2:end));
        v_LogYFFT = log10(abs(v_YFFT));
        v_LogFreq = log10(v_Freq + diff(v_Freq(1:2)));
        if ~isempty(pv_FreqLims)
            v_FreqInd = zeros(numel(pv_FreqLims), 1);
            for s_Counter = 1:numel(pv_FreqLims)
                s_FirstFreqLim = find(v_Freq(:) >= ...
                    pv_FreqLims(s_Counter), 1);
                if isempty(s_FirstFreqLim)
                    s_FirstFreqLim = numel(v_Freq);
                end
                if s_FirstFreqLim > 1 && (abs(pv_FreqLims(s_Counter) - ...
                        v_Freq(s_FirstFreqLim - 1)) < abs(pv_FreqLims(s_Counter) - ...
                        v_Freq(s_FirstFreqLim)))
                    s_FirstFreqLim = s_FirstFreqLim - 1;
                end
                v_FreqInd(s_Counter) = s_FirstFreqLim;
            end
            v_LogYFFTAll = v_LogYFFT;
            v_LogFreqAll = v_LogFreq;
            v_LogYFFT = v_LogYFFT(v_FreqInd(1):v_FreqInd(end));
            v_LogFreq = v_LogFreq(v_FreqInd(1):v_FreqInd(end));
        end
        
        if ~isempty(find(isinf(v_LogYFFT), 1)) || ~isempty(find(isnan(v_LogYFFT), 1))
            m_WhiMat = [];
            break;
        end
        
        if ~isempty(ps_PolyOrd)
            if numel(pv_FreqLims) > 2
                v_PolVal = [];
                for s_Counter = 1:(numel(v_FreqInd) - 1)
                    s_FirstFreqLim = v_FreqInd(s_Counter);
                    if s_Counter > 1
                        s_FirstFreqLim = s_FirstFreqLim + 1;
                    end
                    s_LastFreqLim = v_FreqInd(s_Counter + 1);
                    s_FirstFreqLim = s_FirstFreqLim - v_FreqInd(1) + 1;
                    s_LastFreqLim = s_LastFreqLim - v_FreqInd(1) + 1;
                    v_Poly = polyfit(v_LogFreq(s_FirstFreqLim:s_LastFreqLim), ...
                        v_LogYFFT(s_FirstFreqLim:s_LastFreqLim), ps_PolyOrd);
                    v_PolValAux  = polyval(v_Poly, ...
                        v_LogFreq(s_FirstFreqLim:s_LastFreqLim));
                    
% % % % % % % % % % % This part makes all lines adjacents                    
                    if s_Counter > 1
                        s_Slope = (v_PolValAux(end) - v_PointTemp(2)) / ...
                            (v_LogFreq(s_LastFreqLim) - v_PointTemp(1));
                        s_YPoint = v_PolValAux(end) - s_Slope * ...
                            v_LogFreq(s_LastFreqLim);
                        v_Poly = [s_Slope s_YPoint];
                        v_PolValAux  = polyval(v_Poly, ...
                            v_LogFreq(s_FirstFreqLim:s_LastFreqLim));
                    end
                    v_PointTemp = [v_LogFreq(s_LastFreqLim) v_PolValAux(end)];
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % 

                    v_PolVal = f_AddVerElems(v_PolVal, v_PolValAux(:));
                end
            else
                v_Poly = polyfit(v_LogFreq, v_LogYFFT, ps_PolyOrd);
                v_PolVal  = polyval(v_Poly, v_LogFreq);
            end
        else
%             figure;
            s_MaxOrd = 10;
            v_Var = zeros(1, s_MaxOrd);
            for s_Counter = 1:numel(v_Var)
                v_Poly = polyfit(v_LogFreq, v_LogYFFT, s_Counter);
                v_PolVal = polyval(v_Poly, v_LogFreq);
                
%                 if v_PolVal(1) > v_LogYFFT(1)
%                     break;
%                 end
                
%                 v_Var(s_Counter) = abs(var(v_PolVal - v_LogYFFT));
%                 if s_Counter > 2
%                     if v_Var(s_Counter - 1) <= v_Var(s_Counter - 2) && ...
%                             v_Var(s_Counter - 1) <= v_Var(s_Counter)
%                         break;
%                     end
%                 end
                
%                 plot(v_LogFreq, v_LogYFFT)
%                 hold on
%                 plot(v_LogFreq, v_PolVal, 'r')
%                 hold off
%                 pause(0.5)
            end
            ps_PolyOrd = s_Counter;
%             figure;
%             plot(abs(v_Var))
        end
        
%         display(sprintf('[f_EqualizerFreqFilter] - Equalizing signal spectrum with poly order %s', ...
%             num2str(ps_PolyOrd)));
                
%         figure;
%         plot(v_LogFreq, v_LogYFFT)
%         hold on
%         plot(v_LogFreq, v_PolVal, 'r')
%         

% % % % % WARNING: DO NOT COMMENT THIS LINE!!!
        v_PolVal = v_LogYFFT - v_PolVal;
% % % % % % % % % % % % % % % % % % % % % % %         

%         
%         figure;
%         plot(v_LogFreq, v_PolVal, 'r')
        
        if isempty(pv_FreqLims)
            s_Mean1 = mean(v_LogYFFT);
            s_Dis = mean(v_PolVal);
            s_Dis = s_Mean1 - s_Dis;
            v_PolVal = v_PolVal + s_Dis;
        else
            v_LogYFFT = v_PolVal;
            v_PolVal = v_LogYFFTAll;
            v_PolVal(v_FreqInd(1):v_FreqInd(end)) = v_LogYFFT;
            
            if numel(v_FreqInd) > 2
                v_FreqInd = [v_FreqInd(1) v_FreqInd(end)];
            end
            clear v_LogYFFT
            for s_Counter = 1:numel(v_FreqInd)
                s_CurrentFreqLim = v_FreqInd(s_Counter);
                if s_Counter > 1
                    s_CurrentFreqLim = s_CurrentFreqLim + 1;
                end
                
                if s_CurrentFreqLim == 1
                    continue;
                end
%                 if s_CurrentFreqLim == numel(v_PolVal)
%                     break;
%                 end

                if s_CurrentFreqLim >= numel(v_PolVal)
                    break;
                end
                if s_Counter > 1
                    s_FirstFreqLim = v_FreqInd(s_Counter - 1);
                else
                    s_FirstFreqLim = 1;
                end
                if s_Counter < numel(v_FreqInd)
                    s_LastFreqLim = v_FreqInd(s_Counter + 1);
                else
                    s_LastFreqLim = numel(v_PolVal);
                end
                                    
                s_Dis = min([(s_CurrentFreqLim - s_FirstFreqLim) ...
                    (s_LastFreqLim - s_CurrentFreqLim)]);
                s_Dis = max([1 round(s_Dis * s_UnionLenPer)]);
                s_Mean1 = mean(v_PolVal(s_CurrentFreqLim - s_Dis: ...
                    s_CurrentFreqLim - 1));
                
                v_PolVal(s_CurrentFreqLim:s_LastFreqLim) = ...
                    v_PolVal(s_CurrentFreqLim:s_LastFreqLim) - ...
                    mean(v_PolVal(s_CurrentFreqLim: ...
                    s_CurrentFreqLim + s_Dis));
                v_PolVal(s_CurrentFreqLim:s_LastFreqLim) = ...
                    v_PolVal(s_CurrentFreqLim:s_LastFreqLim) + ...
                    s_Mean1;
            end
        end
        
%         figure;
%         plot(v_LogFreqAll, v_LogYFFTAll)
%         hold on
%         plot(v_LogFreqAll, v_PolVal, 'r')
% 
%         figure;
%         plot(v_LogFreqAll, v_PolVal, 'r')
%         hold on
%         plot(v_LogFreqAll, v_LogYFFTAll)
        
        v_PolVal = (10.^v_PolVal).* exp(1i.* angle(v_YFFT));
        v_PolVal = [v_PolVal;flipud(conj(v_PolVal))];
        v_PolVal(1) = real(v_PolVal(1));
        
%         v_PolVal = (10.^v_PolVal).* exp(1i.* angle(v_YFFT(2:end)));
%         v_PolVal = [v_PolVal;flipud(conj(v_PolVal))];
%         v_PolVal = [sum(v_Y);v_PolVal];
        
        if numel(v_PolVal) > numel(v_Y)
            v_PolVal = v_PolVal(1:end - 1);
        end          
        
        m_WhiMat(1:numel(v_PolVal), s_ColCount) = ifft(v_PolVal);
        if ~isreal(m_WhiMat(:, s_ColCount))
            display('[f_EqualizerFreqFilter] - WARNING: resulting signal is not real!');
        end
        if numel(v_PolVal) < size(m_WhiMat, 1)
            m_WhiMat(end, s_ColCount) = mean(m_WhiMat(end - 2:end - 1, s_ColCount));
        end

%         v_Y1PSD = pwelch(m_WhiMat(:, s_ColCount), [], [], ...
%             size(m_WhiMat, 1), ps_SampleFreq);
%         
%         [v_YPSD, v_Freq] = pwelch(pm_ColMatIn(:, s_ColCount), [], [], ...
%             size(pm_ColMatIn, 1), ps_SampleFreq);
%         
%         figure;
%         plot(log10(v_Freq), log10(v_YPSD))
%         hold on
%         plot(log10(v_Freq), log10(v_Y1PSD), 'r')  
%         
%         figure;
%         plot(v_Freq, v_YPSD)
%         hold on
%         plot(v_Freq, v_Y1PSD, 'r')  
        
    end
end