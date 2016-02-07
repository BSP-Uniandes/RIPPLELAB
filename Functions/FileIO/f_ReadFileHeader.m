%   f_ReadInfo.m [As a part of HFO Detection Project]
%   Written by:
%   Miguel G. Navarrete Mejia
%   Electrical Engineering MS 
%   UNIVERSIDAD DE LOS ANDES
%   Colombia, 2012
%   mnavarretem@gmail.com

function st_Info = f_ReadFileHeader(pst_SigPath)
% Reads header information of signal files
% INPUT:
% pst_SigPath.name: Name of Signal file
% pst_SigPath.path: Path of Signal File
% OUTPUT
% st_Info.SigPath     = Full Path of signal file
% st_Info.SigName     = Signal Name;
% st_Info.SigExt      = File extention for signal type;
% st_Info.str_FileType= File Type
% st_Info.Start       = Absolute start time
% st_Info.Time        = Time length of record in mins;
% st_Info.SampleRate  = Sample rate for signal;
% st_Info.NumbRec     = Number of records;
% st_Info.Labels      = Label of records;
% st_Info.Scale       = Amplitude scale;
% st_Info.error       = Reading Error;
% st_Info.AmpScaleRec = Amplitude scale for record;
% st_Info.MinMaxRec   = min value and max value per record;
% st_Info.Custom      = Structure with ustom information according with
%                       type

s_ExtIndex      = regexp(pst_SigPath.name,'\.');
s_ExtIndex      = s_ExtIndex(end);
str_FileExt     = pst_SigPath.name((s_ExtIndex+1):length(pst_SigPath.name));
str_FileName    = pst_SigPath.name(1:(s_ExtIndex-1));
str_FullPath	= fullfile(pst_SigPath.path,pst_SigPath.name);

if isnumeric(str2double(str_FileExt)) && ~isnan(str2double(str_FileExt))
    str_FileType    = 'numeric';
else
    str_FileType    = str_FileExt;
end

st_Info.str_FileType    = lower(str_FileType);
        
switch st_Info.str_FileType
    case 'mat'
        st_Hdr	= load(str_FullPath,'Header');
        
        if isfield(st_Hdr,'Header')
            st_Hdr      = st_Hdr.Header;
            v_Fields	= fieldnames(st_Hdr);
            v_Required  = [{'Sampling'};{'Labels'};{'IniTime'};{'Samples'}];
                       
            if sum(ismember(v_Required,v_Fields)) ~= numel(v_Required)   
                f_ConvertMatFile(str_FullPath);    
                st_Info.s_error	= 0;
                st_Info.s_Check = 0;
                return
            end
            
        else
            f_ConvertMatFile(str_FullPath);
            st_Info.s_error = 0;
            st_Info.s_Check = 0;
            return
        end
                        
        st_Info.str_SigPath     = str_FullPath;
        st_Info.str_FileName    = pst_SigPath.name;
        st_Info.str_SigExt      = str_FileExt;
        st_Info.v_SampleRate    = repmat(st_Hdr.Sampling,...
                                numel(st_Hdr.Labels),1);
        st_Info.s_Start         = st_Hdr.IniTime;
        st_Info.s_Time          = (st_Hdr.Samples/st_Hdr.Sampling)/60;
        st_Info.s_Samples       = st_Hdr.Samples;
        st_Info.v_Labels        = st_Hdr.Labels;
        st_Info.s_NumbRec       = numel(st_Hdr.Labels);
        st_Info.s_Scale         = 1;
        st_Info.s_error         = 0;
        st_Info.st_Custom       = [];
        
        st_Info.s_Check         = 1;
        
    case {'edf' 'rec'}
        st_Hdr         = sdfopen(str_FullPath, 'r');
                
        % Signal Labels:                st_Hdr.Label
        % Signal Sample Rate:           st_Hdr.SampleRate
        % Number of data records:       st_Hdr.NRec
        % Time insecs for data record:  st_Hdr.Dur
        % Absolute start time:          st_Hdr.T0
        
        st_Info.s_Check         = 1;
        st_Info.str_SigPath     = str_FullPath;
        st_Info.str_FileName     = pst_SigPath.name;
        st_Info.str_SigExt      = str_FileExt;
        st_Info.s_Start         = st_Hdr.T0;
        
        if numel(st_Info.s_Start) > 3
            st_Info.s_Start     = st_Info.s_Start(end-2:end);
        end
        
        st_Info.s_Time          = (st_Hdr.NRec * st_Hdr.Dur)/60;
        st_Info.s_Samples       = (st_Hdr.NRec * st_Hdr.Dur) * ...
                                    st_Hdr.SampleRate;
        st_Info.v_SampleRate    = st_Hdr.SampleRate;
        st_Info.s_NumbRec       = size(st_Hdr.Label,1);
        st_Info.v_Labels        = cellstr(st_Hdr.Label);
        st_Info.s_Scale         = 1;
        st_Info.s_error         = 0;
        st_Info.st_Custom       = st_Hdr;
            
        st_Info.v_AmpScaleRec   = st_Hdr.PhysDim;
        st_Info.v_MinMaxRec     = [st_Hdr.PhysMin st_Hdr.PhysMax];
        
    case {'data' 'eeg' 'numeric'}
        
        if strcmpi(str_FileType,'numeric')
            str_HeaderFile  = [pst_SigPath.path str_FileName '.' str_FileExt];
        else
            str_HeaderFile  = [pst_SigPath.path str_FileName];
        end
                
        if strcmpi(str_FileType,'data')
            str_FInfoPath = [str_HeaderFile '.head'];
            s_Type = 1;
        elseif strcmpi(str_FileType,'eeg') || strcmpi(str_FileType,'numeric')
            str_FInfoPath   = [str_HeaderFile '.bni'];
            s_Type = 0;
        end
        
        
        [str_SigLabels,s_SigCh,s_Scale,s_SampleRate,v_IniTime] = ...
        f_GetiSignalHeader(str_FInfoPath,s_Type);
    
        st_FeegInfo                 = dir(str_FullPath);
        [s_TotalTime s_Samples]     = f_AskSignalTime(s_SampleRate,...
                                    st_FeegInfo.bytes,s_SigCh);
    
        if ~isreal(s_TotalTime) && ~(s_TotalTime > 0) && ~isfinite(s_TotalTime)
            st_Info.s_Checkv    = 0;
            return
        end

        st_Info.s_Check         = 1;
        st_Info.str_SigPath     = str_FullPath;
        st_Info.str_FileName    = pst_SigPath.name;
        st_Info.str_SigExt      = str_FileExt;
        st_Info.s_Start         = v_IniTime;
        st_Info.s_Time          = s_TotalTime;
        st_Info.s_Samples       = s_Samples;
        st_Info.v_SampleRate    = s_SampleRate*ones(1,s_SigCh);
        st_Info.s_NumbRec       = s_SigCh;
        st_Info.v_Labels        = f_GetSignalNamesArray(str_SigLabels,0)';
        st_Info.s_Scale         = s_Scale;
        st_Info.s_error         = 0;
        st_Info.st_Custom       = [];
        
    case 'ncs'
        
        st_Hdr      = f_GetExtNCSHeader(str_FullPath);
        
        st_Info.s_Check         = 1;
        st_Info.str_SigPath     = str_FullPath;
        st_Info.str_FileName     = pst_SigPath.name;
        st_Info.str_SigExt      = str_FileExt;
        st_Info.v_SampleRate    = st_Hdr.SamplingFrequency;
        st_Info.s_Start         = st_Hdr.IniTime;
        st_Info.s_Time          = st_Hdr.NRecords*512/st_Info.v_SampleRate;
        st_Info.s_Samples       = st_Hdr.NRecords*512;
        st_Info.s_NumbRec       = 1;
        st_Info.s_Scale         = 1;
        st_Info.s_error         = 0;
        st_Info.st_Custom       = [];
        
        if isfield(st_Hdr,'AcqEntName')
            st_Info.v_Labels        = st_Hdr.AcqEntName;
        elseif isfield(st_Hdr,'NLX_Base_Class_Name')
            st_Info.v_Labels        = st_Hdr.NLX_Base_Class_Name;
        end
    otherwise
        
        try
            st_Hdr      = ft_read_header(str_FullPath);
            
            st_Info.str_SigPath     = str_FullPath;
            st_Info.str_FileName    = pst_SigPath.name;
            st_Info.str_SigExt      = str_FileExt;
            st_Info.s_Start         = [0 0 0];
            st_Info.s_Time          = st_Hdr.nSamples/(st_Hdr.Fs*60);
            st_Info.s_Samples       = st_Hdr.nSamples;
            st_Info.v_SampleRate    = st_Hdr.Fs*ones(1,numel(st_Hdr.label));
            st_Info.s_NumbRec       = numel(st_Hdr.label);
            st_Info.v_Labels        = st_Hdr.label;
            st_Info.s_Scale         = 1;
            st_Info.s_error         = 0;
            st_Info.s_Check         = 1;
            st_Info.st_Custom       = st_Hdr.orig;
        catch            
            st_Info.s_error         = 1;
            st_Info.s_Check         = 1;
        end
end
