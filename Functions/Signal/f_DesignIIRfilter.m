% f_DesignIIRfilter.m
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

function st_Filter  = f_DesignIIRfilter(ps_SampleRate,pv_PassFreqs,...
                    pv_StopFreqs,pv_GainVals)

if nargin < 3 || isempty(ps_SampleRate)
    error('[f_DesignIIRfilter] - ERROR: bad parameters!')
end

if nargin < 4 
    s_Apass = 1;
    s_Astop = 20;
else
    if isempty(pv_GainVals) || numel(pv_GainVals) ~=2
        error('[f_DesignIIRfilter] - ERROR: bad pv_GainVals parameters!')
    end
    s_Apass = pv_GainVals(1);
    s_Astop = pv_GainVals(2);
    clear pv_GainVals
end

if isempty(pv_PassFreqs) || numel(pv_PassFreqs) > 2
    error('[f_DesignIIRfilter] - ERROR: bad CutFreq parameters!')
end

if isempty(pv_StopFreqs) || numel(pv_StopFreqs) > 2
    error('[f_DesignIIRfilter] - ERROR: bad StopFreq parameters!')
end

if numel(pv_PassFreqs) ~= numel(pv_StopFreqs)
    error('[f_DesignIIRfilter] - ERROR: numel CutFreqs and StopFreq mismatch!')
end

if numel(pv_PassFreqs) > 2
    error('[f_DesignIIRfilter] - ERROR: bad CutFreq parameters!')
end

switch numel(pv_PassFreqs)
    case 1
        if pv_PassFreqs > pv_StopFreqs
            str_Type    = 'Highpass';
        else
            str_Type    = 'Lowpass';
        end
    case 2
        if pv_PassFreqs(1) > pv_StopFreqs(1) && ...
                pv_PassFreqs(2) < pv_StopFreqs(2)
            str_Type    = 'Bandpass';
        elseif  pv_PassFreqs(1) < pv_StopFreqs(1) && ...
                pv_PassFreqs(2) > pv_StopFreqs(2)
            str_Type    = 'Bandstop';
        else
            error('[f_DesignIIRfilter] - ERROR: Frequencies mistmatch!')            
        end               
end

v_Wp    = pv_PassFreqs ./ (ps_SampleRate/2);
v_Ws    = pv_StopFreqs ./ (ps_SampleRate/2);
                    
if  numel(v_Wp) == 2
   if v_Wp(end) >= 1 
        
    str_Type    = 'Highpass';
    v_Wp        = v_Wp(1);
    v_Ws        = v_Ws(1);
    
   elseif v_Wp(1) <= 0
        
    str_Type    = 'Lowpass';
    v_Wp        = v_Wp(2);
    v_Ws        = v_Ws(2);
       
   end 
end
switch str_Type
    case 'Highpass'                        
        str_FilTyp	= 'high';
    case 'Lowpass'                        
        str_FilTyp	= 'low';
    case 'Bandpass'                        
        str_FilTyp	= [];
    case 'Bandstop'                            
        str_FilTyp	= 'stop';  
end

try 
    str_SigPath = toolboxdir('signal');
    
    [ps_Order,v_Wst]    = cheb2ord(v_Wp,v_Ws,s_Apass,s_Astop);

    if isempty(str_FilTyp)
        [v_Z, v_P, s_K] = cheby2(ps_Order, s_Astop, v_Wst);
    else
        [v_Z, v_P, s_K] = cheby2(ps_Order, s_Astop, v_Wst, str_FilTyp);
    end
        
    [v_SOS, s_G]    = zp2sos(v_Z, v_P, s_K);
    st_Filter       = dfilt.df2sos(v_SOS, s_G);
        
catch
    if isempty(str_FilTyp)                     
        str_FilTyp	= 'pass'; 
    end
    
    [ps_Order,v_Wst]= fb_cheb2ord(v_Wp,v_Ws,s_Apass,s_Astop);
    [v_Z, v_P, s_K] = fb_cheby2(ps_Order, s_Astop, v_Wst, str_FilTyp);
    v_SOS           = old_zp2sos(v_Z, v_P, s_K);
    
    st_Filter       = struct('SOS',v_SOS,'G',s_K);
    
end

