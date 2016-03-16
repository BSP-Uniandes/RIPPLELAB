%   f_findHFOxSTF.m [As a part of HFO Detection Project]
%   Written by:
%   Miguel G. Navarrete Mejia
%   Electrical Engineering MS candidate
%   UNIVERSIDAD DE LOS ANDES
%   Colombia, 2012
%   mnavarretem@gmail.com

function m_HFOEvents = f_findHFOxSTE(pstr_SignalPath,ps_SignalIdx,st_DatA,...
                                                s_SampleFrec,st_WaitOutput)
%% Variable declarations
p_HFOWaitFigure(st_WaitOutput,...
                'MethPatch',0)
            
m_Data          = [];

load(pstr_SignalPath)
pv_Signal       = m_Data(:,ps_SignalIdx);
clear m_Data

v_Freqs         = [st_DatA.s_FreqIni st_DatA.s_FreqEnd];% Filter freqs
s_Window        = st_DatA.s_RMSWindow * 1e-3;           % RMS window time (ms)
s_RMSThresSD    = st_DatA.s_RMSThres;                   % Threshold for RMS in standard deviation
s_MinWind       = st_DatA.s_MinWind * 1e-3;             % Min window time for an HFO (ms)
s_MinTime       = st_DatA.s_MinTime * 1e-3;             % Min Distance time Betwen two HFO candidates
s_NumOscMin     = st_DatA.s_NumOscMin;                  % Minimum oscillations per interval
s_BPThresh      = st_DatA.s_BPThresh;                   % Threshold for finding peaks
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

%% RMS Calculus

str_Message     = 'RMS Calculation - Step 2 ....';
p_HFOWaitFigure(st_WaitOutput,...
                'LogsList',str_Message)    

s_Window        = round(s_Window * s_SampleFrec);
if mod(s_Window, 2) == 0
    s_Window = s_Window + 1;
end
v_Temp                      = v_SigFilt.^2;
v_Temp                      = filter(ones(1,s_Window),1,v_Temp)./s_Window;
v_RMS                       = zeros(numel(v_Temp), 1);
v_RMS(1:end - ceil(s_Window / 2) + 1) = v_Temp(ceil(s_Window / 2):end);
v_RMS                       = sqrt(v_RMS);

clear v_Temp

str_Message     = 'RMS Calculation  - OK';

p_HFOWaitFigure(st_WaitOutput,...
                'LogsList',str_Message)            
p_HFOWaitFigure(st_WaitOutput,...
                'MethPatch',2/4)

%% Thresholding

    str_Message     = 'Thresholding Calculation - Step 3 ....';
    p_HFOWaitFigure(st_WaitOutput,...
                    'LogsList',str_Message)       

    s_MinWind       = round(s_MinWind * s_SampleFrec);
    s_MinTime       = round(s_MinTime * s_SampleFrec);
    s_EpochLength   = round(s_EpochLength * s_SampleFrec);
    v_EpochTemp     = (1:s_EpochLength:length(pv_Signal))';
    
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
        
        v_Window        = zeros(numel(v_RMS),1);
        v_Window(m_EpochLims(ii,1):m_EpochLims(ii,2)) = 1;
        
        v_RMSEpoch      = v_RMS.*v_Window;
        v_RMSInterval   = v_RMS(m_EpochLims(ii,1):m_EpochLims(ii,2));
        v_EpochFilt     = v_SigFilt(m_EpochLims(ii,1):m_EpochLims(ii,2));

        v_RMSThres      = v_RMSEpoch > ...
                            (mean(v_RMSInterval)+ ...
                                s_RMSThresSD*std(v_RMSInterval));

        if isempty(numel(find(v_RMSThres)))
            str_Message     = 'Thresholding Calculation - No detected';
            s_BarCount      = s_BarCount + 1;

            p_HFOWaitFigure(st_WaitOutput,...
                            'LogsList',str_Message)            
            p_HFOWaitFigure(st_WaitOutput,...
                            'MethPatch',v_StepBar(s_BarCount))
            continue
        end
                            
        v_WindThres     = [0;v_RMSThres;0];
        v_WindJumps     = diff(v_WindThres);
        v_WindJumUp     = find(v_WindJumps==1);
        v_WindJumDown   = find(v_WindJumps==-1);
        v_WinDist       = v_WindJumDown - v_WindJumUp;

        v_WindIni       = v_WindJumUp(v_WinDist > s_MinWind);  
        v_WindEnd       = v_WindJumDown(v_WinDist > s_MinWind)-1;

        if isempty(v_WindIni)
            str_Message     = 'Thresholding Calculation - No detected';
            s_BarCount      = s_BarCount + 1;
            
            p_HFOWaitFigure(st_WaitOutput,...
                            'LogsList',str_Message)            
            p_HFOWaitFigure(st_WaitOutput,...
                            'MethPatch',v_StepBar(s_BarCount))
            continue
        end
        
        clear v_WindThres v_WindJumps v_WindJumUp v_WindJumDown 
        clear v_DistSelect v_WindSelect   
    
        while 1
            v_NextIni   = v_WindIni(2:end);
            v_LastEnd   = v_WindEnd(1:end-1);
            v_WinIdx	= (v_NextIni - v_LastEnd) < s_MinTime;
            if sum(v_WinIdx)==0
                break
            end
            v_NewEnd    = v_WindEnd(2:end);
            
            v_LastEnd(v_WinIdx) = v_NewEnd(v_WinIdx);
            v_WindEnd(1:end-1)  = v_LastEnd;
            
            v_Idx       = diff([0;v_WindEnd])~=0;
            v_WindIni   = v_WindIni(v_Idx);
            v_WindEnd   = v_WindEnd(v_Idx);        
        end
        
        m_WindIntervals = [v_WindIni v_WindEnd];
        
        clear v_WindSelect v_WindIni v_WindEnd v_WinDist

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

        s_Count             = 1;
        m_WindSelect        = zeros(size(m_WindIntervals));

        s_Threshold         = mean(abs(v_EpochFilt)) + ...
                                        s_BPThresh.*std(abs(v_EpochFilt));
        s_TotalWindInterv	= size(m_WindIntervals,1);


        for jj=1:s_TotalWindInterv

            v_Temp          = abs(v_SigFilt(m_WindIntervals(jj,1):...
                                                    m_WindIntervals(jj,2)));
                                                
            if numel(v_Temp) < 3
                continue
            end
            
            s_NumPeaks      = findpeaks(v_Temp,'minpeakheight',s_Threshold);
            clear v_Temp

            if isempty(s_NumPeaks) || length(s_NumPeaks) < s_NumOscMin
                continue;
            end

            m_WindSelect(s_Count,:) = [m_WindIntervals(jj,1)...
                                                    m_WindIntervals(jj,2)];
            s_Count                 = s_Count + 1;

        end
        
        if any(m_WindSelect(:))
            m_HFOEvents     = vertcat(m_HFOEvents,...
                                    m_WindSelect(1:s_Count-1,:)); %#ok<AGROW>
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
 
end