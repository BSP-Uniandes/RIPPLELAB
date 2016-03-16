% f_fftFilter.m
%
%     Copyright (C) 2015, Miguel Navarrete
%
%     This program is free software: you can redistribute it and/or modify
%     it under the terms of the GNU General Public License as published by
%     the Free Software Foundation, either version 3 of the License, or
%     (at your option) any later version.
% 
%     This program is distributed in the hope that it will be useful,
%     but WITHOUT ANY WARRANTY; without even the implied warranty of
%     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%     GNU General Public License for more details.
% 
%     You should have received a copy of the GNU General Public License
%     along with this program.  If not, see <http://www.gnu.org/licenses/>.

function v_Signal = f_fftFilter(pv_Signal,ps_Sampling,pv_CutFreq,ps_SlopeBand,pstr_Type)

if nargin < 3
    error('[f_DesignFIRfilter] - ERROR: bad parameters!')
end

if isempty(ps_SlopeBand) || nargin < 4
    ps_SlopeBand	= 21;
end

if isempty(pstr_Type) || nargin < 5
    pstr_Type	= 'low';
end
            
pstr_Type   = lower(pstr_Type);

v_FFT       = fft(pv_Signal);
v_Freq      = linspace(0,1,length(v_FFT))*ps_Sampling;
ps_SlopeBand= sum(v_Freq <= ps_SlopeBand);

s_DCvalue   = v_FFT(1,:);
v_FFT       = v_FFT(2:end,:);
v_Freq      = v_Freq(2:end);
s_IsOdd     = mod(numel(v_Freq),2);

if s_IsOdd
    s_NqIdx	= ceil(numel(v_Freq)/2);
else
    s_NqIdx	= [];        
end

v_LowerFreq = v_Freq(1:s_NqIdx-1);
% v_NyqFreq 	= v_Freq(s_NqIdx);
% v_UpperFreq = v_Freq(s_NqIdx+1:end);

v_LowerFFT  = v_FFT(1:s_NqIdx-1,:);
v_NyqFFT 	= v_FFT(s_NqIdx,:);
v_UpperFFT  = v_FFT(s_NqIdx+1:end,:);

clear v_FFT v_Freq

switch pstr_Type
    case 'low'
        pv_CutFreq	= min(pv_CutFreq);
        v_Window    = gausswin(ps_SlopeBand*2,3.7);
        v_Window    = v_Window(ceil(numel(v_Window)/2):end);
        s_CutIdx    = find(v_LowerFreq <= pv_CutFreq,1,'last');
        v_PassFrq	= single(v_LowerFreq <= pv_CutFreq);
        
        v_PassFrq(s_CutIdx:numel(v_Window)+s_CutIdx-1)	= v_Window;
        
    case 'high'
        pv_CutFreq	= max(pv_CutFreq);
        v_Window    = gausswin(ps_SlopeBand*2,3.7);
        v_Window    = v_Window(1:floor(numel(v_Window)/2));
        s_NumelWin	= numel(v_Window);
        s_CutIdx    = find(v_LowerFreq >= pv_CutFreq,1,'First');
        v_PassFrq	= single(v_LowerFreq >= pv_CutFreq);
        
        v_PassFrq(s_CutIdx-s_NumelWin+1:s_CutIdx)	= v_Window;
        
    case 'pass'
        
        v_PassFrq   = zeros(size(v_LowerFreq));
        v_Window    = gausswin(ps_SlopeBand,3.7);
        s_NumelWin	= numel(v_Window);
        s_HalfWin	= round(numel(v_Window)/2);
        
        for kk = 1:numel(pv_CutFreq)
            s_CutFreq	= pv_CutFreq(kk);
            [~,s_CutIdx]= min(abs(v_LowerFreq - s_CutFreq));
            
            v_PassFrq(s_CutIdx-s_HalfWin:...    
                s_CutIdx-s_HalfWin+s_NumelWin-1)= v_Window;
        end
        
    case 'stop'
        
        v_PassFrq   = zeros(size(v_LowerFreq));
        v_Window    = gausswin(ps_SlopeBand,3.7);
        s_NumelWin	= numel(v_Window);
        s_HalfWin	= round(numel(v_Window)/2);
        
        for kk = 1:numel(pv_CutFreq)
            s_CutFreq	= pv_CutFreq(kk);
            [~,s_CutIdx]= min(abs(v_LowerFreq - s_CutFreq));
            
            v_PassFrq(s_CutIdx-s_HalfWin:...    
                s_CutIdx-s_HalfWin+s_NumelWin-1)= v_Window;
        end
        
        if numel(v_PassFrq) > size(v_LowerFFT,1)
            v_PassFrq	= v_PassFrq(1:size(v_LowerFFT,1));
        end
        
        v_PassFrq   = ones(size(v_PassFrq))-v_PassFrq;
    otherwise
        error('[f_DesignFIRfilter] - ERROR: Filter type!')            
end

s_DCvalue   = s_DCvalue * v_PassFrq(1);
v_LowerFFT  = v_LowerFFT .* repmat(v_PassFrq(:),1,size(v_LowerFFT,2));
v_NyqFFT 	= v_NyqFFT .* v_PassFrq(end);
v_UpperFFT  = v_UpperFFT .* repmat(flipud(v_PassFrq(:)),1,size(v_UpperFFT,2));
 
v_FFT   = vertcat(s_DCvalue,v_LowerFFT,v_NyqFFT,v_UpperFFT);
% v_Freq  = vertcat(0,v_LowerFreq(:),v_NyqFreq(:),v_UpperFreq(:));

v_Signal= real(ifft(v_FFT))';