%   f_findHFOxEnEnt.m [As a part of HFO Detection Project]
%   Written by:
%   Miguel G. Navarrete Mejia
%   Electrical Engineering MS candidate
%   UNIVERSIDAD DE LOS ANDES
%   Colombia, 2012
%   mnavarretem@gmail.com
function m_HFOEvents = f_findHFOxMNI(pstr_SignalPath,ps_SignalIdx,...
                                    st_HFOData,s_SampleFrec,st_WaitOutput)
                                
%% Variable declarations

if ~isempty(st_WaitOutput)
    p_HFOWaitFigure(st_WaitOutput,...
        'MethPatch',0)
end
            
m_Data          = [];

load(pstr_SignalPath)

if ps_SignalIdx > size(m_Data,2) && size(m_Data,2) == 1
    ps_SignalIdx    = 1;
end

v_Signal        = m_Data(:,ps_SignalIdx);

clear m_Data

v_Freqs         = [st_HFOData.s_FreqIni st_HFOData.s_FreqEnd];  % Filter freqs
s_Epoch         = st_HFOData.s_EpochTime;                       % Cycle Time
s_EpoCHF        = st_HFOData.s_EpoCHF;                          % Continous High Frequency Epoch
s_PerCHF        = st_HFOData.s_PerCHF/100;                      % Continous High Frequency Percentil Threshold       
s_MinWin        = st_HFOData.s_MinWin * 1e-3;                   % Minimum HFO Time     
s_MinGap        = st_HFOData.s_MinGap * 1e-3;                   % Minimum HFO Gap
s_ThresPerc     = st_HFOData.s_ThresPerc/100;                   % Threshold precentil
s_BaseSeg       = st_HFOData.s_BaseSeg*1e-3;                    % Baseline window    
s_BaseShift     = st_HFOData.s_BaseShift;                       % Baseline Shift window    
s_BaseThr       = st_HFOData.s_BaseThr;                         % Baseline threshold
s_BaseMin       = st_HFOData.s_BaseMin;	                        % Baseline minimum time
        
clear st_HFOData

%% Preprocessing Filter
str_Message     = 'Filtering Signal - Step 1 ....';

p_HFOWaitFigure(st_WaitOutput,...
                'LogsList',str_Message)            
p_HFOWaitFigure(st_WaitOutput,...
                'MethPatch',0)
            
s_Filter        = f_GetIIRFilter(s_SampleFrec,v_Freqs);
v_SigFilt       = f_IIRBiFilter(v_Signal,s_Filter);

clear s_Filter

str_Message     = 'Filtering Signal  - OK';

p_HFOWaitFigure(st_WaitOutput,...
                'LogsList',str_Message)            
p_HFOWaitFigure(st_WaitOutput,...
                'MethPatch',1/12)
            
%% RMS Calculus

str_Message     = 'RMS Calculation - Step 2 ....';
p_HFOWaitFigure(st_WaitOutput,...
                'LogsList',str_Message)    

s_Window        = round(0.002 * s_SampleFrec);
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
                'MethPatch',1/6)
            
%% Baseline detection

str_Message         = 'Baseline detection - Step 2 ....';

p_HFOWaitFigure(st_WaitOutput,...
                'LogsList',str_Message)            
            
s_EpochSamples      = round(s_BaseSeg * s_SampleFrec);
s_FreqSeg           = numel(v_Freqs(1):5:v_Freqs(2));
s_StDevCycles       = 3;
% s_WEMax             = 1/log10(s_FreqSeg);   %The maximum theoretical wavelet 
                                            %entropy (WEmax)is obtained for
                                            %white noise, when contributions 
                                            %at all scales are similar

s_WEMax             = zeros(100,1); % Simulation of maximum baseline based in
                                    % the calculus of uniform random
                                    % values

for kk = 1:100 

    v_Segment       = rand(s_EpochSamples,1);
    v_AutoCorr      = xcorr(v_Segment)./sum(v_Segment.^2);
    [m_WCoef,~,~]	= f_GaborTransformWait(v_AutoCorr,...
                                s_SampleFrec, v_Freqs(1),v_Freqs(2),...
                                s_FreqSeg,s_StDevCycles);
                            
    m_ProbEnerg     = mean(m_WCoef.^2,2)/sum(mean(m_WCoef.^2,2));
    s_WEMax(kk)     = -sum(m_ProbEnerg.*log(m_ProbEnerg));
end

clear v_Segment m_ProbEnerg m_WCoef

s_WEMax             = median(s_WEMax);
v_InIndex           = 1:round(s_EpochSamples*s_BaseShift):numel(v_Signal);
v_EnIndex           = v_InIndex + s_EpochSamples - 1;
v_Idx               = v_EnIndex > numel(v_Signal);
v_InIndex(v_Idx)    = [];
v_EnIndex(v_Idx)    = [];
clear v_Idx

v_BaselineWindow	= zeros(size(v_SigFilt));

for kk = 1:numel(v_InIndex)  

    p_HFOWaitFigure(st_WaitOutput,...
                'MethPatch',1/6 + kk/(2*numel(v_InIndex)))
            
    v_AutoCorr      = xcorr(v_SigFilt(v_InIndex(kk):v_EnIndex(kk)))./...
                    sum((v_SigFilt(v_InIndex(kk):v_EnIndex(kk))).^2);
    [m_WCoef,~,~]	= f_GaborTransformWait(v_AutoCorr,...
                    s_SampleFrec, v_Freqs(1),v_Freqs(2),...
                    s_FreqSeg,s_StDevCycles);
                            
    m_ProbEnerg 	= mean(m_WCoef.^2,2)/sum(mean(m_WCoef.^2,2));
    s_WESection     = -sum(m_ProbEnerg.*log(m_ProbEnerg));
    
    if s_WESection < s_BaseThr*s_WEMax;
        v_BaselineWindow(v_InIndex(kk):v_EnIndex(kk))   = 1;
    end
end

clear m_ProbEnerg m_WCoef

str_Message     = 'Baseline detection  - OK';

p_HFOWaitFigure(st_WaitOutput,...
                'LogsList',str_Message)            
p_HFOWaitFigure(st_WaitOutput,...
                'MethPatch',2/3)

%% Threshold calculation
   
str_Message     = 'Thresholding Calculation - Step 3 ....';
p_HFOWaitFigure(st_WaitOutput,...
    'LogsList',str_Message)
 
s_WindSamples	= (s_BaseMin/60) * numel(v_Signal);
s_MinWin        = s_MinWin * s_SampleFrec;
if sum(v_BaselineWindow) >= s_WindSamples
    v_Threshold     = f_PosBaseline();
else
    v_Threshold     = f_NegBaseline();
end

str_Message     = 'Thresholding Calculation - OK ';
p_HFOWaitFigure(st_WaitOutput,...
    'LogsList',str_Message)
p_HFOWaitFigure(st_WaitOutput,...
    'MethPatch',5/6)

%% Event detection

str_Message     = 'Envent Selection - Step 4 ....';

p_HFOWaitFigure(st_WaitOutput,...
    'LogsList',str_Message)

v_EnergyThres   = v_RMS >= v_Threshold;

v_WindThres     = [0;v_EnergyThres;0];
v_WindJumps     = diff(v_WindThres);
v_WindJumUp     = find(v_WindJumps==1);
v_WindJumDown   = find(v_WindJumps==-1);
v_WinDist       = v_WindJumDown - v_WindJumUp;

v_WinDistSelect = (v_WinDist > s_MinWin);

v_WindSelect    = find(v_WinDistSelect);

if isempty(v_WindSelect)
    str_Message     = 'Envent Selection - No detected';
    m_HFOEvents     = [];
    
    p_HFOWaitFigure(st_WaitOutput,...
        'LogsList',str_Message)
    p_HFOWaitFigure(st_WaitOutput,...
        'MethPatch',1)
    return
end

v_WindIni	= v_WindJumUp(v_WindSelect);
v_WindEnd	= v_WindJumDown(v_WindSelect);
s_MinGap	= s_MinGap * s_SampleFrec;

clear v_WindThres v_WindJumps v_WindJumUp v_WindJumDown
clear v_DistSelect v_WindSelect

while 1
    
    if isempty(v_WindIni)
        str_Message     = 'Envent Selection - No detected';
        m_HFOEvents     = [];
        
        p_HFOWaitFigure(st_WaitOutput,...
            'LogsList',str_Message)
        p_HFOWaitFigure(st_WaitOutput,...
            'MethPatch',1)
        return
    end
    
    if numel(v_WindIni) <2
        break
    end
    
    v_NextIni   = v_WindIni(2:end);
    v_LastEnd   = v_WindEnd(1:end-1);
    v_WinIdx	= (v_NextIni - v_LastEnd) < s_MinGap;
    
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

m_HFOEvents     = [v_WindIni v_WindEnd];

clear v_WindSelect v_WindIni v_WindEnd v_WinDist

str_Message     = 'Envent Selection - OK';

p_HFOWaitFigure(st_WaitOutput,...
    'LogsList',str_Message)

str_Message = 'HFO Detection - OK';

p_HFOWaitFigure(st_WaitOutput,...
    'LogsList',str_Message)
p_HFOWaitFigure(st_WaitOutput,...
    'MethPatch',1)
        
%% Functions      
%::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
    function v_Threshold = f_PosBaseline()     
        
        s_WindowThreshold   = round(s_Epoch * s_SampleFrec);
        v_BaselineWindow    = v_BaselineWindow(:);
        v_WindBaseline      = diff([0;v_BaselineWindow;0]);
        v_WindBaselineUp    = find(v_WindBaseline==1);         
        v_WindBaselineDown	= find(v_WindBaseline==-1)-1;
        
        v_IdxIni            = [];
        
        for jj = 1:numel(v_WindBaselineUp) 
            v_IdxAdd    = v_WindBaselineUp(jj):s_WindowThreshold:...
                        v_WindBaselineDown(jj);
                
            v_IdxIni    = horzcat(v_IdxIni,v_IdxAdd); %#ok<AGROW>
        end
        
        v_IdxEnd        = v_IdxIni + s_WindowThreshold -1;  
        
        v_IdxRem            = v_IdxEnd > numel(v_RMS);
        v_IdxIni(v_IdxRem)  = [];
        v_IdxEnd(v_IdxRem)  = [];

        v_Threshold     = zeros(size(v_RMS));
        
        for jj = 1:numel(v_IdxIni) 
            p_HFOWaitFigure(st_WaitOutput,...
                'MethPatch',2/3 + jj/(6*numel(v_IdxIni)))
            v_Section   = sort(v_RMS(v_IdxIni(jj):v_IdxEnd(jj)),'ascend');
            v_GamParams = fb_gamfit(v_Section);
            v_Percent   = fb_gamcdf(v_Section,v_GamParams(1),v_GamParams(2)); 
            s_Index     = find(v_Percent <= s_ThresPerc,1,'last');   
            v_Threshold(v_IdxIni(jj):v_IdxEnd(jj)) = v_Section(s_Index);
        end
        
    end
%::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
    function v_Threshold = f_NegBaseline()        
                            
        s_WindowCHF         = round(s_EpoCHF * s_SampleFrec);            
        
        v_IdxIni            = 1:s_WindowCHF:numel(v_RMS);
        v_IdxEnd            = v_IdxIni + s_WindowCHF - 1;
        v_IdxRem            = v_IdxEnd > numel(v_RMS);
        v_IdxIni(v_IdxRem)	= [];
        v_IdxEnd(v_IdxRem)	= [];
        
        v_Threshold     = zeros(size(v_RMS));
        
        for jj = 1:numel(v_IdxIni) 
            p_HFOWaitFigure(st_WaitOutput,...
                'MethPatch',2/3 + jj/(6*numel(v_IdxIni)))
            v_Section   = sort(v_RMS(v_IdxIni(jj):v_IdxEnd(jj)),'ascend');
            s_ThresLast = max(v_Section);
            
            while 1
                
                if sum(abs(v_Section)) == 0
                    break
                end
                
                v_GamParams = gamfit(v_Section);
                v_Percent   = gamcdf(v_Section,v_GamParams(1),v_GamParams(2));
                s_ThresNew	= v_Section(find(v_Percent <= s_PerCHF,1,'last'));
                
                v_EnergyOver   = v_Section >= s_ThresNew;
                v_WindThr       = [0;v_EnergyOver;0];
                v_Jumps         = diff(v_WindThr);
                v_JumUp         = find(v_Jumps==1);
                v_JumDown       = find(v_Jumps==-1)-1;
                v_Dist          = v_JumDown - v_JumUp;
                
                v_Select        = (v_Dist > s_MinWin);                
                v_Select        = find(v_Select);
                
                if isempty(v_Select)
                    break
                end
                
                v_Ini       = v_JumUp(v_Select);
                v_End       = v_JumDown(v_Select);
                
                for ii = 1:numel(v_Ini)
                    v_Section(v_Ini(ii):v_End(ii))  = 0;
                    v_Section                       = sort(v_Section,'ascend');
                end
                
                s_ThresLast	= s_ThresNew;
                
            end  
            
            v_Threshold(v_IdxIni(jj):v_IdxEnd(jj)) = s_ThresLast;
        end
         
    end
end