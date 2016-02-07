%   f_GetLetterSize.m [As a part of HFO Detection Project]
%   Written by:
%   Miguel G. Navarrete Mejia
%   Electrical Engineering MS candidate
%   UNIVERSIDAD DE LOS ANDES
%   Colombia, 2012
%   mnavarretem@gmail.com

function st_Letter = f_GetLetterSize
v_ScrennRes     = getmondim;
v_ScrennRes     = v_ScrennRes(1,[3 4]);
switch mat2str(v_ScrennRes)
    case '[800 600]'
        % Size of toolbar labels
        st_Letter.toollabel     = 7.5;
        % Size of toolbar controls
        st_Letter.toolcontrol   = 6;
        
        % Size of position info text in signal panel 
        st_Letter.signalpos     = 8;
    case '[1024 768]'
        % Size of toolbar labels
        st_Letter.toollabel     = 8;
        % Size of toolbar controls
        st_Letter.toolcontrol   = 6.5;
        
        % Size of position info text in signal panel 
        st_Letter.signalpos     = 8.5;
    case '[1280 600]'
    case '[1280 720]'
    case '[1280 768]'
    case '[1360 768]'
    case '[1366 768]'
        % Size of toolbar labels
        st_Letter.toollabel     = 9.5;
        % Size of toolbar controls
        st_Letter.toolcontrol   = 8;
        
        % Size of position info text in signal panel 
        st_Letter.signalpos     = 10;
    case '[1680 1050]'
        % Size of toolbar labels
        st_Letter.toollabel     = 10;
        % Size of toolbar controls
        st_Letter.toolcontrol   = 9;
        
        % Size of position info text in signal panel 
        st_Letter.signalpos     = 13;
    otherwise
          % Size of toolbar labels
        st_Letter.toollabel     = 9.5;
        % Size of toolbar controls
        st_Letter.toolcontrol   = 8;
        
        % Size of position info text in signal panel 
        st_Letter.signalpos     = 10;
        
end
end