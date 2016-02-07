function [hdr] = f_GetExtNCSHeader(filename)

% This is a modification of READ_NEURALYNX_NCS and neuralynx_getheader
% READ_NEURALYNX_NCS reads a single continuous channel file
%
% Use as
%   [ncs] = read_neuralynx_ncs(filename)
%   [ncs] = read_neuralynx_ncs(filename, begrecord, endrecord)

% Copyright (C) 2005-2007, Robert Oostenveld
%
% This file is part of FieldTrip, see http://www.ru.nl/neuroimaging/fieldtrip
% for the documentation and details.
%
%    FieldTrip is free software: you can redistribute it and/or modify
%    it under the terms of the GNU General Public License as published by
%    the Free Software Foundation, either version 3 of the License, or
%    (at your option) any later version.
%
%    FieldTrip is distributed in the hope that it will be useful,
%    but WITHOUT ANY WARRANTY; without even the implied warranty of
%    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%    GNU General Public License for more details.
%
%    You should have received a copy of the GNU General Public License
%    along with FieldTrip. If not, see <http://www.gnu.org/licenses/>.
%

% the file starts with a 16*1024 bytes header in ascii, followed by a number of records
hdr = neuralynx_getheader(filename);
fid = fopen(filename, 'rb', 'ieee-le');

% determine the length of the file
fseek(fid, 0, 'eof');
headersize = 16384; %16 kB
recordsize = 1044;
NRecords   = floor((ftell(fid) - headersize)/recordsize);

fclose(fid);

% store the header info in the output structure
hdr.NRecords = NRecords;

s_idx       = strfind(hdr.Header, 'At Time: ');

if ~isempty(s_idx)
    [str_Token, str_Remain] = strtok(hdr.Header(s_idx(1):end),':');
    [v_IniTimeTemp, str_Remain] = strtok(str_Remain(2:end),'#');
else
    s_idx       = strfind(hdr.Header, '(h:m:s.ms) ');
    
    [str_Token, str_Remain] = strtok(hdr.Header(s_idx(1):end),'#');
    [str_Token,v_IniTimeTemp] = strtok(str_Token,')');
    v_IniTimeTemp   = v_IniTimeTemp(2:end);

end


v_IniTime   = zeros(1,3);
for kk=1:3
    [str_Token, v_IniTimeTemp] = strtok(v_IniTimeTemp, ':');
    v_IniTime(kk)           = str2double(str_Token);
end

hdr.IniTime = v_IniTime;

end
