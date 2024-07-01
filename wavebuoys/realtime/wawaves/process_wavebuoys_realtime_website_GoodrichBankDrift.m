%%  Process wave buoys (real time) for display on wawaves.org

%MC to update prior to merging into master branch

%AQL public token: a1b3c0dbaa16bb21d5f0befcbcca51
%UWA token: e0eb70b6d9e0b5e00450929139ea34

%% set initial paths for wave buoy data to process and parser script
clear; clc

%location of wavebuoy_tools repo
% buoycodes = 'C:\Data\wavebuoy_tools\wavebuoys'; 
% addpath(genpath(buoycodes))

%buoy type and deployment info number and deployment info 
buoy_info.type = 'sofar'; 
buoy_info.serial = 'SPOT-1292'; %spotter serial number, or just Datawell 
buoy_info.name = 'GoodrichBankDrift'; 
buoy_info.datawell_name = 'nan'; 
buoy_info.version = 'V2'; %or DWR4 for Datawell, for example
buoy_info.sofar_token = 'e0eb70b6d9e0b5e00450929139ea34'; 
buoy_info.utc_offset = 8; 
buoy_info.DeployLoc = 'GoodrichBankDrift';
buoy_info.DeployDepth = 0; 
buoy_info.DeployLat = 0; 
buoy_info.DeployLon = 0; 
buoy_info.UpdateTime =  1; %hours
buoy_info.DataType = 'parameters'; %can be parameters if only bulk parameters, or spectral for including spectral coefficients
buoy_info.web_path = 'E:\wawaves';
buoy_info.archive_path = 'G:\wawaves'; 
buoy_info.website_filename = 'buoys.csv'; 
buoy_info.backup_path = '\\drive.irds.uwa.edu.au\OGS-COD-001\CUTTLER_wawaves\Data\realtime_archive_backup'; 
buoy_info.datawell_datapath = 'E:\waved'; %top level directory for Datawell CSVs
buoy_info.time_cutoff = 3; %hours
buoy_info.search_rad = 0; %meters for watch circle radius 

%use this website to calculate magnetic declination: https://www.ngdc.noaa.gov/geomag/calculators/magcalc.shtml#declination
% buoy_info.MagDec = 1.98; 

%% process realtime mode data

%Sofar Spotter (v1 and v2) 
if strcmp(buoy_info.type,'sofar')==1            
    %check whether smart mooring or normal mooring
    if strcmp(buoy_info.version,'smart_mooring')
        limit = buoy_info.UpdateTime*2; %note, for AQL they only transmit 2 points even though it's 2 hour update time
        [SpotData, flag] = Get_Spoondrift_SmartMooring_realtime(buoy_info, limit); 
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
%         [warning] = spotter_buoy_search_radius_and_alert(buoy_info, SpotData);
        %check>0 means that directory already exists (and monthly file should
        %exist); otherwise, this is the first data for this location 
        if all(check)~=0        
            [archive_data] = load_archived_data(buoy_info);                  
            idx_w = find(SpotData.time>archive_data.time(end));   
            idx_t = find(SpotData.temp_time>archive_data.temp_time(end));    
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
            
            
            
            if ~isempty(idx_w)&~isempty(idx_t)
                ff = fieldnames(SpotData); 
                for f = 1:length(ff)                
                    if strcmp(ff{f},'temp_time')|strcmp(ff{f},'surf_temp')|strcmp(ff{f},'bott_temp')
                        SpotData.(ff{f}) = SpotData.(ff{f})(idx_t,:); 
                    elseif (contains(ff{f},'swell')|contains(ff{f},'sea')|strcmp(ff{f},'part_time'))&~strcmp(ff{f},'wind_seasurfaceId')
                        SpotData.(ff{f}) = SpotData.(ff{f})(idx_part,:); 
                    elseif strcmp(ff{f},'spec_time')|size(SpotData.(ff{f}),2)>1
                        SpotData.(ff{f}) = SpotData.(ff{f})(idx_s,:); 
                    else
                        SpotData.(ff{f}) = SpotData.(ff{f})(idx_w,:);
                    end                
                end
                %check that it's new data
                if SpotData.time(1)>archive_data.time(end)
                    %perform some QA/QC --- QARTOD 19 and QARTOD 20        
                    [data] = qaqc_bulkparams_realtime_website(buoy_info, archive_data, SpotData);                        
                
                    %save data to different formats        
                    realtime_archive_mat(buoy_info, data);
                    realtime_backup_mat(buoy_info, data);
                    realtime_archive_text(buoy_info, data, size(SpotData.time,1)); 
                    %output MEM and SST plots --- only most recent time
                    %point 
                    if strcmp(buoy_info.DataType,'spectral')                        
                        [NS, NE, ndirec] = lygre_krogstad(SpotData.a1(end,:),SpotData.a2(end,:),SpotData.b1(end,:),...
                            SpotData.b2(end,:),SpotData.varianceDensity(end,:));
                        make_MEM_plot(ndirec, SpotData.frequency(end,:), NE, SpotData.hsig(end,1),...
                            SpotData.tp(end,1), SpotData.dp(end,1), SpotData.time(end,1), buoy_info)        
                    end
                    
                    %code to update the buoy info master file for website to read
                    update_website_buoy_info(buoy_info, data); 
                end
            end
        else
            SpotData.qf_waves = ones(size(SpotData.time,1),1).*4;
            if isfield(SpotData,'temp_time')
                SpotData.qf_sst = ones(size(SpotData.temp_time,1),1).*4; 
                SpotData.qf_bott_temp = ones(size(SpotData.temp_time,1),1).*4;                 
            end
            realtime_archive_mat(buoy_info, SpotData);
            realtime_backup_mat(buoy_info, SpotData);
            realtime_archive_text(buoy_info, SpotData, size(SpotData.time,1)); 
            
            %output MEM and SST plots 
            if strcmp(buoy_info.DataType,'spectral')        
                [NS, NE, ndirec] = lygre_krogstad(SpotData.a1(end,:),SpotData.a2(end,:),SpotData.b1(end,:),...
                    SpotData.b2(end,:),SpotData.varianceDensity(end,:));
                make_MEM_plot(ndirec, SpotData.frequency(end,:), NE, SpotData.hsig(end,1),...
                    SpotData.tp(end,1), SpotData.dp(end,1), SpotData.time(end,1), buoy_info)      
            end
            
            %code to update the buoy info master file for website to read
            update_website_buoy_info(buoy_info, SpotData); 
        end        
    end  
end



        

        
        
       




