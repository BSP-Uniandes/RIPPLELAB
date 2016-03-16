%   f_findHFOxSLL.m [As a part of HFO Detection Project]
%   Written by:
%   Miguel G. Navarrete Mejia
%   Electrical Engineering MS candidate
%   UNIVERSIDAD DE LOS ANDES
%   Colombia, 2012
%   mnavarretem@gmail.com

function m_HFOEvents = f_findHFOxSLL(pstr_SignalPath,ps_SignalIdx,st_HFOData,...
                                                s_SampleFrec,st_WaitOutput)
%% Variable declarations

p_HFOWaitFigure(st_WaitOutput,...
                'MethPatch',0)

m_Data          = [];

load(pstr_SignalPath)
pv_Signal       = m_Data(:,ps_SignalIdx);
clear m_Data

v_Freqs         = [st_HFOData.s_FreqIni  st_HFOData.s_FreqEnd];

s_Window        = round(st_HFOData.s_FiltWind * 1e-3 * s_SampleFrec);
s_EpochWind     = st_HFOData.s_EpochTime;
s_Percentil     = st_HFOData.s_Percentil * 1e-2;
s_MinWind       = st_HFOData.s_MinWind * 1e-3; 

%% Equalization Filter

str_Message     = 'Preprocessing Signal - Step 1 ....';

p_HFOWaitFigure(st_WaitOutput,...
                'LogsList',str_Message)            
p_HFOWaitFigure(st_WaitOutput,...
                'MethPatch',0)


v_FiltSignal    = f_EqualizerFreqFilter(pv_Signal,s_SampleFrec,1,v_Freqs);

%% Bandpass Filter

s_Filter                = f_GetIIRFilter(s_SampleFrec,v_Freqs);
v_FiltSignal            = f_IIRBiFilter(v_FiltSignal,s_Filter);

str_Message     = 'Filtering Signal  - OK';

p_HFOWaitFigure(st_WaitOutput,...
                'LogsList',str_Message)            
p_HFOWaitFigure(st_WaitOutput,...
                'MethPatch',1/4)

%% Energy Line Length

str_Message     = 'Energy Line Calculation - Step 2 ....';
p_HFOWaitFigure(st_WaitOutput,...
                'LogsList',str_Message)            

v_FiltSignal    = v_FiltSignal(:);
v_FiltSignal    = [v_FiltSignal(1);v_FiltSignal];
v_Temp          = abs(diff(v_FiltSignal));
v_Temp          = filter(ones(1,s_Window),1,v_Temp)./s_Window;
v_Energy        = zeros(numel(v_Temp), 1);
v_Energy(1:end - ceil(s_Window / 2) + 1) = 10*v_Temp(ceil(s_Window / 2):end);

% Window to the 1% for edge cutting
v_EdgeWind      = gausswin(round(numel(v_Energy)*.01),5.25);
v_EdgeWind      = v_EdgeWind(:);
[~,s_CenterIdx] = max(v_EdgeWind);
v_EdgeWind      = vertcat(v_EdgeWind(1:s_CenterIdx),...
                ones(numel(v_Energy)-numel(v_EdgeWind),1),...
                v_EdgeWind(s_CenterIdx+1:end));

v_Energy        = v_Energy.*v_EdgeWind;

str_Message     = 'Energy Line Calculation  - OK';
p_HFOWaitFigure(st_WaitOutput,...
                'LogsList',str_Message)            
p_HFOWaitFigure(st_WaitOutput,...
                'MethPatch',2/4)
            
%% Thresholding

str_Message     = 'Thresholding Calculation - Step 3 ....';
p_HFOWaitFigure(st_WaitOutput,...
                'LogsList',str_Message)            

s_MinWind       = round(s_MinWind * s_SampleFrec);
s_EpochWind     = round(s_EpochWind .* s_SampleFrec);
s_Epochs        = round(numel(v_Energy)/s_EpochWind);
v_Threshold     = zeros(numel(v_Energy),1);

for kk=1:s_Epochs
    
    str_Message     = ['Thresholding Calculation - Epoch '...
                    num2str(kk) ' of ' num2str(s_Epochs)];
                
    p_HFOWaitFigure(st_WaitOutput,'LogsList',str_Message)            
    
    s_Ini	= floor((kk-1) .* s_EpochWind)+1;
    s_End	= s_Ini + s_EpochWind;
    
    if s_End > numel(v_Energy)
        s_End   = numel(v_Energy);
    end
    
    v_Perc	= edfcnd(v_Energy(s_Ini:s_End),-inf,[],'method',3);
    v_Val	= v_Perc(:,1);
    v_Perc  = v_Perc(:,2);
    
    s_Index	= find(v_Perc <= s_Percentil,1,'last');
    
    v_Threshold(s_Ini:s_End)= v_Val(s_Index);
    
end

str_Message     = 'Thresholding Calculation - OK';
p_HFOWaitFigure(st_WaitOutput,...
                'LogsList',str_Message)
p_HFOWaitFigure(st_WaitOutput,...
                'MethPatch',3/4)
            
str_Message     = 'Interval Selection - Step 4 ....';

p_HFOWaitFigure(st_WaitOutput,...
                'LogsList',str_Message)
p_HFOWaitFigure(st_WaitOutput,...
                'MethPatch',3/4)

v_EnergyThres   = v_Energy >= v_Threshold;


v_WindThres     = [0;v_EnergyThres;0];
v_WindJumps     = diff(v_WindThres);
v_WindJumUp     = find(v_WindJumps==1);
v_WindJumDown   = find(v_WindJumps==-1);
v_WinDist       = v_WindJumDown - v_WindJumUp;

v_WinDistSelect = (v_WinDist > s_MinWind);

v_WindSelect    = find(v_WinDistSelect);

if isempty(v_WindSelect)
    m_HFOEvents	= [];
else
    m_HFOEvents	= [v_WindJumUp(v_WindSelect) ...
                                            v_WindJumDown(v_WindSelect)-1];
end

str_Message     = 'Interval Selection - OK';

p_HFOWaitFigure(st_WaitOutput,...
                'LogsList',str_Message)
p_HFOWaitFigure(st_WaitOutput,...
                'MethPatch',4/4)

str_Message = 'HFO Detection - OK';

p_HFOWaitFigure(st_WaitOutput,...
                'LogsList',str_Message)
p_HFOWaitFigure(st_WaitOutput,...
                'MethPatch',4/4)

%% Last

% v_ThreSelected  = zeros(numel(v_Energy),1);
% 
% for kk = 1:numel(v_WindIniSelect)
%     v_ThreSelected(v_WindIniSelect(kk):v_WindEndSelect(kk)) = 10;
% end
% 
% figure(2)
% % plot(pv_Signal,'b');
% hold on;
% plot(v_FiltSignal,'g');plot(v_Energy,'r');plot(v_Threshold,'b');
% plot(v_EnergyThres,'b');plot(v_ThreSelected,'m');
% hold off

end