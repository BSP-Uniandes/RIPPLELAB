%   f_CheckTextNumbers.m [Part of HFO Detection Project]
%   Written by:
%   Miguel G. Navarrete Mejia
%   Electrical Engineering MS candidate
%   UNIVERSIDAD DE LOS ANDES
%   Colombia, 2012
%   mnavarretem@gmail.com

function [v_Numbers,s_Check] = f_CheckTextNumbers(...
                            pstr_Ini,pstr_End,ps_Max,...
                            ps_EmptyZero,ps_DisplayError)
% Check if text is number

% Check if empty text is valid as zero
if nargin <= 4  
    ps_DisplayError = true;
end

if nargin <= 3  
    ps_EmptyZero = 0;
end

if nargin <= 2
    ps_Max       = inf;
end

% Convert String to number
s_ValueIni	= str2double(pstr_Ini);
if ~isempty(pstr_End)
    s_ValueEnd 	= str2double(pstr_End);
elseif isempty(pstr_End) && ps_EmptyZero
    s_ValueEnd	= str2double(pstr_End);
else
    s_ValueEnd	= -1;
end

if ps_EmptyZero 
    if isnan(s_ValueIni) && (strcmpi(pstr_Ini,'-') || isempty(pstr_Ini))
        s_ValueIni	= 0;
    end
    
    if isnan(s_ValueEnd) && (strcmpi(pstr_End,'-') || isempty(pstr_End))
        s_ValueEnd	= 0;
    end
end


% Check if text is number
if isnan(s_ValueIni) || isnan(s_ValueEnd)
    v_Numbers	= NaN;
    if isnan(s_ValueIni)
        s_Check	= -1;
    else
        s_Check	= -2;
    end
    if ps_DisplayError
        errordlg('Values must be numbers','Bad Input','modal')
    end
    return
end

% Check if Value "end" exist
if s_ValueEnd == -1
    v_Numbers	= s_ValueIni;
    s_Check     = 0;
    return
end

if s_ValueEnd == Inf
        s_ValueEnd = ps_Max;
end
    
% Check if Max Value is greater than Max posible Value
if ~isempty(ps_Max) && (ps_Max - s_ValueEnd) < -1e-4
    v_Numbers   = NaN;
    s_Check     = -2;
    
    if ps_DisplayError
        errordlg(['High value can''t be greater than ' num2str(ps_Max)],...
            'Bad Input','modal')
    end
    return
    
elseif (s_ValueEnd > ps_Max)
    s_ValueEnd  = ps_Max;
    
end

% Check if Min Value is greater than Max Value
if s_ValueIni >= s_ValueEnd && ~ps_EmptyZero
    v_Numbers   = NaN;
    s_Check     = -1;
    
    if ps_DisplayError
        errordlg('Max Value is greater than Min Value','Bad Input','modal')
    end
    return
end

v_Numbers   = [s_ValueIni s_ValueEnd];
s_Check     = 0;
end