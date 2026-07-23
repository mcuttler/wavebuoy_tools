%%  Process wave buoys (delayed mode)

%Process on-board (memory card) data from Sofar Spotter, Datawell, Triaxys
%Conducts quality control based on QARTOD manual
%Outputs monthly netCDF file following IMOS conventions for upload to AODN
%Ouput formats as from ARDC project. 
%after running this code, can runa 'netCDF checker code to make plots and
%verify results 

%2025-10
%   - v6 updates include new QAQC config reading and other small changes to
%   match python workflow 

%% set initial paths for wave buoy tools 
clear; clc; close all;
%location of wavebuoy_tools repo
mpath = 'C:\Users\00084142\CUTTLER_GitHub\wavebuoy_tools'; 
addpath(genpath(mpath))

%% read CSV with metadata for buoys to process DM data
dpath = 'X:\CUTTLER_wawaves\Data\wawaves'; 
dname = 'wa_delayed_mode_buoys_to_process-datawell.csv'; 

buoy_metadata = readtable(fullfile(dpath,dname),'VariableNamingRule','preserve'); 
%only keep buoys that are set to be processed 
buoy_metadata = buoy_metadata(buoy_metadata.process==1,:); 

%% Loop over buoys and process
%for b = 1%:size(buoy_metadata,1)

    %% create buoy_info variable from metadata sheet
    b = 1; 
    vars = buoy_metadata.Properties.VariableNames; 
    for j = 1:length(vars)
        if iscell(buoy_metadata.(vars{j})(b))
            buoy_info.(vars{j}) = buoy_metadata.(vars{j}){b}; 
        else
            buoy_info.(vars{j}) = buoy_metadata.(vars{j})(b); 
        end
    end
    
    %parse start/stop times from datapath 
    cname = strsplit(buoy_info.datapath,'\'); 
    for j = 1:length(cname)
        if contains(cname{j},'deploy')
            cdum = cname{j}; 
        end
    end
    cname = cdum; clear cdum; 
    cname = strsplit(cname,'_');      
    for j = 1:length(cname)
        if contains(cname{j},'deploy')
            buoy_info.starttime = datetime(strrep(cname{j},'deploy',''),'InputFormat','yyyyMMdd','TimeZone',buoy_info.timezone); 
            buoy_info.starttimeUTC = buoy_info.starttime; 
            buoy_info.starttimeUTC.TimeZone = 'UTC'; 
        elseif contains(cname{j},'retrieve')
            buoy_info.endtime = datetime(strrep(cname{j},'retrieve',''),'InputFormat','yyyyMMdd','TimeZone',buoy_info.timezone);   
            buoy_info.endtimeUTC = buoy_info.endtime; 
            buoy_info.endtimeUTC.TimeZone = 'UTC'; 
        end
    end    

    %% process data based on buoy type (sofar, datawell, etc.)
    
   
     

        %create blank array for output
        dw_vars = {'serial','E','theta','s','m2','n2','time','a1','a2','b1','b2',...
            'frequency','hs','tm','tp','dp','dpspr', 'curr_mag','curr_dir',...
            'curr_mag_std','curr_dir_std','temp_time','surf_temp','bott_temp','w','w_std',...
            'gps_time','gps_pos','disp_tstart','disp_time','z','y','x'}; 

        for i = 1:length(dw_vars)
            data.(dw_vars{i}) = []; 
        end
        
        cnt=1;
        %loop through directory of files output from CF card (need datawell
        %lib to convert to CSV)
        %get all the field to process 20 file is 1D spectra
        files=dir((fullfile(buoy_info.datapath,'*-20.csv'))); 

        for kk=1:length(files)
            %skip 1970 file that always seems to appear
            if strcmp(files(kk).name(1:4),'1970')
                continue
            else
                disp(['File ' num2str(kk) ' out of ' num2str(length(files))]); 
                
                file20 = fullfile(buoy_info.datapath, [files(kk).name(1:10)  '-20.csv']);
                file21 =fullfile(buoy_info.datapath, [files(kk).name(1:10)  '-21.csv']); 
                file25 =fullfile(buoy_info.datapath, [files(kk).name(1:10)  '-25.csv']); 
                file28 = fullfile(buoy_info.datapath, [files(kk).name(1:10)  '-28.csv']);
                file80 =fullfile(buoy_info.datapath, [files(kk).name(1:10)  '-80.csv']); 
                file82 =fullfile(buoy_info.datapath, [files(kk).name(1:10)  '-82.csv']);
                file23 = fullfile(buoy_info.datapath, [files(kk).name(1:10) '-23.csv']);
                filed = fullfile(buoy_info.datapath, [files(kk).name(1:10) '-displacement.csv']);                      
                
                %load and organize data for each file containing 4 days of data
                try
                    [temp] = Process_Datawell_delayed_mode(buoy_info, file20, file21, file25, file28, file80, file82, file23, filed);   
                    %add dummy variables for meanspr and dm as don't exist in datawell?
                    temp.dm = ones(size(temp.hs,1),1).*-9999; 
                    temp.meanspr = ones(size(temp.hs,1),1).*-9999;      
                    process_flag = 1;
                catch
                    disp(['processing datawell for this file could not be completed']);
                    process_flag = 0; 
                end       

            end            
            %now append
            if cnt==1 & process_flag==1
                data=temp;                          
                data.pkspr = data.dpspr;
                data = rmfield(data,'dpspr');
                
                cnt=cnt+1;
                clear temp
            elseif cnt>1 & process_flag ==1 
                fields = fieldnames(data); 
                for jj = 1:length(fields)
                    if strcmp(fields{jj}, 'spec2D')
                        data.spec2D = cat(3,data.spec2D,temp.spec2D);
                    elseif strcmp(fields{jj},'pkspr')
                        data.pkspr = [data.pkspr; temp.dpspr]; 
                    else                     
                        data.(fields{jj}) = [data.(fields{jj}); temp.(fields{jj})];
                    end
                end                  
                clear temp
                cnt=cnt+1;
            end         
        end

                %% set spectral analysis settings datawell 
        disp_type = 'flt'; 
        fs = 2.56; 
        dum_dt = data.disp_time(:); 
        dum.x = data.x(:); 
        dum.y = data.y(:); 
        dum.z = data.z(:); 
        buoy_xyz = array2timetable([dum.x dum.y dum.z],'RowTimes',dum_dt, 'VariableNames',{'x','y','z'}); 
        buoy_xyz.Time.TimeZone = 'UTC'; 

        clear dum_dt dum
     

        %set start/stop time for buliding spectral analysis time blocks 
        tstart = buoy_info.starttimeUTC +hours(buoy_info.time_crop_start);
        tend = buoy_info.endtimeUTC +hours(buoy_info.time_crop_end); 
        
        %set spectral processing time window
        spec_window = 30; %minutes 
        min_samples = spec_window*60*fs; %expected number of samples 
        dt = [tstart:minutes(spec_window):tend]; 
        
        %set up spectral info
        %nfft=512; %#### this needs to be a function of the sample frequency see
        %additional code below that will set this up such that the nfft is based
        %on time rather than the number of samples which is based on the sample frequency 
        segments=8; % number of segments to split the record into
        nfft=2^(nextpow2(min_samples/segments));
        nover=0.5; 
        
        %merge=3; %this also relates to the nfft and defines final resolution, the
        %larger nfft is the larger this should be
        if nfft==512
            merge=3;
        elseif nfft==1024
            merge=5;
        elseif nfft==2048
            merge=7;
        end
        type = 'xyz'; 
        info.hab = [];   
        info.fmaxSS = 1/8; 
        info.fmaxSea = 1/2; 
        
        %settings for qc as part of the spectral_from_displacements processing 
        info.bad_data_thresh=2/3; 
        info.hs0_thresh = buoy_info.displacement_hs0_thresh; 
        info.t0_thresh = buoy_info.displacement_t0_thresh; 
        info.h = buoy_info.DeployDepth; 
        info.QC = buoy_info.displacement_qc; 
        info.max_steep = 1/4; 

        
        %%  calculate integrated wave paremeters loop over and calculate parameters 
        for i = 1:length(dt)-1
            disp(['processing time block ' num2str(i) ' out of ' num2str(length(dt)-1)]); 
            tr = timerange(dt(i), dt(i+1));  
            
            %get displacements for given time window 
            dum = buoy_xyz(tr,:); 
            
            %set minimum number of samples to do analysis 
            if abs(size(dum,1) - min_samples)<100     
                %do the spectral analysis     
                try
                    out=spectra_from_displacements(dum.z,dum.y,dum.x,nfft,nover,fs,merge,'xyz',info);     
                    
                    if isstruct(out)    
                        %partition the results from the spectral analysis 
                        out=spectra_partitioning(out,info);
                        bulkparams.time(i,1)=dt(i); 
                        bulkparams.hs(i,1)=out.Hm0;
                        bulkparams.hsSwell(i,1) = out.Hm0_Swell; 
                        bulkparams.hsSea(i,1) = out.Hm0_Sea;
                        bulkparams.hrms(i,1) = out.Hrms; 
                        bulkparams.tp(i,1)=out.Tp;
                        bulkparams.dp(i,1)=out.Dp;
                        bulkparams.tm(i,1)=out.Tm1; 
                        bulkparams.tm2(i,1)=out.Tm2;
                        bulkparams.tmSwell(i,1) = out.Tm1_Swell; 
                        bulkparams.tm2Swell(i,1) = out.Tm2_Swell;
                        bulkparams.tmSea(i,1) = out.Tm1_Sea;
                        bulkparams.tm2Sea(i,1) = out.Tm2_Sea;            
                        bulkparams.dpspr(i,1) = out.spread_Dp; 
                        bulkparams.dmspr(i,1)=out.spread;
                        bulkparams.dmsprSwell(i,1) = out.spreadSwell; 
                        bulkparams.dmsprSea(i,1) = out.spreadSea; 
                        bulkparams.dm(i,1)=out.mdir1;
                        bulkparams.dm2(i,1)=out.mdir2;
                        bulkparams.dmSwell(i,1)=out.mdir1_Swell;
                        bulkparams.dm2Swell(i,1)=out.mdir2_Swell;
                        bulkparams.dmSea(i,1)=out.mdir1_Sea;
                        bulkparams.dm2Sea(i,1)=out.mdir2_Sea;       
                        
                        bulkparams.dm_spec(i,:) = out.mdir1_spec; 
                        bulkparams.frequency = out.f; 
                        bulkparams.energy(i,:)=out.spec1D; 
                        bulkparams.a1(i,:)=out.a1;
                        bulkparams.a2(i,:)=out.a2;
                        bulkparams.b1(i,:)=out.b1;
                        bulkparams.b2(i,:)=out.b2;
                        bulkparams.segments(i,1) = out.segments;                     
                        bulkparams.segments_used(i,1) = out.segments_used;       
                        bulkparams.check_fact(i,:) = out.Check; 
                        
                        %save bands for sea/swell
                        if ~isfield(bulkparams,'sea_T_limits')
                            bulkparams.sea_T_limits=out.sea_max_min_T;
                            bulkparams.swell_T_limits=out.swell_max_min_T;
                        end
                        
                        %calculate zero crossing heights
                        [zup] = ZeroUpX3(dum.z, 1/fs, info.h);
                        bulkparams.height_0{i}=zup.Heights;
                        bulkparams.periods_0{i}=zup.Periods;
                        bulkparams.crests{i}=zup.Crests;
                        bulkparams.troughs{i}=zup.Troughs;
                        bulkparams.hs_0{i}=zup.Hs;
                        bulkparams.tz_0{i}=zup.Tz;
                        clear zup                
                    end 
                    clear dum
                catch
                    disp(['could not complete spectral analysis']); 
                end
            end     
        end    

        data.spectral_analysis = bulkparams; 
    
 