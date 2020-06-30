function vt_out = f_ListEventClasses()
% List event class for ripple classification. For adding more clasess
% consider including names after position 7.

vt_out	= {...
        'None';...          % Original class 1 
        'Gamma';...         % Original class 2 
        'Ripple';...        % Original class 3 
        'FastRipple';...    % Original class 4 
        'Spike';...         % Original class 5 
        'Artifact';...      % Original class 6 
        'Other';...         % Original class 7 
        'New class';...     % Add new classes from here 
        };
