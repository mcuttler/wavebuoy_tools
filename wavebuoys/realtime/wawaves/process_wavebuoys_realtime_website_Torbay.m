%%  Process wave buoys (real time) for display on wawaves.org

%MC to update prior to merging into master branch


%% set initial paths for wave buoy data to process and parser script
clear; clc

%location of wavebuoy_tools repo
% buoycodes = 'C:\Data\wavebuoy_tools\wavebuoys'; 
% addpath(genpath(buoycodes))

%buoy type and deployment info number and deployment info 
buoy_info.type = 'datawell'; 
buoy_info.serial = 'Datawell-74089';  
buoy_info.name = 'Torbay'; 
buoy_info.datawell_name = 'Dev_Site'; 
buoy_info.version = 'DWR4'; %or DWR4 for Datawell, for example
buoy_info.sofar_token = 'e0eb70b6d9e0b5e00450929139ea34'; 
buoy_info.utc_offset = 8; 
buoy_info.DeployLoc = 'Torbay';
buoy_info.DeployDepth = 32; 
buoy_info.DeployLat = -35.06892; 
buoy_info.DeployLon = 117.77054; 
buoy_info.UpdateTime =  1; %hours
buoy_info.DataType = 'spectral'; %can be parameters if only bulk parameters, or spectral for including spectral coefficients
buoy_info.archive_path = 'G:\wawaves';
buoy_info.web_path = 'E:\wawaves';
buoy_info.website_filename = 'buoys.csv'; 
buoy_info.backup_path = '\\drive.irds.uwa.edu.au\OGS-COD-001\CUTTLER_wawaves\Data\realtime_archive_backup\batch_file_test';
buoy_info.backup_path2 = '\\drive.irds.uwa.edu.au\SEE-PNP-001\HANSEN_Albany_WaveEnergy_Feasibility_ongoing\Data\WaveBuoys\realtime_archive_backup';
buoy_info.datawell_datapath = 'G:\waved'; %top level directory for Datawell CSVs

%data for search radius and alert
buoy_info.time_cutoff = 3; %hours
buoy_info.search_rad = 190; %meters for watch circle radius 


%% process realtime mode data

if strcmp(buoy_info.type,'sofar')==1            
%---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 %Datawell DWR4 
elseif strcmp(buoy_info.type,'datawell')==1
    %check buoy position and send email if out of search radius
    [warning] = buoy_search_radius_and_alert(buoy_info);     
    
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
    
    [check] = check_archive_path(buoy_info, dw_data);   
    
    %add Spotter and Smart Mooring fields
    dd = ones(size(dw_data.time,1),1).*-9999; 
    dw_data.dm_sea = dd; 
    dw_data.dm_swell = dd; 
    dw_data.dmspr_sea = dd; 
    dw_data.dmspr_swell = dd; 
    dw_data.endFreq_sea = dd; 
    dw_data.endFreq_swell = dd; 
    dw_data.hsig_sea = dd; 
    dw_data.hsig_swell = dd; 
    dw_data.part_time = dw_data.time; 
    dw_data.press_std_time = dw_data.time; 
    dw_data.press_time = dw_data.time; 
    dw_data.pressure = dd; 
    dw_data.pressure_std = dd; 
    dw_data.spec_time = dw_data.time; 
    dw_data.startFreq_sea = dd; 
    dw_data.startFreq_swell = dd; 
    dw_data.tm_sea = dd; 
    dw_data.tm_swell = dd; 
    dw_data.varianceDensity = dw_data.E.*nan;      
    dw_data.wind_dir = dd; 
    dw_data.wind_speed = dd; 
    dw_data.wind_time = dw_data.time; 
    
    %check that it's new data
    if all(check)~=0
        if ~isempty(archive_data)
            if size(dw_data.time,1)>size(archive_data.time,1)
                %perform some QA/QC --- QARTOD 19 and QARTOD 20        
                [data] = qaqc_bulkparams_realtime_website(buoy_info, archive_data, dw_data);                        
                
                %save data to different formats        
                realtime_archive_mat(buoy_info, data); 
                realtime_backup_mat(buoy_info, data);
                limit = size(dw_data.time,1) - size(archive_data.time,1);             
                realtime_archive_text(buoy_info, data, limit);             
                
                %output MEM and SST plots 
                plot_idx = find(data.time>archive_data.time(end)); 
                if strcmp(buoy_info.DataType,'spectral')                        
                    for ii = 1:size(plot_idx,1) 
                        [NS, NE, ndirec] = lygre_krogstad_MC(data.a1(plot_idx(ii),:),data.a2(plot_idx(ii),:),data.b1(plot_idx(ii),:),data.b2(plot_idx(ii),:),data.E(plot_idx(ii),:),3);
                        make_MEM_plot(ndirec, data.frequency', NE, data.hsig(plot_idx(ii)), data.tp(plot_idx(ii)), data.dp(plot_idx(ii)), data.time(plot_idx(ii)), buoy_info)    
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
        realtime_backup_mat(buoy_info, dw_data);
        limit = 1; 
        realtime_archive_text(buoy_info, dw_data, limit); 
        
        %output MEM and SST plots 
        if strcmp(buoy_info.DataType,'spectral')        
            for ii = 1:size(dw_data.a1,1); 
                [NS, NE, ndirec] = lygre_krogstad_MC(dw_data.a1(ii,:),dw_data.a2(ii,:),dw_data.b1(ii,:),dw_data.b2(ii,:),dw_data.E(ii,:),3);
                make_MEM_plot(ndirec, dw_data.frequency', NE, dw_data.hsig(ii), dw_data.tp(ii), dw_data.dp(ii), dw_data.time(ii), buoy_info)    
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










        

        
        
       




