%   f_findHFOxSTF.m [As a part of HFO Detection Project]
%   Written by:
%   Miguel G. Navarrete Mejia
%   Electrical Engineering MS candidate
%   UNIVERSIDAD DE LOS ANDES
%   Colombia, 2012
%   mnavarretem@gmail.com

function m_HFOEvents = f_findHFOxHIL(pstr_SignalPath,ps_SignalIdx,st_DatA,...
                                                s_SampleFrec,st_WaitOutput)
%% Variable declarations
p_HFOWaitFigure(st_WaitOutput,...
                'MethPatch',0)
            
m_Data          = [];

load(pstr_SignalPath)
pv_Signal       = m_Data(:,ps_SignalIdx);
clear m_Data

v_Freqs         = [st_DatA.s_FreqIni st_DatA.s_FreqEnd];% Filter freqs
s_SDThres   	= st_DatA.s_SDThres;                    % Threshold in standard deviation
s_MinWind       = st_DatA.s_MinWind * 1e-3;             % Min window time for an HFO (ms)
s_EpochLength   = st_DatA.s_EpochTime;                  % Cycle Time

%% Preprocessing Filter
str_Message     = 'Filtering Signal - Step 1 ....';

p_HFOWaitFigure(st_WaitOutput,...
                'LogsList',str_Message)            
p_HFOWaitFigure(st_WaitOutput,...
                'MethPatch',0)
            
s_Filter        = f_GetIIRFilter(s_SampleFrec,v_Freqs);
v_SigFilt       = f_IIRBiFilter(pv_Signal,s_Filter);
clear s_Filter

str_Message     = 'Filtering Signal  - OK';

p_HFOWaitFigure(st_WaitOutput,...
                'LogsList',str_Message)            
p_HFOWaitFigure(st_WaitOutput,...
                'MethPatch',1/4)
%% Hilbert transform Calculus

str_Message     = 'Hilbert Transform Calculation - Step 2 ....';
p_HFOWaitFigure(st_WaitOutput,...
                'LogsList',str_Message)   
            
v_SigFilt       = abs(hilbert(v_SigFilt));

str_Message     = 'Hilbert Transform Calculation  - OK';

p_HFOWaitFigure(st_WaitOutput,...
                'LogsList',str_Message)            
p_HFOWaitFigure(st_WaitOutput,...
                'MethPatch',2/4)
            
%% Thresholding

    str_Message     = 'Thresholding Calculation - Step 2 ....';
    p_HFOWaitFigure(st_WaitOutput,...
                    'LogsList',str_Message)       

    s_EpochLength   = round(s_EpochLength * s_SampleFrec);
    v_EpochTemp     = (1:s_EpochLength:length(pv_Signal))';
    s_MinWind       = round(s_MinWind * s_SampleFrec);
    
    if v_EpochTemp(end) < length(pv_Signal)
        v_EpochTemp(end+1)  = length(pv_Signal);
    end
    
    m_EpochLims     = [v_EpochTemp(1:end-1) v_EpochTemp(2:end)-1];
    s_Epochs        = size(m_EpochLims,1);
    
    clear v_EpochTemp s_EpochLength
    
    m_HFOEvents = [];  
    v_StepBar   = 1/2 + (.5:.5:s_Epochs)./(2*s_Epochs); 
    s_BarCount  = 0;
    
    for ii = 1:size(m_EpochLims,1)
        
        str_Message     = ['Thresholding Calculation - Epoch '...
                                    num2str(ii) ' of ' num2str(s_Epochs)];
        s_BarCount      = s_BarCount + 1;
        p_HFOWaitFigure(st_WaitOutput,...
                        'LogsList',str_Message)            
        p_HFOWaitFigure(st_WaitOutput,...
                        'MethPatch',v_StepBar(s_BarCount))
        
        v_EpochFilt     = v_SigFilt(m_EpochLims(ii,1):m_EpochLims(ii,2));
        
        v_WinThres      = v_EpochFilt > ...
                            (mean(v_EpochFilt)+ s_SDThres*std(v_EpochFilt));

        if isempty(numel(find(v_WinThres)))
            str_Message     = 'Thresholding Calculation - No detected';
            s_BarCount      = s_BarCount + 1;

            p_HFOWaitFigure(st_WaitOutput,...
                            'LogsList',str_Message)            
            p_HFOWaitFigure(st_WaitOutput,...
                            'MethPatch',v_StepBar(s_BarCount))
            continue
        end
                            
        v_WindThres     = [0;v_WinThres;0];
        v_WindJumps     = diff(v_WindThres);
        v_WindJumUp     = find(v_WindJumps==1);
        v_WindJumDown   = find(v_WindJumps==-1)-1;        
        v_WinDist       = v_WindJumDown - v_WindJumUp;

        v_DistSelect    = (v_WinDist > s_MinWind);
        v_WindJumUp     = v_WindJumUp(v_DistSelect);  
        v_WindJumDown   = v_WindJumDown(v_DistSelect)-1;


        str_Message     = 'Thresholding Calculation - OK';
        
        p_HFOWaitFigure(st_WaitOutput,...
                        'LogsList',str_Message)            
        p_HFOWaitFigure(st_WaitOutput,...
                        'MethPatch',v_StepBar(s_BarCount))
        
        str_Message     = ['Interval Selection - Epoch '...
                                    num2str(ii) ' of ' num2str(s_Epochs)];
        s_BarCount      = s_BarCount + 1;
        
        p_HFOWaitFigure(st_WaitOutput,...
                        'LogsList',str_Message)            
        p_HFOWaitFigure(st_WaitOutput,...
                        'MethPatch',v_StepBar(s_BarCount))

        m_WindSelect	= [v_WindJumUp v_WindJumDown] + m_EpochLims(ii,1)-1;
        
        if any(m_WindSelect(:))
            m_HFOEvents     = vertcat(m_HFOEvents,m_WindSelect); %#ok<AGROW>
        end
        
        str_Message     = 'Interval Selection - OK';
        
        p_HFOWaitFigure(st_WaitOutput,...
                        'LogsList',str_Message)            
        p_HFOWaitFigure(st_WaitOutput,...
                        'MethPatch',v_StepBar(s_BarCount))

    end


str_Message = 'HFO Detection - OK';

p_HFOWaitFigure(st_WaitOutput,...
    'LogsList',str_Message)
p_HFOWaitFigure(st_WaitOutput,...
    'MethPatch',1)
 
%% Last
% % m_WindSelect                = m_WindSelect(1:s_Count-1,:);
% v_WindInter         = zeros(numel(v_EpochFilt),1);
% for kk=1:length(m_WindIntervals)-1
%     v_WindInter(m_WindIntervals(kk,1):m_WindIntervals(kk,2))   = 1;
% end

% v_WindInterPks    = zeros(numel(pv_Signal),1);
% for kk=1:length(m_WindSelect)
% %     v_WindInterPks(m_WindSelect(kk,1):m_WindSelect(kk,2))   = 1;
% % end
% figure
% % plot(v_SigFilt,'b')
% hold on;
% plot(v_EpochFilt,'g')
% plot(v_WindInter.*v_EpochFilt,'r')

% plot(abs(v_RMS),'r')
% plot(0.5*v_RMSThres,'y')
% plot(v_WindInter,'m')
% plot(50*v_WindInterPks,'g')
% plot((mean(v_RMS)+ s_RMSThresSD*std(v_RMS)).*ones(1,numel(v_RMS)),'y');

% hold off

end