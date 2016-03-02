%   f_GetData.m [As a part of HFO Detection Project]
%   Written by:
%   Miguel G. Navarrete Mejia
%   Electrical Engineering MS candidate
%   UNIVERSIDAD DE LOS ANDES
%   Colombia, 2012
%   mnavarretem@gmail.com

function st_Data = f_GetData(pst_Info,pv_TimeLims,pv_Selected)
% Reads channels data from eeg files
% INPUT:
% pst_Info	= Information structure 
%
%     st_Info.SigPath     = Full Path of signal file
%     st_Info.SigName     = Signal Name;
%     st_Info.SigExt      = File extension for signal type;
%     st_Info.str_FileType= File Type
%     st_Info.Start       = Absolute start time
%     st_Info.Time        = Time length of record in mins;
%     st_Info.SampleRate  = Sample rate for signal;
%     st_Info.NumbRec     = Number of records;
%     st_Info.Labels      = Label of records;
%     st_Info.Scale       = Amplitude scale;
%     st_Info.error       = Reading Error;
%     st_Info.AmpScaleRec = Amplitude scale for record;
%     st_Info.MinMaxRec   = min value and max value per record;
%     st_Info.Custom      = Structure with custom information according with
%                           type
%
% pv_TimeLims       = Time limits of channels to load
% pv_Selected

% OUTPUT
% 
% st_Data	= Data structure 
%
%     st_Data.v_Labels    = Labels of selected channels;
%     st_Data.s_Sampling  = Frequency sample;
%     st_Data.v_TimeLims  = Time limits of channels to load;
%     st_Data.m_Data      = mxn matrix of channels samples m: samples, n:channels
%     st_Data.v_Time      = Time vector;                
%     st_Data.s_TotalTime = Total time in seconds;


st_Data.v_Labels    = pst_Info.v_Labels(pv_Selected);
st_Data.s_Sampling  = pst_Info.v_SampleRate(pv_Selected(1));
st_Data.v_TimeLims  = pv_TimeLims;

try
    switch pst_Info.str_FileType
        case 'mat'
            [s_Start,s_End]	= f_AskSamplesLims(st_Data.s_Sampling,...
                            pst_Info.s_Time,pv_TimeLims);


            if isfield(pst_Info.st_Custom, 'Structure')
                if ~strcmp(pst_Info.st_Custom.Structure,...
                            '[f_ConvertMatFile]:RIPPLELABconvertedMATfile')

                    errordlg('Unrecognized MAT file format','System Error','modal')
                    st_Data.m_Data      = [];
                    st_Data.v_Labels    = [];
                    st_Data.s_Sampling  = [];
                    return
                end

                str_LabSelected     = pst_Info.v_Labels;                        
                v_Idx               = ismember(str_LabSelected,st_Data.v_Labels);
                st_Data.v_Labels    = str_LabSelected(v_Idx);
                m_Data.Data         = load(pst_Info.str_SigPath,...
                                    pst_Info.st_Custom.DataVar);
                m_Data.Data         = m_Data.Data.(pst_Info.st_Custom.DataVar);
                m_Data.Data         = m_Data.Data .* pst_Info.s_Scale;
            else     
                str_LabSelected     = load(pst_Info.str_SigPath,'Header');
                v_Idx               = ismember(str_LabSelected.Header.Labels,...
                                    st_Data.v_Labels);
                
                st_Data.v_Labels	= str_LabSelected.Header.Labels(v_Idx);
                m_Data              = load(pst_Info.str_SigPath,'Data');
            end

            if find(size(m_Data.Data) == numel(v_Idx)) == 1
                m_Data.Data = m_Data.Data';
            end             

            if isempty(s_Start) 
                s_Start	= 1;
            end
            if isempty(s_End)
                s_End   = size(m_Data.Data,1);
            end                          

            st_Data.m_Data  = single(m_Data.Data(s_Start:s_End,v_Idx));
            clear m_Data              

        case {'rec' 'edf'}
            [s_Start,s_End]	= f_AskSamplesLims(st_Data.s_Sampling,...
                            pst_Info.s_Time,pv_TimeLims);

            st_Data.m_Data  = single(...
                            ft_read_data(pst_Info.str_SigPath,...
                            'begsample',s_Start,...
                            'endsample',s_End,...
                            'chanindx',pv_Selected));

            if find(size(st_Data.m_Data) == numel(pv_Selected)) == 1
                st_Data.m_Data	= st_Data.m_Data';
            end             

        case {'data' 'eeg' 'numeric'} 

            str_LabSelected	= st_Data.v_Labels(:)';
            str_LabSelected = vertcat(str_LabSelected,repmat({','},...
                            size(str_LabSelected)));

            str_LabSelected	= strcat(cell2mat(str_LabSelected(:)'));

            [s_Start,s_End]	= f_AskSamplesLims(st_Data.s_Sampling,...
                            pst_Info.s_Time,pv_TimeLims);

            st_Data.m_Data  = single(...
                            f_GetSignalsNico(pst_Info.str_SigPath,...
                            str_LabSelected,[],[],[],s_Start,s_End));

            if find(size(st_Data.m_Data) == numel(pv_Selected)) == 1
                st_Data.m_Data	= st_Data.m_Data';
            end

        case 'ncs'

            [s_Start,s_End]	= f_AskSamplesLims(st_Data.s_Sampling,...
                                  pst_Info.s_Time,pv_TimeLims);

            if isempty(s_Start) && isempty(s_End)
                st_ncs      = read_neuralynx_ncs(pst_Info.str_SigPath);
            else
                s_StageIni  = ceil(s_Start/512);
                s_StageEnd  = ceil(s_End/512);

                st_Data.v_TimeLims	= [((s_StageIni-1) * 512 + 1) ...
                                    / (st_Data.s_Sampling * 60) ...
                                    (s_StageEnd * 512) ...
                                    / (st_Data.s_Sampling * 60)];

                st_ncs              = single(...
                                    read_neuralynx_ncs(pst_Info.str_SigPath, ...
                                    s_StageIni, s_StageEnd));
            end

            if find(size(st_ncs.dat) == numel(pv_Selected)) == 1
                st_Data.m_Data	= st_ncs.dat';
            end         

            clear st_ncs

        case 'trc'

            [s_Start,s_End]	= f_AskSamplesLims(st_Data.s_Sampling,...
                            pst_Info.s_Time,pv_TimeLims);

            s_Check         = exist('f_GetSignalsTRC','file');

            if s_Check == 6

                str_LabSelected	= st_Data.v_Labels(:)';
                str_LabSelected = vertcat(str_LabSelected,repmat({','},...
                                size(str_LabSelected)));

                str_LabSelected	= strcat(cell2mat(str_LabSelected(:)'));
                st_Data.m_Data	= single(...
                                f_GetSignalsTRC(pst_Info.str_SigPath,...
                                str_LabSelected,...
                                s_Start,s_End));

                if find(size(st_Data.m_Data) == numel(pv_Selected)) == 1
                    st_Data.m_Data	= st_Data.m_Data';
                end

            else

                if isempty(s_Start) && isempty(s_End)            
                    st_Data.m_Data	= single(...
                                    ft_read_data(pst_Info.str_SigPath,...
                                    'chanindx',pv_Selected));

                else        
                    st_Data.m_Data  = single(...
                                    ft_read_data(pst_Info.str_SigPath,...
                                    'begsample',s_Start,...
                                    'endsample',s_End,...
                                    'chanindx',pv_Selected));
                end

                if find(size(st_Data.m_Data) == numel(pv_Selected)) == 1
                    st_Data.m_Data	= st_Data.m_Data';
                end
            end

        case 'plx'

            [s_Start,s_End]	= f_AskSamplesLims(st_Data.s_Sampling,...
                            pst_Info.s_Time,pv_TimeLims);

            if isempty(s_Start) && isempty(s_End)   
                st_Data.m_Data  = single(...
                                ft_read_data(pst_Info.str_SigPath,...
                                'begsample',1,...
                                'endsample',inf,...
                                'chanindx',pv_Selected));

            else        
                st_Data.m_Data  = single(...
                                ft_read_data(pst_Info.str_SigPath,...
                                'begsample',s_Start,...
                                'endsample',s_End,...
                                'chanindx',pv_Selected));
            end                       

            if find(size(st_Data.m_Data) == numel(pv_Selected)) == 1
                st_Data.m_Data	= st_Data.m_Data';
            end

        case 'abf'

            [s_Start,s_End]	= f_AskSamplesLims(st_Data.s_Sampling,...
                            pst_Info.s_Time,pv_TimeLims);
            str_LabSelected = st_Data.v_Labels(:)';

            if isempty(s_End) 
                s_Start	= 0;
            end

            if isempty(s_End)  
                s_End	= 'e';
            end

            st_Data.m_Data	= abfload(pst_Info.str_SigPath,...
                            'channels',str_LabSelected,...
                            'start',s_Start,...
                            'stop',s_End);

            if find(size(st_Data.m_Data) == numel(pv_Selected)) == 1
                st_Data.m_Data	= st_Data.m_Data';
            end

%         case 'new'  % Read new format file >>>>>>>>>>> [**INSERT!**] <<<<<<<<< 
% 
%             [s_Start,s_End]	= f_AskSamplesLims(st_Data.s_Sampling,...
%                               pst_Info.s_Time,pv_TimeLims);
%             str_LabSelected   = st_Data.v_Labels(:)';
% 
%             if isempty(s_End) 
%                 s_Start	= ...;
%             end
% 
%             if isempty(s_End)  
%                 s_End	= ...;
%             end
% 
%             st_Data.m_Data	= newformatreaddata(pst_Info.str_SigPath,...
%                               'channels',pv_Selected,...
%                               'start',s_Start,...
%                               'stop',s_End);
% 
%             if find(size(st_Data.m_Data) == numel(pv_Selected)) == 1
%                 st_Data.m_Data	= st_Data.m_Data';
%             end 

        otherwise

            [s_Start,s_End]	= f_AskSamplesLims(st_Data.s_Sampling,...
                            pst_Info.s_Time,pv_TimeLims);
            
            if isempty(s_Start) && isempty(s_End)
                st_Data.m_Data	= single(...
                                ft_read_data(pst_Info.str_SigPath,...
                                'chanindx',pv_Selected));

            else
                st_Data.m_Data  = single(...
                                ft_read_data(pst_Info.str_SigPath,...
                                'begsample',s_Start,...
                                'endsample',s_End,...
                                'chanindx',pv_Selected));
            end

            if find(size(st_Data.m_Data) == numel(pv_Selected)) == 1
                st_Data.m_Data	= st_Data.m_Data';
            end

            if find(size(st_Data.m_Data) == numel(pv_Selected)) == 1
                st_Data.m_Data	= st_Data.m_Data';
            end

    end

catch error
    errordlg(error.message,'System Error','modal')
    st_Data.m_Data      = [];
    st_Data.v_Labels    = [];
    st_Data.s_Sampling  = [];
    return
end

st_Data.v_Time      = ((0:length(st_Data.m_Data)-1)*1/st_Data.s_Sampling)';                
st_Data.s_TotalTime = st_Data.v_Time(end)-st_Data.v_Time(1);
        
end