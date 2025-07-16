%%  Process wave buoys (delayed mode)

%Process on-board (memory card) data from Sofar Spotter, Datawell, Triaxys
%Conducts quality control based on QARTOD manual
%Outputs monthly netCDF file following IMOS conventions for upload to AODN
%Ouput formats as from ARDC project. 
%after running this code, can runa 'netCDF checker code to make plots and
%verify results 

%2025-07
%   - v5 updates include new time cropping and updated watch circle qaqc 

%% set initial paths for wave buoy tools 
clear; clc; close all;
%location of wavebuoy_tools repo
mpath = 'C:\Users\00104893\LocalDocuments\Projects\Wave buoys\IMOS AODN\Github\wavebuoy_tools\wavebuoys'; 
addpath(genpath(mpath))

%% read CSV with metadata for buoys to process DM data
dpath = 'C:\Users\00104893\LocalDocuments\Projects\Wave buoys\Spotters\data\OceanBeach_deploy20240701_retrieve20241205_SPOT31395C'; 
dname = 'wa_delayed_mode_buoys_to_process.csv'; 

buoy_metadata = readtable(fullfile(dpath,dname),'VariableNamingRule','preserve'); 


%% Loop over buoys and process
for b = 1:size(buoy_metadata,1)
    %% create buoy_info variable from metadata sheet
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
    
    if strcmp(buoy_info.type,'sofar')==1        
        [displacements, ~, surface_temp, baro, gps, smart_mooring,smart_mooring_bm, smart_mooring_bm_agg] = process_sofar_SD_card(buoy_info.datapath); 
        
        %initial clip based on input start/stop times
        %set displacements TimeZone to UTC
        displacements.Time.TimeZone = 'UTC'; 
        %now convert to LOCAL for cropping
        displacements.Time.TimeZone = buoy_info.timezone; 
        %create cropping time range based on metadata spreadsheet
        tr = timerange(buoy_info.starttime+hours(buoy_info.time_crop_start), buoy_info.endtime+hours(buoy_info.time_crop_end),'closed');              
        displacements = displacements(tr,:); 
        %convert displacements Time back to UTC for cropping remaining
        %variables
        displacements.Time.TimeZone = 'UTC'; 

        %create time range based on cropped displacements
        tr = timerange(displacements.Time(1), displacements.Time(end),'closed'); 

        %crop remaining variables; 
        gps.Time.TimeZone = 'UTC'; 
        baro.Time.TimeZone = 'UTC'; 
        gps = gps(tr,:); 
        baro = baro(tr,:); 
        if contains(buoy_info.instrument,'Smart')
            if istimetable(smart_mooring_bm)
                smart_mooring_bm.Time.TimeZone = 'UTC'; 
                smart_mooring_bm = smart_mooring_bm(tr,:); 
                smart_mooring_bm_agg.Time.TimeZone = 'UTC'; 
                smart_mooring_bm_agg = smart_mooring_bm_agg(tr,:); 
            elseif istimetable(smart_mooring)
                smart_mooring.Time.TimeZone = 'UTC'; 
                smart_mooring = smart_mooring(tr,:); 
            end
        elseif istimetable(surface_temp)
            surface_temp.Time.TimeZone = 'UTC'; 
            surface_temp = surface_temp(tr,:); 
        end    
        
        %% set spectral analysis settings 
        disp_type = 'flt'; 
        fs = 2.5; 
        buoy_xyz = displacements; 
        clear displacements displacements_hdr             

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
        info.hs0_thresh = 3; 
        info.t0_thresh = 5; 
        
        %%  calculate integrated wave paremeters loop over and calculate parameters 
        for i = 1:length(dt)-1
            disp(['processing time block ' num2str(i) ' out of ' num2str(length(dt)-1)]); 
            tr = timerange(dt(i), dt(i+1));  
            
            %get displacements for given time window 
            dum = buoy_xyz(tr,:); 
            
            %set minimum number of samples to do analysis 
            if abs(size(dum,1) - min_samples)<100     
                %do the spectral analysis 
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
                    [zup] = ZeroUpX3(dum.z, 1/fs);
                    bulkparams.height_0{i}=zup.Heights;
                    bulkparams.periods_0{i}=zup.Periods;
                    bulkparams.crests{i}=zup.Crests;
                    bulkparams.troughs{i}=zup.Troughs;
                    bulkparams.hs_0{i}=zup.Hs;
                    bulkparams.tz_0{i}=zup.Tz;
                    clear zup                
                end 
                clear dum
            end     
        end    
        
        data = bulkparams; 
        clear bulkparams
        
        %remove NaT
        indNat = ~isnat(data.time); 
        fields = fieldnames(data);
        for i = 1:length(fields)
            if ~strcmp(fields{i},'frequency') & ~contains(fields{i},'limits') & ~contains(fields{i},'0') & ~strcmp(fields{i},'crests') & ~strcmp(fields{i},'troughs')
                data.(fields{i}) = data.(fields{i})(indNat,:); 
            elseif  contains(fields{i},'0') | strcmp(fields{i},'crests') | strcmp(fields{i},'troughs')
                data.(fields{i}) = data.(fields{i})(indNat); 
            end
        end        
        
        %%%% down-sample/interpolate - could make this a 'switch' in the
        % inputs to preserve temperature time or interpolate 
        
        % data.temp_time = data.time; 
        % if contains(buoy_info.instrument,'Smart')
        %     if istimetable(smart_mooring_bm)  
        %         data.surf_temp = interp1(smart_mooring_bm_agg.Time, smart_mooring_bm_agg.temp_mean_degC, data.time); 
        %     else
        %         data.surf_temp = interp1(smart_mooring.Time(smart_mooring.node==1), smart_mooring.temp_degC(smart_mooring.node==1), data.time); 
        %     end
        % else        
        %     if istimetable(surface_temp)
        %         %resample to 30min averages to match wave timestep
        %         dt30 = minutes(30);
        %         tdum = retime(surface_temp,'regular','mean','TimeStep',dt30);
        %         data.surf_temp = retime(tdum, data.time,'nearest'); 
        %         data.surf_temp = table2array(data.surf_temp); 
        %         clear tdum dt30; 
        %     else
        %         data.surf_temp = ones(size(data.time,1),1)*-9999; 
        %     end
        % end                
        
        if contains(buoy_info.instrument,'Smart')
            if istimetable(smart_mooring_bm)  
                data.temp_time = smart_mooring_bm_agg.Time(smart_mooring_bm_agg.node_position==1); 
                data.surf_temp = smart_mooring_bm_agg.temp_mean_degC(smart_mooring_bm_agg.node_position==1);
            else
                data.temp_time = smart_mooring.Time(smart_mooring.node==1); 
                data.surf_temp = smart_mooring.temp_degC(smart_mooring.node==1); 
            end
        else        
            if istimetable(surface_temp)
                data.temp_time = surface_temp.Time; 
                data.surf_temp = surface_temp.temperature;          
            else
                data.temp_time = data.time; 
                data.surf_temp = ones(size(data.time,1),1)*-9999; 
            end
        end
        
        %align gps to bulkparams time 
        if size(unique(gps.Time),1) == size(gps.Time,1)
            data.lon = interp1(gps.Time, gps.longitude, data.time); 
            data.lat = interp1(gps.Time, gps.latitude, data.time); 
        else
            [~,ind] = unique(gps.Time); 
            gps = gps(ind,:); 
            data.lon = interp1(gps.Time, gps.longitude, data.time); 
            data.lat = interp1(gps.Time, gps.latitude, data.time); 
            clear ind
        end
        
        %displacements        
        data.disp_time = buoy_xyz.Time; 
        data.x = buoy_xyz.x; 
        data.y = buoy_xyz.y; 
        data.z = buoy_xyz.z; 
        clear buoy_xyz;          
     
    elseif strcmp(buoy_info.type,'datawell')==1 %needs to be re-written to incorporate the displacements and then pushed through same displacements code as above 
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
                [temp] = Process_Datawell_delayed_mode(buoy_info, file20, file21, file25, file28, file80, file82, file23, filed);   
                %add dummy variables for meanspr and dm as don't exist in datawell?
                temp.dm = ones(size(temp.hs,1),1).*-9999; 
                temp.meanspr = ones(size(temp.hs,1),1).*-9999;             
            end
            
            %now append
            if cnt==1
                data=temp;                          
                data.pkspr = data.dpspr;
                data = rmfield(data,'dpspr');
                
                cnt=cnt+1;
                clear temp
            else
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
        %now down-sample temperature to same time as waves - this gets rid of current data as well      
        data_nc = rmfield(data,{'surf_temp','bott_temp','curr_mag','curr_dir','curr_mag_std','curr_dir_std','w','w_std','curr_dir_std'}); 
        if size(data.temp_time,1)~=size(data.time,1)
            for i = 1:size(data.time,1)
                ind = find(abs(data.time(i) - data.temp_time)==min(abs(data.time(i) - data.temp_time))); 
                if length(ind)>1
                    data_nc.surf_temp(i,1) = nanmean(data.surf_temp(ind));             
                    data_nc.bott_temp(i,1) = nanmean(data.bott_temp(ind)); 
                else
                    data_nc.surf_temp(i,1) = (data.surf_temp(ind));             
                    data_nc.bott_temp(i,1) = (data.bott_temp(ind)); 
                end
            end
        end
        data_nc.temp_time= data.time; 
        data = data_nc; 
        clear data_nc
    end
    
    %%   QAQC data - following QARTOD
    %settings for QAQC
    check.time = data.time; 
    check.temp_time = data.temp_time; 
    check.WVHGT = data.hs;
    check.WVPD = data.tp; %parameter for range test (could also be mean) 
    check.WVDIR = data.dp; %parameter for range test (could also be mean)
    check.SST = data.surf_temp; 
    check.STD = 3; % mean + std test
    check.time_window = 72; %hours for calculating mean + std    
    check.WHTOL = 0.025; % flat line
    check.WPTOL = 0.01; % flat line
    check.WDTOL = 0.5;  %flat line
    check.WSPTOL = 0.5; %flat line
    check.TTOL = 0.01; %flat line 
    check.rep_fail = 240;  %  flat line (hrs)
    check.rep_suspect = 144; % flat line (hrs) 
    check.MINWH = 0.10; %min height 
    check.MAXWH = 10; %max height
    check.MINWP = 1; %min period
    check.MAXWP = 25; %max period
    check.MINSV = 0.07; %min spread
    check.MAXSV = 80.0; %max spread
    check.MINT = 5; %min temp
    check.MAXT = 55; %max temp
    check.WHROC= 2; %height rate of change
    check.WPROC= 10; %period rate of change
    check.WDROC= 50; %direction rate of change
    check.WSPROC= 25; %spreading rate of change
    check.TROC = 2; %temp rate of change
    check.wave_fields = {'hs','tp','dp'}; %fields for assigning primary/secondary subflags 
    check.temp_fields = {'surf_temp'}; %fields for assigning primary/secondary subflags 
    check.qaqc_tests = {'15','16','19','20','spike'}; % qaqc tests to use in assigning flags 
    
    [data] = qaqc_bulkparams(data,check);  


    % Make table of individual test flags for TEMP. export to CSV. for
    % comparison to Python workflow
     TEMP=data.surf_temp;
     TIME_TEMP=data.temp_time;
     TEMP_quality_control=data.qc_flag_temp;
     TEMP_QC_TEMP_gross_range_test=data.surf_temp_19;
     TEMP_QC_TEMP_rate_of_change_test= data.surf_temp_20;
     TEMP_QC_TEMP_flat_line_test=data.surf_temp_16;
     TEMP_QC_TEMP_mean_std_test= data.surf_temp_15;
     TEMP_QC_TEMP_spike_test=data.surf_temp_spike;

     temp_subflag_tests=table(TEMP,TIME_TEMP,TEMP_quality_control,TEMP_QC_TEMP_gross_range_test,TEMP_QC_TEMP_rate_of_change_test,TEMP_QC_TEMP_flat_line_test,TEMP_QC_TEMP_mean_std_test,TEMP_QC_TEMP_spike_test);
     
     cd(buoy_info.archive_path)
     writetable(temp_subflag_tests,'temp_qc_subflags.csv')

     clearvars TEMP TIME_TEMP TEMP_quality_control TEMP_QC_TEMP_gross_range_test TEMP_QC_TEMP_rate_of_change_test TEMP_QC_TEMP_flat_line_test TEMP_QC_TEMP_mean_std_test TEMP_QC_TEMP_spike_test
   
     % make table for individual subflag tests BP's. export to csv for
     % comparison to Python workflow
    TIME=data.time;
    WSSH=data.hs;
    WPFM=data.tm;
    WPPE=data.tp;
    SSWMD=data.dm;
    WPDI=data.dp;
    WMDS=data.dmspr;
    WPDS=data.dpspr;
    LONGITUDE=data.lat;
    LATITUDE=data.lon;
    WAVE_quality_control=data.qc_flag_wave;
    WAVE_QC_WSSH_gross_range_test=data.qf_19(:,1);
    WAVE_QC_WSSH_rate_of_change_test=data.hs_20;
    WAVE_QC_WSSH_mean_std_test=data.hs_15;
    WAVE_QC_WSSH_spike_test=data.hs_spike;
    WAVE_QC_WPPE_gross_range_test=data.qf_19(:,1);
    WAVE_QC_WPPE_rate_of_change_test=data.tp_20;
    WAVE_QC_WPPE_mean_std_test=data.tp_15;
    WAVE_QC_WPPE_spike_test=data.tp_spike;
    WAVE_QC_WPDI_gross_range_test=data.qf_19(:,1);
    WAVE_QC_WPDI_rate_of_change_test=data.dp_20;
    WAVE_QC_WPDI_mean_std_test=data.dp_15;
    WAVE_QC_WPDI_spike_test=data.dp_spike;
    
    %remove all indivdiual parameter QAQC tests 
    fields = fieldnames(data); 
    for i = 1:length(fields); 
        if length(fields{i})>1
            if strcmp(fields{i}(end-1:end),'15') | strcmp(fields{i}(end-1:end),'16') | strcmp(fields{i}(end-1:end),'19') | strcmp(fields{i}(end-1:end),'20') | strcmp(fields{i}(end-1:end),'ke')
                data = rmfield(data, fields{i}); 
            end             
        end
    end    
    
    %quickly denan and replace with fill values
    fields = fieldnames(data); 
    for i = 1:length(fields)
        if strcmp(fields{i},'serial') | contains(fields{i},'time') | contains(fields{i},'0') | strcmp(fields{i},'crests') | strcmp(fields{i},'troughs')
            continue        
        elseif strcmp(fields{i},'qc_flag_wave') | strcmp(fields{i},'qc_subflag_wave') | strcmp(fields{i},'qc_flag_temp') | strcmp(fields{i},'qc_subflag_wave')
            data.(fields{i})(isnan(data.(fields{i}))) = -127; 
        else
            data.(fields{i})(isnan(data.(fields{i}))) = -9999;
        end
    end     
    
    %frequency can't have FillValues, so cut last frequency if it's got -9999
    data.frequency = data.frequency(1,:);
    if data.frequency(end)==-9999
        %find frequency that's not -9999
        ind_f = find(data.frequency>-9999); 
        fields = {'frequency','energy','a1','a2','b1','b2','Sxx','Syy'}; 
        for i = 1:length(fields)
            data.(fields{i}) = data.(fields{i})(:,ind_f); 
        end
    end

    %run final QC using watch circle, note this function overwrties the
    %qc_flag_wave where watch circle test is suspect (3) and fail
    %(4). It also overwrites qc_subflag_wave with (37) when outside watch circle.
    % watch_circle_flag tells whether any (1) or none (0) data were
    % outside the watch circle. 

    [data,watch_circle_flag] = qaqc_watch_circle(buoy_info, data); 

    %quickly calculate total number of suspect and fail data
    qc_fail = (size(data.qc_flag_wave(data.qc_flag_wave>1),1)/size(data.time,1))*100; 

     
    %Write Bulk parameters subflags csv
    WATCH_quality_control_primary = data.qc_flag_watch(:,1);
    WATCH_quality_control_secondary = data.qc_flag_watch(:,2);

    bp_subflag_tests=table(TIME,WSSH,WPFM,WPPE,SSWMD,WPDI,WMDS,WPDS,LONGITUDE,LATITUDE,WAVE_quality_control,WAVE_QC_WSSH_gross_range_test,WAVE_QC_WSSH_rate_of_change_test,WAVE_QC_WSSH_mean_std_test,WAVE_QC_WSSH_spike_test,WAVE_QC_WPPE_gross_range_test,WAVE_QC_WPPE_rate_of_change_test,WAVE_QC_WPPE_mean_std_test,WAVE_QC_WPPE_spike_test,WAVE_QC_WPDI_gross_range_test,WAVE_QC_WPDI_rate_of_change_test,WAVE_QC_WPDI_mean_std_test,WAVE_QC_WPDI_spike_test,WATCH_quality_control_primary,WATCH_quality_control_secondary);

    cd(buoy_info.archive_path);

    writetable(bp_subflag_tests,'bulk_qc_subflags.csv')

    clearvars TIME WSSH WPFM WPPE SSWMD WPDI WMDS WPDS LONGITUDE LATITUDE WAVE_quality_control WAVE_QC_WSSH_gross_range_test WAVE_QC_WSSH_rate_of_change_test WAVE_QC_WSSH_mean_std_test WAVE_QC_WSSH_spike_test WAVE_QC_WPPE_gross_range_test WAVE_QC_WPPE_rate_of_change_test WAVE_QC_WPPE_mean_std_test WAVE_QC_WPPE_spike_test WAVE_QC_WPDI_gross_range_test WAVE_QC_WPDI_rate_of_change_test WAVE_QC_WPDI_mean_std_test WAVE_QC_WPDI_spike_test WATCH_quality_control_primary WATCH_quality_control_secondary


%% Save mat file for internal Use
    
    %set start date based on final dataset start/stop (UTC)
    buoy_info.startdate = data.time(1); buoy_info.enddate = data.time(end); 
    
    fname = make_imos_ardc_filename(buoy_info,'ALL'); 
    fname = strrep(fname,'nc','mat'); 
    
    save(fname,'baro','buoy_info','buoy_metadata','check','data','gps','surface_temp','smart_mooring_bm','smart_mooring_bm_agg','watch_circle_flag','qc_fail','-v7.3'); 
    
    
    %write outputs if passes the final watch circle QC; otherwise, write log file with issues to check
    if qc_fail>buoy_info.qc_percent_fail | watch_circle_flag>0
        % write log file for this deployment processing if bad data and needs closer look
        fname = ['processingLog_' buoy_info.name '_' datestr(datetime('now'),'yyyymmdd_HHMMSS') '.txt']; 
        logfile = fullfile(buoy_info.archive_path,fname); 
        flog = fopen(logfile,'a'); 
        fprintf(flog, [buoy_info.name ' failed the watch circle QAQC tests OR too much flagged data and needs a closer look.']); 
        fclose(flog); 
    else
       %% Organise for netCDF following IMOS-ARDC conventions      
        
        % %Clip data to start/stop time of interest 
        % ind_wave = find(data.time>=(buoy_info.startdate)&data.time<=(buoy_info.enddate)); 
        % ind_tempcurr = find(data.temp_time>=buoy_info.startdate&data.temp_time<=buoy_info.enddate); 
        % ind_disp = find(data.disp_time(:,1)>=(buoy_info.startdate)&data.disp_time(:,1)<=(buoy_info.enddate)); 
        % 
        % fields = fieldnames(data); 
        % for i = 1:length(fields); 
        %     if strcmp(fields{i},'disp_time') | strcmp(fields{i},'x') | strcmp(fields{i},'y') | strcmp(fields{i},'z')
        %         data.(fields{i}) = data.(fields{i})(ind_disp,:); 
        %     elseif strcmp(fields{i},'temp_time') | strcmp(fields{i},'surf_temp') | strcmp(fields{i},'bott_temp') | strcmp(fields{i},'qc_flag_temp') | strcmp(fields{i},'qc_subflag_temp') 
        %         data.(fields{i}) = data.(fields{i})(ind_tempcurr,:); 
        %     elseif strcmp(fields{i},'curr_mag') | strcmp(fields{i},'curr_dir') | strcmp(fields{i},'curr_mag_std') | strcmp(fields{i},'curr_dir_std') | strcmp(fields{i},'w') | strcmp(fields{i},'w_std')  
        %         data.(fields{i}) = data.(fields{i})(ind_tempcurr,:); 
        %     elseif strcmp(fields{i},'frequency')
        %         data.(fields{i}) = data.(fields{i})(1,:);
        %     elseif contains(fields{i},'limits') | contains(fields{i},'0') | strcmp(fields{i},'crests') | strcmp(fields{i},'troughs')
        %         continue
        %     else
        %         data.(fields{i}) = data.(fields{i})(ind_wave,:); 
        %     end
        % end    
        
        
        %make time a datenum for netCDF codes 
        data.time = datenum(data.time); 
        data.temp_time = datenum(data.temp_time); 
        data.disp_time = datenum(data.disp_time); 
        
        %%  Integral Wave Parameters 
        
        globfile = [mpath '\imos_nc\metadata\glob_att_integralParams_ardc.txt']; 
        
        if strcmp(buoy_info.type,'datawell')
            varsfile = [mpath '\imos_nc\metadata\bulkwave_parameters_DM_mapping_DWR4.csv']; 
        else
            varsfile = [mpath '\imos_nc\metadata\bulkwave_parameters_DM_mapping.csv']; 
        end
        globfile_Int = globfile;
        varsfile_Int = varsfile;
        bulkparams_to_IMOS_ARDC_nc(data, buoy_info, globfile, varsfile); 
        
        %% displacements
        
        globfile = [mpath '\imos_nc\metadata\glob_att_rawDispl_ardc.txt']; 
        if strcmp(buoy_info.type,'datawell')
            varsfile = [mpath '\imos_nc\metadata\rawDispl_parameters_DM_mapping.csv']; 
        else
            varsfile = [mpath '\imos_nc\metadata\rawDispl_parameters_DM_mapping.csv']; 
        end
        
        %divide displacements into 2week blocks and may x, y, z and time single
        %column variables 
        disp_buoy_info = buoy_info; %create dum info variable as time needs to change in code below 
        %transpose so can stack in time 
        data.disp_time = data.disp_time'; data.x = data.x'; data.y = data.y'; data.z = data.z'; 
        data.disp_time = data.disp_time(:); 
        data.x = data.x(:); 
        data.y = data.y(:); 
        data.z = data.z(:); 
        
        %make whole days to match python (times are in datenum, so use datenum)
        d1 = floor(data.disp_time(1)); 
        d2 = ceil(data.disp_time(end)); 
        
        ttdum = d1:14:d2; 
        for i = 1:length(ttdum)
            if i == length(ttdum)
                ind = find(data.disp_time>=ttdum(i) & data.disp_time<d2);  
            else
                ind = find(data.disp_time>=ttdum(i) & data.disp_time<ttdum(i+1));
            end
            displacements.time = data.disp_time(ind); 
            displacements.x = data.x(ind); 
            displacements.y = data.y(ind); 
            displacements.z = data.z(ind); 
            %find lat/lon from bulkparameters that's inside displacements time
            ind = find(data.time>=displacements.time(1) & data.time<=displacements.time(end)); 
            displacements.lat = data.lat(ind); 
            displacements.lon = data.lon(ind); 
            displacements.time_location = data.time(ind);
            disp_buoy_info.startdate = displacements.time(1); 
            disp_buoy_info.enddate = displacements.time(end);
            
            displacements_to_IMOS_ARDC_nc(displacements, disp_buoy_info, globfile, varsfile); 
        end
        
        globfile_Disp = globfile;
        varsfile_Disp = varsfile;              
        %% spectral data
        
        globfile = [mpath '\imos_nc\metadata\glob_att_spectral_ardc.txt']; 
        if strcmp(buoy_info.type,'datawell')
            varsfile = [mpath '\imos_nc\metadata\spectral_parameters_DM_mapping_DWR4.csv']; 
        else
            varsfile = [mpath '\imos_nc\metadata\spectral_parameters_DM_mapping.csv']; 
        end
        
        spec_to_IMOS_ARDC_nc(data, buoy_info, globfile, varsfile);
        
        globfile_Spec = globfile;
        varsfile_Spec = varsfile;
        %%  overwrite previous .mat file with final info 
        %convert back to datetime for easier plotting in future 
        data.time = datetime(data.time,'convertfrom','datenum'); data.time.TimeZone = 'UTC'; 
        data.disp_time = datetime(data.disp_time,'convertfrom','datenum'); data.disp_time.TimeZone='UTC'; 
        data.temp_time = datetime(data.temp_time,'convertfrom','datenum'); data.temp_time.TimeZone='UTC'; 
        fname = make_imos_ardc_filename(buoy_info,'ALL'); 
        fname = strrep(fname,'nc','mat'); 
        save(fname,'baro','buoy_info','buoy_metadata','check','data','gps','surface_temp','smart_mooring_bm','smart_mooring_bm_agg',...
            'globfile_Spec','globfile_Disp','globfile_Int','varsfile_Spec','varsfile_Disp','varsfile_Int','buoy_info','check','disp_buoy_info','mpath','-v7.3'); 
    end
end



        

        
        
       




