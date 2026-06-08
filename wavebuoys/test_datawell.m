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

        %now down-sample temperature to same time as waves - this gets rid of current data as well      
        % data_nc = rmfield(data,{'surf_temp','bott_temp','curr_mag','curr_dir','curr_mag_std','curr_dir_std','w','w_std','curr_dir_std'}); 
        % if size(data.temp_time,1)~=size(data.time,1)
        %     for i = 1:size(data.time,1)
        %         ind = find(abs(data.time(i) - data.temp_time)==min(abs(data.time(i) - data.temp_time))); 
        %         if length(ind)>1
        %             data_nc.surf_temp(i,1) = nanmean(data.surf_temp(ind));             
        %             data_nc.bott_temp(i,1) = nanmean(data.bott_temp(ind)); 
        %         else
        %             data_nc.surf_temp(i,1) = (data.surf_temp(ind));             
        %             data_nc.bott_temp(i,1) = (data.bott_temp(ind)); 
        %         end
        %     end
        % end
        % data_nc.temp_time= data.time; 
        % data = data_nc; 
        % clear data_nc
    
    
 