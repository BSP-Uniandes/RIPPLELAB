% f_FilterIIR.m
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

function v_SigFilt  = f_FilterIIR(pv_Signal,pst_Filter,ps_DoubleFilt)


if nargin < 2
    error('[f_FilterIIR] - ERROR: bad parameters!')
end

if nargin < 3 || isempty(ps_DoubleFilt)
    ps_DoubleFilt   = true;
end

if size(pv_Signal, 1) == 1
    pv_Signal = pv_Signal(:);
end

if isstruct(pst_Filter)
    v_SigFilt   = f_SOSfilt(pst_Filter,pv_Signal);
else
    v_SigFilt   = filter(pst_Filter,pv_Signal);
end

if ps_DoubleFilt
    
    if isstruct(pst_Filter)
        v_SigFilt   = f_SOSfilt(pst_Filter,flipud(v_SigFilt));
    else
        v_SigFilt = filter(pst_Filter, flipud(v_SigFilt));
    end

    v_SigFilt = flipud(v_SigFilt);
end
