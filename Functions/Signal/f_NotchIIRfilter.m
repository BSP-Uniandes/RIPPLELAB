% f_NotchIIRfilter.m
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

function st_Filter  = f_NotchIIRfilter(pv_Signal,ps_SampleRate,...
                    pv_StopFreqs)

pv_Signal   = pv_Signal(:);              
v_FFT       = fft(pv_Signal);
v_Freq      = ps_SampleRate*linspace(0,1,numel(v_FFT));
s_IsOdd     = mod(numel(pv_Signal),2);  
