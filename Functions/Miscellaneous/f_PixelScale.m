function [m_Spectrum, v_Time, v_Freq] = f_PixelScale(...
                                    pm_Spectrum,pv_Time,pv_Freq)
                                
str_PreUnits    = get(gca,'units');
set(gca,'units','pixels')
v_Axepos        = get(gca,'position');
v_Axepos        = round(v_Axepos([3,4]));
set(gca,'units',str_PreUnits)

m_Spectrum      = pm_Spectrum;
v_Time          = pv_Time;
v_Freq          = pv_Freq;

clear pm_Spectrum pv_Time pv_Freq

if size(m_Spectrum,1) > v_Axepos(2)
    
    v_Freq          = linspace(v_Freq(1),v_Freq(end),v_Axepos(2));
    v_IdxIn         = round(linspace(1,...
                    size(m_Spectrum,1)-round(size(m_Spectrum,1)/v_Axepos(2)),...
                    v_Axepos(2)));
    v_IdxEn         = v_IdxIn(2:end) - 1;
    v_IdxEn(end+1)  = size(m_Spectrum,1);
    v_IdxEn         = v_IdxEn(:);
    v_IdxIn         = v_IdxIn(:);
    
    str_IdxEn       = num2str(v_IdxEn(:));
    str_IdxIn       = num2str(v_IdxIn(:));
    str_Concat      = repmat(':',numel(v_IdxIn),1);
    
    str_meanFst     = repmat(' mean(m_Spectrum(',numel(v_IdxIn),1);
    str_meanLst     = repmat(',:));',numel(v_IdxIn),1);
    
    str_EvalStr     = [ str_meanFst str_IdxIn str_Concat str_IdxEn str_meanLst];
    str_EvalStr(1,1)= '[';
    str_EvalStr(end,end)= ']';
    str_EvalStr = str_EvalStr';
    m_Spectrum = eval(str_EvalStr);
end

if size(m_Spectrum,2) > v_Axepos(1)
    
    v_Time          = linspace(v_Time(1),v_Time(end),v_Axepos(1));
    v_IdxIn         = round(linspace(1,...
                    size(m_Spectrum,2)-round(size(m_Spectrum,2)/v_Axepos(1)),...
                    v_Axepos(1)));
    v_IdxEn         = v_IdxIn(2:end) - 1;
    v_IdxEn(end+1)  = size(m_Spectrum,2);
    v_IdxEn         = v_IdxEn(:);
    v_IdxIn         = v_IdxIn(:);
    
    str_IdxEn       = num2str(v_IdxEn(:));
    str_IdxIn       = num2str(v_IdxIn(:));
    str_Concat      = repmat(':',numel(v_IdxIn),1);
    
    str_meanFst     = repmat(' mean(m_Spectrum(:,',numel(v_IdxIn),1);
    str_meanLst     = repmat('),2),',numel(v_IdxIn),1);
    
    str_EvalStr     = [ str_meanFst str_IdxIn str_Concat str_IdxEn str_meanLst];
    str_EvalStr(1,1)= '[';
    str_EvalStr(end,end)= ']';
    str_EvalStr = str_EvalStr';
    m_Spectrum = eval(str_EvalStr);
end