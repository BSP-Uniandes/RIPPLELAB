% Function: f_ImageMatrix
% 
% Descrption:
% This function makes the image of the data contained in a matrix. Each
% cell in the matrix is the center of a rectangular pixel. 
% 
% Parameters:
% pm_Data(*): Matrix to display as image
% pv_XAxis: Vector containing the bounds of x axis (see "help imagesc")
% pv_YAxis: Vector containing the bounds of y axis (see "help imagesc")
% pv_Limits: Two-element vector that limits the range of data values in the
% matrix (see "help imagesc")
% pstr_Color: String containing the name of the desired colormap (see
% "help colormap")
% ps_ColorLevels: Number of levels inside the colormap
% ps_NewFigure: Set to 1 to force the creation of a new figure
% ps_InvertImage: Set to 1 to invert upside down the resulting image.
% Default 1.
% ps_SetColorMap: Set to 1 to set the colormap passed above. Default 1.
% 
% (*) Required parameters
% 
function s_Handle = f_ImageMatrix(...
    pm_Data, ...
    pv_XAxis, ...
    pv_YAxis, ...
    pv_Limits, ...
    pstr_Color, ...
    ps_ColorLevels, ...
    ps_NewFigure, ...
    ps_InvertImage, ...
    ps_SetColorMap)

    if nargin < 1
        error('[f_ImageMatrix] - ERROR: Bad number of parameters')
    end

    v_Limits = [];
    str_Color = 'jet';
    s_ColorLevels = 256;
    s_NewFigure = 0;
    s_InvertImage = 1;

    if nargin >= 4 && ~isempty(pv_Limits)
        v_Limits = pv_Limits;
    end
    if nargin >= 5 && ~isempty(pstr_Color)
        str_Color = pstr_Color;
    end
    if nargin >= 6 && ~isempty(ps_ColorLevels)
        s_ColorLevels = ps_ColorLevels;
    end
    if nargin >= 7 && ~isempty(ps_NewFigure)
        s_NewFigure = ps_NewFigure;
    end
    if nargin >= 8 && ~isempty(ps_InvertImage)
        s_InvertImage = ps_InvertImage;
    end
    if ~exist('ps_SetColorMap', 'var') || isempty(ps_SetColorMap)
        ps_SetColorMap = 1;
    end
    
    if s_NewFigure
        figure
    end
    
    if ps_SetColorMap
        str_ColorMap = sprintf('colormap(%s(%d))', str_Color, s_ColorLevels);
        eval(str_ColorMap)
    end
    
    if ~isempty(v_Limits)
        s_Handle = imagesc(pv_XAxis, pv_YAxis, pm_Data, v_Limits);
    else
        s_Handle = imagesc(pv_XAxis, pv_YAxis, pm_Data);
%         image(pv_XAxis, pv_YAxis, pm_Data,'CDataMapping','scaled');
    end
    if s_InvertImage
        axis('xy');
    end
    
return;