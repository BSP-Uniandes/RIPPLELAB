% f_DesignFIRfilter.m
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

function st_Filter  = f_DesignFIRfilter(ps_SampleRate,pv_PassFreqs,...
                    pv_StopFreqs,ps_Order)
                
if nargin < 3 || isempty(ps_SampleRate)
    error('[f_DesignFIRfilter] - ERROR: bad parameters!')
end

if nargin < 4 
    ps_Order = 50;
else
    if isempty(ps_Order) || numel(ps_Order) >1 || ps_Order < 1
        error('[f_DesignFIRfilter] - ERROR: bad ps_Order parameter!')
    end
end

if isempty(pv_PassFreqs) || numel(pv_PassFreqs) > 2
    error('[f_DesignFIRfilter] - ERROR: bad CutFreq parameters!')
end

if isempty(pv_StopFreqs) || numel(pv_StopFreqs) > 2
    error('[f_DesignIIRfilter] - ERROR: bad StopFreq parameters!')
end
    
switch numel(pv_PassFreqs)
    case 1
        if pv_PassFreqs > pv_StopFreqs
            str_Type    = 'high';
        else
            str_Type    = 'low';
        end
    case 2
        if pv_PassFreqs(1) > pv_StopFreqs(1) && ...
                pv_PassFreqs(2) < pv_StopFreqs(2)
            str_Type    = 'bandpass';
        elseif  pv_PassFreqs(1) < pv_StopFreqs(1) && ...
                pv_PassFreqs(2) > pv_StopFreqs(2)
            str_Type    = 'stop';
        else
            error('[f_DesignFIRfilter] - ERROR: Frequencies mistmatch!')            
        end               
end

v_Wp        = pv_PassFreqs ./ ps_SampleRate;
st_Filter   = fb_fir1(ps_Order,v_Wp,str_Type);