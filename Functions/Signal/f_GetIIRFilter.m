% function f_GetIIRFilter.m
% 
% This function returns an IIR filter
% 
% Parameters:
% 
% ps_SampleRate: The sample rate of the signal to be filtered
% 
% ps_CutFreqs: A vector or a scalar containing the cut frequencies
% 
% ps_Order: The order of the filter
% 
% pstr_Type: Set empty ([]) for a pass-band filter, 'low', 'high' or 'stop'
% 
% ps_CheckGain = Set to 1 for check the filter gain  in the pass band.
% For a stop band filter this is a vector containing the gains in the
% middle frequencies for each pass band and for the stop band
% 
% ps_FilterName: Set 'butter', 'cheby2' (default)
% 
function [v_Filter v_Gain] = ...
    f_GetIIRFilter( ...
    ps_SampleRate, ...
    ps_CutFreqs, ...
    ps_Order, ...
    pstr_Type, ...
    ps_CheckGain, ...
    ps_FilterName)

    if nargin < 2 || isempty(ps_SampleRate)
        error('[f_GetIIRFilter] - ERROR: bad parameters!')
    end
    
    if ~exist('ps_Order', 'var')
        ps_Order = [];
    end
    
    if ~exist('pstr_Type', 'var')
        pstr_Type = [];
    end
    
    if ~exist('ps_CheckGain', 'var') || isempty(ps_CheckGain)
        ps_CheckGain = 0;
    end
    
    if ~exist('ps_FilterName', 'var') || isempty(ps_FilterName)
        ps_FilterName = 'cheby2';
    end
    
%     s_Nyq = round(ps_SampleRate / 2);
    s_Nyq = ps_SampleRate / 2;
    
    clear v_Filter v_Gain

    clear v_Z v_P s_K v_SOS s_G v_Wst
    if strcmpi(ps_FilterName, 'cheby2')
        s_Rp = .5;
        s_Rs = 100; % db
%         s_Rs = 20; % db
        s_Space = 0.5;
        v_Wst = [];
        if isempty(ps_Order)
            if strcmpi(pstr_Type, 'low')
                s_LowFreq = ps_CutFreqs;
                s_HighFreq = s_LowFreq;
                s_Scale = 0;
                while s_HighFreq < 1
                    s_HighFreq = s_HighFreq * 10;
                    s_Scale = s_Scale + 1;
                end
                s_HighFreq = s_LowFreq + (s_Space * 10^(-1 * s_Scale));
                v_StopFreq = s_HighFreq;
                [ps_Order v_Wst] = cheb2ord(ps_CutFreqs./ s_Nyq, ...
                    v_StopFreq./ s_Nyq, s_Rp, s_Rs);
                ps_CutFreqs = s_HighFreq;
            elseif strcmpi(pstr_Type, 'stop') || isempty(pstr_Type)
                
                %::::::::::::::::::MGNM:::::::::::::
                if  ps_CutFreqs(2) >= .99*s_Nyq
                    ps_CutFreqs(2)=s_Nyq * 0.99;
                    s_Space = .5;
                    s_Rs = 100;
                end
                %:::::::::::::::::::::::::::::::::::
                s_LowFreq = ps_CutFreqs(1);
                s_HighFreq = ps_CutFreqs(2);
                
                s_Scale = 0;
                while s_LowFreq > 0 && s_LowFreq < 1
                    s_LowFreq = s_LowFreq * 10;
                    s_Scale = s_Scale + 1;
                end
                s_LowFreq = ps_CutFreqs(1) - (s_Space * 10^(-1 * s_Scale));
                s_Scale = 0;
                while s_HighFreq < 1
                    s_HighFreq = s_HighFreq * 10;
                    s_Scale = s_Scale + 1;
                end
                s_HighFreq = ps_CutFreqs(2) + (s_Space * 10^(-1 * s_Scale));
                                
                v_StopFreq = [s_LowFreq s_HighFreq];
                if isempty(pstr_Type) 
                    [ps_Order v_Wst] = cheb2ord(ps_CutFreqs./ s_Nyq, ...
                        v_StopFreq./ s_Nyq, s_Rp, s_Rs);
                else
                    [ps_Order v_Wst] = cheb2ord(v_StopFreq./ s_Nyq, ...
                        ps_CutFreqs./ s_Nyq, s_Rp, s_Rs);
                end
            end
        end
        if ~isempty(v_Wst)
            if ~isempty(pstr_Type)
                [v_Z, v_P, s_K] = cheby2(ps_Order, s_Rs, v_Wst, pstr_Type);
            else
%                 [v_Z, v_P, s_K] = cheby2(ps_Order, s_Rs, ps_CutFreqs./ s_Nyq);
                [v_Z, v_P, s_K] = cheby2(ps_Order, s_Rs, v_Wst);
            end
        elseif ~isempty(pstr_Type)
            [v_Z, v_P, s_K] = cheby2(ps_Order, s_Rs, ps_CutFreqs./ s_Nyq, pstr_Type);
%             [v_Z, v_P, s_K] = cheby2(ps_Order, s_Rs, v_Wst, pstr_Type);
        else
            display('[f_GetIIRFilter] - ERROR: v_Wst and pstr_Type are empty!');
            return;
        end
    elseif strcmpi(ps_FilterName, 'butter')
        if ~isempty(pstr_Type)
            [v_Z, v_P, s_K] = butter(ps_Order, ps_CutFreqs./ s_Nyq, pstr_Type);
        else
            [v_Z, v_P, s_K] = butter(ps_Order, ps_CutFreqs./ s_Nyq);
        end
    else
        display('[f_GetIIRFilter] - ERROR: unknown filter name!')
        return;
    end
    [v_SOS, s_G] = zp2sos(v_Z, v_P, s_K);
    v_Filter = dfilt.df2sos(v_SOS, s_G);
    clear v_Z v_P s_K v_SOS s_G    
    
    v_Gain = -1;
    
    if ~ps_CheckGain
        return;
    end
    
    clear v_H v_F v_FBand
    [v_H v_F] = freqz(v_Filter, [], ps_SampleRate);
    if isempty(pstr_Type) || strcmpi(pstr_Type, 'stop')
        v_FBand = find(v_F > ps_CutFreqs(1) & v_F < ps_CutFreqs(2));
    else
        if strcmpi(pstr_Type, 'low')
            v_FBand = find(v_F < ps_CutFreqs);
        elseif strcmpi(pstr_Type, 'high')
            v_FBand = find(v_F > ps_CutFreqs);
        end
    end
    if ~isempty(v_FBand)
        if length(v_FBand) > 1
            s_MidFreq = round(length(v_FBand) / 2);
        else
            s_MidFreq = 1;
        end
            
        v_Gain = abs(v_H(v_FBand(s_MidFreq)));
        if strcmpi(pstr_Type, 'stop')
            v_Gain = -1.* ones(1, 3);
            v_Gain(3) = abs(v_H(v_FBand(s_MidFreq)));
            v_FBand = find(v_F < ps_CutFreqs(1));
            if length(v_FBand) > 1
                s_AuxFreq = round(length(v_FBand) / 2);
            else
                s_AuxFreq = 1;
            end
            v_Gain(1) = abs(v_H(v_FBand(s_AuxFreq)));
            v_FBand = find(v_F > ps_CutFreqs(2));
            if length(v_FBand) > 1
                s_AuxFreq = round(length(v_FBand) / 2);
            else
                s_AuxFreq = 1;
            end
            v_Gain(2) = abs(v_H(v_FBand(s_AuxFreq)));
        end
    end
    clear v_H v_F v_FBand

return;
