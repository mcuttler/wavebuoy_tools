%%  Process wave buoys (real time) for display on wawaves.org

%MC to update prior to merging into master branch



%% set initial paths for wave buoy data to process and parser script
clear; clc

%location of wavebuoy_tools repo
% buoycodes = 'C:\Data\wavebuoy_tools\wavebuoys'; 
% addpath(genpath(buoycodes))

%buoy type and deployment info number and deployment info 
buoy_info.type = 'sofar'; 
buoy_info.serial = 'SPOT-1734'; %spotter serial number, or just Datawell 
buoy_info.name = 'Tantabiddi'; 
buoy_info.datawell_name = 'nan'; 
buoy_info.version = 'smart_mooring'; %V1, V2, smart_mooring, Datawell, Triaxys
buoy_info.sofar_token = 'a1b3c0dbaa16bb21d5f0befcbcca51'; 
buoy_info.utc_offset = 8; 
buoy_info.DeployLoc = 'Tantabiddi';
buoy_info.DeployDepth = 19;
buoy_info.DeployLat = -21.9024;
buoy_info.DeployLon = 113.9290; 
buoy_info.UpdateTime =  1; %hours
buoy_info.DataType = 'parameters'; %can be parameters if only bulk parameters, or spectral for including spectral coefficients
buoy_info.archive_path = 'E:\wawaves';
buoy_info.website_filename = 'buoys.csv'; 
buoy_info.backup_path = '\\drive.irds.uwa.edu.au\OGS-COD-001\CUTTLER_wawaves\Data\realtime_archive_backup'; 
buoy_info.datawell_datapath = 'E:\waved'; %top level directory for Datawell CSVs
%data for search radius and alert
buoy_info.time_cutoff = 6; %hours
buoy_info.search_rad = 250; %meters for watch circle radius 
%use this website to calculate magnetic declination: https://www.ngdc.noaa.gov/geomag/calculators/magcalc.shtml#declination
% buoy_info.MagDec = 1.98; 

%% process realtime mode data

%Sofar Spotter (v1 and v2) 
if strcmp(buoy_info.type,'sofar')==1            
    %check whether smart mooring or normal mooring
    if strcmp(buoy_info.version,'smart_mooring')
        limit = buoy_info.UpdateTime*2; %note, for AQL they only transmit 2 points even though it's 2 hour update time
        [SpotData, flag] = Get_Spoondrift_SmartMooring_realtime(buoy_info, limit); 
        flag = 1; %ignore flag in Smart mooring code 
    else
        if strcmp(buoy_info.DataType,'parameters')
            limit = buoy_info.UpdateTime*2;     
            [SpotData] = Get_Spoondrift_Data_realtime(buoy_info, limit);   
            flag = 1; 
        elseif strcmp(buoy_info.DataType,'spectral'); 
            limit = buoy_info.UpdateTime; 
            [SpotData] = Get_Spoondrift_Data_realtime_fullwaves(buoy_info, limit);     
            flag = 1; 
        end                    
    end    
    
    if flag == 1
        for i = 1:size(SpotData.time,1)
            SpotData.name{i,1} = buoy_info.name; 
        end
        
        %load in any existing data for this site and combine with new
        %measurements, then QAQC
        [check] = check_archive_path(buoy_info.archive_path, buoy_info, SpotData);    
        [warning] = spotter_buoy_search_radius_and_alert(buoy_info, SpotData);
        %check>0 means that directory already exists (and monthly file should
        %exist); otherwise, this is the first data for this location 
        if all(check)~=0        
            [archive_data] = load_archived_data(buoy_info.archive_path, buoy_info);                    
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
            
            %SpotData needs to be newer wave data, but the temperature time
            %also needs to end after the wave data for other codes to work
            %correctly (this is for Aqualink only !!)
            
            %%uncomment below when running on Aqualink schedule
%             if SpotData.time(1)>archive_data.time(end) && SpotData.temp_time(end)>SpotData.time(end) 
            if SpotData.time(1)>archive_data.time(end)    
                %check that it's new data
                idx_w = find(SpotData.time>archive_data.time(end)); 
                idx_t = find(SpotData.temp_time>archive_data.temp_time(end)); 
                %if smart mooring, only keep new temp and wave data
                ff = fieldnames(SpotData); 
                for f = 1:length(ff)
                    if strcmp(ff{f},'temp_time')|strcmp(ff{f},'surf_temp')|strcmp(ff{f},'bott_temp')
                        SpotData.(ff{f}) = SpotData.(ff{f})(idx_t,:); 
                    else
                        SpotData.(ff{f}) = SpotData.(ff{f})(idx_w,:);
                    end
                end
                clear ff idx_w idx_t f
                
                %perform some QA/QC --- QARTOD 19 and QARTOD 20        
                [data] = qaqc_bulkparams_realtime_website(buoy_info, archive_data, SpotData);                                        

                %save data to different formats        
                realtime_archive_mat(buoy_info, data);
                realtime_archive_text(buoy_info, data, limit); 
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
        else
            SpotData.qf_waves = ones(size(SpotData.time,1),1).*4;
            if isfield(SpotData,'temp_time')
                SpotData.qf_sst = ones(size(SpotData.temp_time,1),1).*4; 
                SpotData.qf_bott_temp = ones(size(SpotData.temp_time,1),1).*4; 
                
            end
            realtime_archive_mat(buoy_info, SpotData);
            realtime_archive_text(buoy_info, SpotData, limit); 
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
%---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 %Datawell DWR4 
elseif strcmp(buoy_info.type,'datawell')==1
    data.time = datenum(now); 
    data.tnow = datevec(data.time); 
    
    data.file20 = [buoy_info.datawell_datapath '\' buoy_info.datawell_name '\' num2str(data.tnow(1)) '\' num2str(data.tnow(2),'%02d') '\' buoy_info.datawell_name '{0xF20}' num2str(data.tnow(1)) '-' num2str(data.tnow(2),'%02d') '.csv'];
    data.file21 = [buoy_info.datawell_datapath '\' buoy_info.datawell_name '\' num2str(data.tnow(1)) '\' num2str(data.tnow(2),'%02d') '\' buoy_info.datawell_name '{0xF21}' num2str(data.tnow(1)) '-' num2str(data.tnow(2),'%02d') '.csv'];
    data.file25 = [buoy_info.datawell_datapath '\' buoy_info.datawell_name '\' num2str(data.tnow(1)) '\' num2str(data.tnow(2),'%02d') '\' buoy_info.datawell_name '{0xF25}' num2str(data.tnow(1)) '-' num2str(data.tnow(2),'%02d') '.csv'];
    data.file28 = [buoy_info.datawell_datapath '\' buoy_info.datawell_name '\' num2str(data.tnow(1)) '\' num2str(data.tnow(2),'%02d') '\' buoy_info.datawell_name '{0xF28}' num2str(data.tnow(1)) '-' num2str(data.tnow(2),'%02d') '.csv'];
    data.file82 = [buoy_info.datawell_datapath '\' buoy_info.datawell_name '\' num2str(data.tnow(1)) '\' num2str(data.tnow(2),'%02d') '\' buoy_info.datawell_name '{0xF82}' num2str(data.tnow(1)) '-' num2str(data.tnow(2),'%02d') '.csv'];    
    
    %original code for Datawell buoys does all checking of directories and
    %grabbing archived data
    [dw_data, archive_data,check] = Process_Datawell_realtime_website(buoy_info, data, data.file20, data.file21, data.file25, data.file28, data.file82);
    clear data; 
    
    %check that it's new data
    
    if all(check)~=0
        if ~isempty(archive_data)
            if size(dw_data.time,1)>size(archive_data.time,1)
                %perform some QA/QC --- QARTOD 19 and QARTOD 20        
                [data] = qaqc_bulkparams_realtime_website(buoy_info, archive_data, dw_data);                        
                
                %save data to different formats        
                realtime_archive_mat(buoy_info, data);
%                 realtime_backup_mat(buoy_info, data);
                limit = 1;         
                realtime_archive_text(buoy_info, data, limit);             
                
                %output MEM and SST plots 
                plot_idx = find(data.time>archive_data.time(end)); 
                if strcmp(buoy_info.DataType,'spectral')                        
                    for ii = 1:size(plot_idx,1); 
                        [NS, NE, ndirec] = lygre_krogstad_MC(data.a1(plot_idx(ii),:),data.a2(plot_idx(ii),:),data.b1(plot_idx(ii),:),data.b2(plot_idx(ii),:),data.E(plot_idx(ii),:),3);
                        make_MEM_plot(ndirec, data.frequency, NE, data.hsig(plot_idx(ii)), data.tp(plot_idx(ii)), data.dp(plot_idx(ii)), data.time(plot_idx(ii)), buoy_info)    
                    end
                end
                
                %code to update the buoy info master file for website to read
                update_website_buoy_info(buoy_info, data); 
            end
        end
    else
        dw_data.qf_waves = ones(size(dw_data.time,1),1).*4;
        dw_data.qf_sst = ones(size(dw_data.temp_time,1),1).*4; 
        dw_data.qf_bott_temp =ones(size(dw_data.temp_time,1),1).*4; 
        realtime_archive_mat(buoy_info, dw_data); 
%         realtime_backup_mat(buoy_info, dw_data);
        limit = 1; 
        realtime_archive_text(buoy_info, dw_data, limit); 
        
        %output MEM and SST plots 
        if strcmp(buoy_info.DataType,'spectral')        
            for ii = 1:size(dw_data.a1,1); 
                [NS, NE, ndirec] = lygre_krogstad_MC(data.a1(plot_idx(ii),:),data.a2(plot_idx(ii),:),data.b1(plot_idx(ii),:),data.b2(plot_idx(ii),:),data.E(plot_idx(ii),:),3);
                make_MEM_plot(ndirec, data.frequency, NE, data.hsig(plot_idx(ii)), data.tp(plot_idx(ii)), data.dp(plot_idx(ii)), data.time(plot_idx(ii)), buoy_info)    
            end    
        end
        
        %code to update the buoy info master file for website to read
        update_website_buoy_info(buoy_info, dw_data); 
    end
%---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
%Triaxys
elseif strcmp(buoy_info.type,'triaxys')
    disp('No Triaxys code yet'); 
end

%%
% quit









        

        
        
       




