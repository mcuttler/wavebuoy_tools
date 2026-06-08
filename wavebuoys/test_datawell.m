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
mpath = 'D:\CUTTLER_GitHub\wavebuoy_tools'; 
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
    
    %%   QAQC data 


    %read QAQC config file
    qc_config = readtable(buoy_info.qc_config_file,'VariableNamingRule','preserve'); 
    %keep settings based on qc_config to use
    qc_config = qc_config(qc_config.config_id==buoy_info.qc_config,:);     
    %get the enabled vars
    data.qc_config = qc_config(qc_config.enable_checks==1,:);     
    clear qc_config

    %info for exporting qaqc results
    saveTable=1;
    vnames = data.qc_config.parameter_matlab; 
    tableName =['qc_config=' num2str(buoy_info.qc_config)]; 
    for j = 1:length(vnames)
        tableName = [tableName '_' vnames{j}]; 
    end   
    
    [data, buoy_info] = qaqc_bulkparams(data,data.qc_config, buoy_info, saveTable, tableName);           

    %remove all indivdiual parameter QAQC tests 
    fields = fieldnames(data); 
    for i = 1:length(fields)
        if length(fields{i})>1
            if contains(fields{i},'test')
                data = rmfield(data, fields{i}); 
            end             
        end
    end    
        
    %quickly denan and replace with fill values
    fields = fieldnames(data); 
    for i = 1:length(fields)
        if strcmp(fields{i},'serial') | contains(fields{i},'time') | contains(fields{i},'0') | strcmp(fields{i},'crests') | strcmp(fields{i},'troughs') | strcmp(fields{i},'qc_config')
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

    %quickly calculate total number of suspect and fail data 
    data.qc_fail = (size(data.qc_flag_wave(data.qc_flag_wave>1),1)/size(data.time,1))*100; 

    
%% Save mat file for internal Use
    
    %set start date based on final dataset start/stop (UTC)
    buoy_info.startdate = data.time(1); buoy_info.enddate = data.time(end); 
    
    %read metadata file to get operating institution name 
    regional_metadata = readtable(buoy_info.regional_metadata,'VariableNamingRule','preserve'); 
    site_metadata = readcell(buoy_info.metadata_file); 
    site_vars = site_metadata(1,:);  
    
    %loop over the regional_metadata spreadsheet to find correct
    %institution and metadata
    if contains(site_metadata(contains(site_metadata(:,1),'Operating'),3),'IMOS')
        site_info = regional_metadata(contains(regional_metadata.operating_institution,'IMOS'),:);
    else
        for jj =1 :size(regional_metadata,1)
            if  contains(regional_metadata.operating_institution{jj},site_metadata(contains(site_metadata(:,1),'Operating'),3))
                site_info = regional_metadata(jj,:); 
            end
        end
    end       

    vars = site_info.Properties.VariableNames; 
    for jj =1:length(vars)
        if iscell(site_info.(vars{jj}))
            buoy_info.(vars{jj}) = site_info.(vars{jj}){1}; 
        else
            buoy_info.(vars{jj}) = site_info.(vars{jj});
        end
    end    

    fname = make_imos_ardc_filename(buoy_info,'ALL'); 
    fname = strrep(fname,'nc','mat');     
   
    save(fname,'baro','buoy_info','buoy_metadata','data','gps','surface_temp','smart_mooring_bm','smart_mooring_bm_agg','-v7.3'); 
    
    
    %write outputs if passes the final watch circle QC; otherwise, write log file with issues to check
    if data.qc_fail>buoy_info.qc_percent_fail | data.watch_circle_flag>0
        % write log file for this deployment processing if bad data and needs closer look
        fname = ['processingLog_' buoy_info.name '_' datestr(datetime('now'),'yyyymmdd_HHMMSS') '.txt']; 
        logfile = fullfile(buoy_info.archive_path,fname); 
        flog = fopen(logfile,'a'); 
        fprintf(flog, [buoy_info.name ' failed the watch circle QAQC tests OR too much flagged data and needs a closer look.']); 
        fclose(flog); 
    else
       %% Organise for netCDF following IMOS-ARDC conventions      
                       
        %make time a datenum for netCDF codes 
        data.time = datenum(data.time); 
        data.temp_time = datenum(data.temp_time); 
        data.disp_time = datenum(data.disp_time); 

        %modify author name
        buoy_info.author = strrep(buoy_info.author,'-',', '); 
        
        %%  Integral Wave Parameters 
        
        globfile = [mpath '\wavebuoys\imos_nc\metadata\glob_att_integralParams_ardc.txt']; 

        if strcmp(buoy_info.type,'datawell')
            varsfile = [mpath '\wavebuoys\imos_nc\metadata\bulkwave_parameters_DM_mapping_DWR4.csv']; 
        else
            varsfile = [mpath '\wavebuoys\imos_nc\metadata\bulkwave_parameters_DM_mapping.csv']; 
        end
        globfile_Int = globfile;
        varsfile_Int = varsfile;
        bulkparams_to_IMOS_ARDC_nc(data, buoy_info, globfile, varsfile); 

        %% displacements

        globfile = [mpath '\wavebuoys\imos_nc\metadata\glob_att_rawDispl_ardc.txt']; 
        if strcmp(buoy_info.type,'datawell')
            varsfile = [mpath '\wavebuoys\imos_nc\metadata\rawDispl_parameters_DM_mapping.csv']; 
        else
            varsfile = [mpath '\wavebuoys\imos_nc\metadata\rawDispl_parameters_DM_mapping.csv']; 
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
            dfields = {'operating_institution_long_name', 'instrument', 'site_name','acknowledgement','citation',...
                'principal_investigator','principal_investigator_email','serial','naming_authority'}; 
            for mm = 1:length(dfields)
                disp_buoy_info.(dfields{mm}) = buoy_info.(dfields{mm}); 
            end

            displacements_to_IMOS_ARDC_nc(displacements, disp_buoy_info, globfile, varsfile); 
        end

        globfile_Disp = globfile;
        varsfile_Disp = varsfile;              
        %% spectral data

        globfile = [mpath '\wavebuoys\imos_nc\metadata\glob_att_spectral_ardc.txt']; 
        if strcmp(buoy_info.type,'datawell')
            varsfile = [mpath '\wavebuoys\imos_nc\metadata\spectral_parameters_DM_mapping_DWR4.csv']; 
        else
            varsfile = [mpath '\wavebuoys\imos_nc\metadata\spectral_parameters_DM_mapping.csv']; 
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
        save(fname,'baro','buoy_info','buoy_metadata','data','gps','surface_temp','smart_mooring_bm','smart_mooring_bm_agg',...
            'globfile_Spec','globfile_Disp','globfile_Int','varsfile_Spec','varsfile_Disp','varsfile_Int','buoy_info','disp_buoy_info','mpath','-v7.3'); 
    end
end



        

        
        
       




