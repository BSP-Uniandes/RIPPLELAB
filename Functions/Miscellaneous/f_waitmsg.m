%   f_waitmsg.m [As Part of HFO Detection Project]
%   Written by:
%   Miguel G. Navarrete Mejia
%   Electrical Engineering MS candidate
%   UNIVERSIDAD DE LOS ANDES
%   Colombia, 2012
%   mnavarretem@gmail.com

function st_handle = f_waitmsg(varargin)

switch nargin
    case 0
        pstr_String = [];
        st_handle   = [];
    case 1
        pstr_String = varargin{1};
        st_handle   = [];
    case 2
        st_handle   = varargin{1};
        pstr_String = varargin{2};
    otherwise
        error('s_WaitFigure:argChk', 'Wrong number of input arguments')
        return %#ok<UNRCH>
end

if isfield(st_handle,'s_WaitFigure') && ishandle(st_handle.windowMsg)
    set(st_handle.windowMsg,'String',pstr_String)
else
    st_handle   = [];
    str_HeadMsg             = '...Please Wait...';
    st_handle.s_WaitFigure  = figure(...
                            'Units', 'normalized', ...
                            'BusyAction', 'queue', ...
                            'WindowStyle', 'modal', ...
                            'Position', [.425 .475 .15 .05], ...
                            'Resize','off', ...
                            'CreateFcn','', ...
                            'NumberTitle','off', ...
                            'IntegerHandle','off', ...
                            'MenuBar', 'none', ...
                            'Tag','TMWWaitbar',...
                            'Interruptible', 'off', ...
                            'DockControls', 'off', ...
                            'Visible','on');

    v_FigColor              = get(st_handle.s_WaitFigure,'Color');

    st_handle.windowLabel   = uicontrol(st_handle.s_WaitFigure,...
                            'Style','text',...
                            'BackgroundColor',v_FigColor,...
                            'HorizontalAlignment','center',...      
                            'FontSize',10,...
                            'String',str_HeadMsg,...
                            'Units','normalized',...
                            'Position',[0 .5 1 .45]);

    st_handle.windowMsg     = uicontrol(st_handle.s_WaitFigure,...
                            'Style','text',...
                            'BackgroundColor',v_FigColor,...
                            'HorizontalAlignment','center',...      
                            'FontSize',10,...
                            'String',pstr_String,...
                            'Units','normalized',...
                            'Position',[0 0 1 .45]);                    
end

end