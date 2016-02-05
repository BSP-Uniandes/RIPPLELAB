%   f_GetData.m [As a part of HFO Detection Project]
%   Written by:
%   Miguel G. Navarrete Mejia
%   Electrical Engineering MS candidate
%   UNIVERSIDAD DE LOS ANDES
%   Colombia, 2012
%   mnavarretem@gmail.com

function st_Data = f_GetData(pst_Info,pv_TimeLims,ps_Selected)


st_Data.v_Labels    = pst_Info.v_Labels(ps_Selected);
st_Data.s_Sampling  = max(pst_Info.v_SampleRate(ps_Selected));
st_Data.v_TimeLims  = pv_TimeLims;

switch pst_Info.str_FileType
    case 'mat'
        [s_SampleIni,...
               s_SampleEnd]	= f_AskSamplesLims(st_Data.s_Sampling,...
                              pst_Info.s_Time,pv_TimeLims);
                          
        str_LabSelected     = load(pst_Info.str_SigPath,'Header');
        
        
        if isfield(str_LabSelected,'Header')
                
            v_Idx               = ismember(str_LabSelected.Header.Labels,...
                                st_Data.v_Labels);

            st_Data.v_Labels	= str_LabSelected.Header.Labels(v_Idx);
            m_Data              = load(pst_Info.str_SigPath,'Data');
        else
            
            str_LabSelected	= load(sprintf('./Temp/%s','TempHeaderMat.mat'));
            str_LabSelected = str_LabSelected.st_Hdr.Labels;
                        
            v_Idx           = ismember(str_LabSelected,...
                            st_Data.v_Labels);

            st_Data.v_Labels	= str_LabSelected(v_Idx);
            
            m_Data      = load(pst_Info.str_SigPath);
            str_Field	= fieldnames(m_Data);
            m_Data      = m_Data.(str_Field{1});
            
        end
        if isempty(s_SampleIni) && isempty(s_SampleEnd)
            s_SampleIni	= 1;
            s_SampleEnd = size(m_Data.Data,1);
        end                          
        
        st_Data.m_Data      = m_Data.Data(s_SampleIni:s_SampleEnd,v_Idx);
        clear m_Data              
        
    case {'rec' 'edf'}
        [s_SampleIni,...
               s_SampleEnd]	= f_AskSamplesLims(st_Data.s_Sampling,...
                              pst_Info.s_Time,pv_TimeLims);
        str_LabSelected     = st_Data.v_Labels;
        [~,st_Data.m_Data]  = edfread(pst_Info.str_SigPath,...
                            'targetsignals',str_LabSelected);
                        
        if isempty(s_SampleIni)
            s_SampleIni	= 1; 
        end
        
        if isempty(s_SampleEnd)
            s_SampleEnd	= length(st_Data.m_Data);
        end
        
        st_Data.m_Data	= st_Data.m_Data(s_SampleIni:s_SampleEnd)';
                
    case {'data' 'eeg' 'numeric'} 
        
        str_LabSelected     = st_Data.v_Labels;
        
        for kk=1:numel(st_Data.v_Labels)-1
            str_LabSelected{kk}(end+1) = ',';
        end
        
        str_LabSelected     = strcat(cell2mat(str_LabSelected'));
        [s_SampleIni,...
               s_SampleEnd]	= f_AskSamplesLims(st_Data.s_Sampling,...
                              pst_Info.s_Time,pv_TimeLims);
        st_Data.m_Data      = f_GetSignalsNico(pst_Info.str_SigPath,...
                                str_LabSelected,[],[],[],...
                                                s_SampleIni,s_SampleEnd);
        try
        	st_Data.m_Data 	= (st_Data.m_Data * pst_Info.s_Scale)';
        catch error
            errordlg(error.message,'System Error','modal')
            st_Data.m_Data      = [];
            st_Data.v_Labels    = [];
            st_Data.s_Sampling  = [];
            return
        end
        
    case 'ncs'
        
        [s_SampleIni,...
               s_SampleEnd]	= f_AskSamplesLims(st_Data.s_Sampling,...
                              pst_Info.s_Time,pv_TimeLims);

        if isempty(s_SampleIni) && isempty(s_SampleEnd)
            st_ncs              = read_neuralynx_ncs(pst_Info.str_SigPath);
        else
            s_StageIni          = ceil(s_SampleIni/512);
            s_StageEnd          = ceil(s_SampleEnd/512);
            
            st_Data.v_TimeLims  = [((s_StageIni-1) * 512 + 1) ...
                                    / (st_Data.s_Sampling * 60) ...
                                    (s_StageEnd * 512) ...
                                    / (st_Data.s_Sampling * 60)];
            
            st_ncs              = read_neuralynx_ncs(pst_Info.str_SigPath, ...
                                s_StageIni, s_StageEnd);
        end
        st_Data.m_Data      = st_ncs.dat(:);
        clear st_ncs
    otherwise
        
        [s_SampleIni,...
               s_SampleEnd]	= f_AskSamplesLims(st_Data.s_Sampling,...
                              pst_Info.s_Time,pv_TimeLims);

        if isempty(s_SampleIni) && isempty(s_SampleEnd)            
            st_Data.m_Data	= ft_read_data(pst_Info.str_SigPath,...
                            'chanindx',ps_Selected);
                            
        else        
            st_Data.m_Data  = ft_read_data(pst_Info.str_SigPath,...
                            'begsample',s_SampleIni,...
                            'endsample',s_SampleEnd,...
                            'chanindx',ps_Selected);
        end
        st_Data.m_Data  = st_Data.m_Data(:);
        
end

st_Data.v_Time      = ((0:length(st_Data.m_Data)-1)*1/st_Data.s_Sampling)';
                
st_Data.s_TotalTime = st_Data.v_Time(end)-st_Data.v_Time(1);
        
end