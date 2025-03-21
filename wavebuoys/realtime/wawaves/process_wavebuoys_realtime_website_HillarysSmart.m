%%  Process wave buoys (real time) for display on wawaves.org

%MC to update prior to merging into master branch


%% set initial paths for wave buoy data to process and parser script
clear; clc

%location of wavebuoy_tools repo
% buoycodes = 'C:\Data\wavebuoy_tools\wavebuoys'; 
% addpath(genpath(buoycodes))

%buoy type and deployment info number and deployment info 
buoy_info.type = 'sofar'; 
buoy_info.serial = 'SPOT-30320R'; %spotter serial number, or just Datawell 
buoy_info.name = 'Dunsborough'; 
buoy_info.datawell_name = 'nan'; 
buoy_info.version = 'smart_mooring_combined'; %V1, V2, smart_mooring, Datawell, Triaxys
buoy_info.sofar_token = 'e0eb70b6d9e0b5e00450929139ea34'; 
buoy_info.utc_offset = 8; 
buoy_info.DeployLoc = 'Hillarys';
buoy_info.DeployDepth = 30; 
buoy_info.DeployLat = -31.8517;
buoy_info.DeployLon = 115.6465;
buoy_info.UpdateTime =  1; %hours
buoy_info.DataType = 'parameters'; %can be parameters if only bulk parameters, or spectral for including spectral coefficients
buoy_info.web_path = 'E:\wawaves';
buoy_info.archive_path = 'G:\wawaves'; 
buoy_info.website_filename = 'buoys.csv'; 
buoy_info.backup_path = '\\drive.irds.uwa.edu.au\OGS-COD-001\CUTTLER_wawaves\Data\realtime_archive_backup'; 
buoy_info.datawell_datapath = 'E:\waved'; %top level directory for Datawell CSVs
%data for search radius and alert
buoy_info.time_cutoff = 3; %hours
buoy_info.search_rad = 150; %meters for watch circle radius 

%% process realtime mode data

%Sofar Spotter (v1 and v2) 
if strcmp(buoy_info.type,'sofar')==1            
    %check whether smart mooring or normal mooring
    if contains(buoy_info.version,'smart_mooring')
        limit = buoy_info.UpdateTime*2; %note, for AQL they only transmit 2 points even though it's 2 hour update time
        [SpotData, flag] = Get_Spoondrift_SmartMooring_realtime_v2(buoy_info,limit);
        flag = 1; %ignore flag in Smart mooring code 
    else
        limit = buoy_info.UpdateTime*2; %not used in v2 code
        [SpotData] = Get_Spoondrift_Data_realtime_v2(buoy_info, limit);         
        flag = 1;                  
    end    
    
    if flag == 1
        for i = 1:size(SpotData.time,1)
            SpotData.name{i,1} = buoy_info.name; 
        end
        
        %load in any existing data for this site and combine with new
        %measurements, then QAQC
        [check] = check_archive_path(buoy_info, SpotData); 
        % Think this warning is the email function
        [warning] = spotter_buoy_search_radius_and_alert(buoy_info, SpotData);
        
        % check>0 means that directory already exists (and monthly file should
        % exist); otherwise, this is the first data for this location 
        
        if all(check)~=0      
            [archive_data] = load_archived_data(buoy_info);                  
            %add serial ID and name if not already there
            if ~isfield(archive_data,'serialID')
                for i = 1:size(archive_data.time,1)
                    archive_data.serialID{i,1} = buoy_info.serial;
                end
            end
            if ~isfield(archive_data,'name')
                for i = 1:size(archive_data.time,1)
                    archive_data.name{i,1} = buoy_info.name;
                end
            end   
            
            %check that it's new data
            idx_w = find(SpotData.time>archive_data.time(end)); 
            idx_t = find(SpotData.temp_time>archive_data.temp_time(end)); 
            idx_p = find(SpotData.press_time>archive_data.press_time(end)); 
            idx_pstd = find(SpotData.press_std_time>archive_data.press_std_time(end));            
            
            %add spectral data if it exists in archive
            if isfield(SpotData,'spec_time') & isfield(archive_data,'spec_time')
                idx_s = find(SpotData.spec_time>archive_data.spec_time(end));
            elseif isfield(SpotData,'spec_time') & ~isfield(archive_data,'spec_time'); 
                idx_s = [1:length(SpotData.spec_time)]';
            else
                idx_s = []; 
            end
            
            %add spectral data if it exists in archive
            if isfield(SpotData,'part_time') & isfield(archive_data,'part_time')
                idx_part = find(SpotData.part_time>archive_data.part_time(end));
            elseif isfield(SpotData,'part_time') & ~isfield(archive_data,'part_time')
                idx_part = [1:length(SpotData.part_time)]';           
            else
                idx_part = [];
            end
            
            
            %if smart mooring, only keep new temp and wave data
            if ~isempty(idx_w)&~isempty(idx_t)
                ff = fieldnames(SpotData); 
                for f = 1:length(ff)
                    if strcmp(ff{f},'temp_time')|strcmp(ff{f},'surf_temp')|strcmp(ff{f},'bott_temp')
                        SpotData.(ff{f}) = SpotData.(ff{f})(idx_t,:); 
                    elseif strcmp(ff{f},'press_time')|strcmp(ff{f},'pressure')
                        SpotData.(ff{f}) = SpotData.(ff{f})(idx_p,:); 
                    elseif strcmp(ff{f},'press_std_time')|strcmp(ff{f},'pressure_std')
                        SpotData.(ff{f}) = SpotData.(ff{f})(idx_pstd,:); 
                    elseif (contains(ff{f},'swell')|contains(ff{f},'sea')|strcmp(ff{f},'part_time'))&~strcmp(ff{f},'wind_seasurfaceId')
                        SpotData.(ff{f}) = SpotData.(ff{f})(idx_part,:); 
                    elseif strcmp(ff{f},'spec_time')|size(SpotData.(ff{f}),2)>1
                        SpotData.(ff{f}) = SpotData.(ff{f})(idx_s,:); 
                    else
                        SpotData.(ff{f}) = SpotData.(ff{f})(idx_w,:);
                    end
                end                             
                clear ff idx_w idx_t f idx_p idx_pstd            
                if SpotData.time(1)>archive_data.time(end)
                    %perform some QA/QC --- QARTOD 19 and QARTOD 20        
                    [data] = qaqc_bulkparams_realtime_website(buoy_info, archive_data, SpotData);                                        
                    
                    %save data to different formats        
                    realtime_archive_mat(buoy_info, data);
                    realtime_archive_text(buoy_info, data, size(SpotData.time,1)); 
                    realtime_backup_mat(buoy_info, data);
                    
                    %output MEM and SST plots 
                    if strcmp(buoy_info.DataType,'spectral')        
                        [NS, NE, ndirec] = lygre_krogstad(SpotData.a1,SpotData.a2,SpotData.b1,SpotData.b2,SpotData.varianceDensity);
                        make_MEM_plot(ndirec, SpotData.frequency, NE, SpotData.hsig, SpotData.tp, SpotData.dp, SpotData.time, buoy_info)        
                    end
                    
                    %code to update the buoy info master file for website to read
                    update_website_buoy_info(buoy_info, data); 
                end
                clear idx_t idx_w
            end            
        else
            SpotData.qf_waves = ones(size(SpotData.time,1),1).*4;
            if isfield(SpotData,'temp_time')
                SpotData.qf_sst = ones(size(SpotData.temp_time,1),1).*4;                             
                SpotData.qf_bott_temp = ones(size(SpotData.temp_time,1),1).*4; 
            end

            realtime_archive_mat(buoy_info, SpotData);
            realtime_archive_text(buoy_info, SpotData, size(SpotData.time,1)); 
            realtime_backup_mat(buoy_info, SpotData);
                    
            %output MEM and SST plots 
            if strcmp(buoy_info.DataType,'spectral')        
                [NS, NE, ndirec] = lygre_krogstad(SpotData.a1,SpotData.a2,SpotData.b1,SpotData.b2,SpotData.varianceDensity);
                make_MEM_plot(ndirec, SpotData.frequency, NE, SpotData.hsig, SpotData.tp, SpotData.dp, SpotData.time, buoy_info)        
            end
            
            %code to update the buoy info master file for website to read
            update_website_buoy_info(buoy_info, SpotData); 
        end        
    end       
end









        

        
        
       




