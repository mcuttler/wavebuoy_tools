%%  Process wave buoys (real time) for display on wawaves.org

%     Example usage for Sofar Spotter: 
%                 buoy_info.type = 'sofar'; 
%                 buoy_info.name = 'SPOT0171'; %spotter serial number, or deployment location for Datawell 
%                 buoy_info.DeployLoc = 'Testing';
%                 buoy_info.DeployDepth = 30; 

%     Example usage for Datawell: 
%                 buoy_info.type = 'datawell'; 
%                 buoy_info.name = 'Datawell'; %spotter serial number, or deployment location for Datawell 
%                 buoy_info.DeployLoc = 'Testing';
%                 buoy_info.DeployDepth = 30; 
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%     
% Code history
% 
%     Author          | Date             | Script Version     | Update
%     -------------------------------------------------------------------------------------------------------------------------
%     M. Cuttler     | 26 Nov 2020 | 1.0                     | Initial creation
% -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
%     M. Cuttler     | 22 Dec 2020 | 1.1                     | Update code
%                                                                           for handling Spotter data
%--------------------------------------------------------------------------------------------------------------------------------------------------
%     M. Cuttler     | 14 Jan 2021 | 1.2                     | Update code
%                                                                           for handling Datawell data

%% set initial paths for wave buoy data to process and parser script
clear; clc

%location of wavebuoy_tools repo
buoycodes = 'E:\CUTTLER_GitHub\wavebuoy_tools\wavebuoys'; 
addpath(genpath(buoycodes))

%buoy type and deployment info number and deployment info 
buoy_info.type = 'sofar'; 
buoy_info.serial = 'SPOT-0559'; %spotter serial number, or just Datawell 
buoy_info.name = 'ExmouthGulf'; 
buoy_info.datawell_name = 'nan'; 
buoy_info.version = 'V2'; %or DWR4 for Datawell, for example
buoy_info.DeployLoc = 'ExmouthGulf';
buoy_info.DeployDepth = 30; 
buoy_info.DeployLat = -31.8516; 
buoy_info.DeployLon = 115.6469; 
buoy_info.UpdateTime =  1; %hours
buoy_info.DataType = 'parameters'; %can be parameters if only bulk parameters, or spectral for including spectral coefficients
buoy_info.archive_path = 'E:\CUTTLER_GitHub\wavebuoy_tools\wavebuoys\example_archive';
buoy_info.datawell_datapath = 'D:\Active_Projects\LOWE_IMOS_WaveBuoys\Data\waves_website\CodeTesting\waved'; %top level directory for Datawell CSVs

%use this website to calculate magnetic declination: https://www.ngdc.noaa.gov/geomag/calculators/magcalc.shtml#declination
% buoy_info.MagDec = 1.98; 

%% process realtime mode data

%Sofar Spotter (v1 and v2) 
if strcmp(buoy_info.type,'sofar')==1            
    
    if strcmp(buoy_info.DataType,'parameters')
        limit = buoy_info.UpdateTime*2; 
        [SpotData] = Get_Spoondrift_Data_realtime(buoy_info.serial, limit);     
    elseif strcmp(buoy_info.DataType,'spectral'); 
        limit = buoy_info.UpdateTime; 
        [SpotData] = Get_Spoondrift_Data_realtime_fullwaves(buoy_info.serial, limit);     
    end                    
    
    for i = 1:size(SpotData.time,1)
        SpotData.name{i,1} = buoy_info.name; 
    end
    
    %load in any existing data for this site and combine with new
    %measurements, then QAQC
    [check] = check_archive_path(buoy_info.archive_path, buoy_info, SpotData);    
    
    %check>0 means that directory already exists (and monthly file should
    %exist); otherwise, this is the first data for this location 
    if all(check)~=0        
        [archive_data] = load_archived_data(buoy_info.archive_path, buoy_info, SpotData);                  
        
        %check that it's new data
        if SpotData.time(1)>archive_data.time(end)
            %perform some QA/QC --- QARTOD 19 and QARTOD 20        
            [data] = qaqc_bulkparams_realtime_website(buoy_info, archive_data, SpotData);                        
            
            %save data to different formats        
            realtime_archive_mat(buoy_info, data);                   
            realtime_archive_text(buoy_info, data, limit); 
            %output MEM and SST plots 
            if strcmp(buoy_info.DataType,'spectral')        
                [NS, NE, ndirec] = lygre_krogstad(SpotData.a1,SpotData.a2,SpotData.b1,SpotData.b2,SpotData.varianceDensity);
                make_MEM_plot(ndirec, SpotData.frequency, NE, SpotData.hsig, SpotData.tp, SpotData.dp, SpotData.time, buoy_info)        
                %     elseif strcmp(buoy_info.version, 'V2'); 
                %         make_SST_plot()
            end
    
            %code to update the buoy info master file for website to read 
            update_website_buoy_info(buoy_info, data); 
        end
    else
        SpotData.qf_waves = ones(size(SpotData.time,1),1).*4; 
        SpotData.qf_sst = ones(size(SpotData.temp_time,1),1).*4; 
        SpotData.qf_bott_temp = ones(size(SpotData.temp_time,1),1).*4; 
        realtime_archive_mat(buoy_info, SpotData); 
        realtime_archive_text(buoy_info, SpotData, limit); 
        
        %output MEM and SST plots 
        if strcmp(buoy_info.DataType,'spectral')        
            [NS, NE, ndirec] = lygre_krogstad(SpotData.a1,SpotData.a2,SpotData.b1,SpotData.b2,SpotData.varianceDensity);
            make_MEM_plot(ndirec, SpotData.frequency, NE, SpotData.hsig, SpotData.tp, SpotData.dp, SpotData.time, buoy_info)        
            %     elseif strcmp(buoy_info.version, 'V2'); 
            %         make_SST_plot()
        end
    
        %code to update the buoy info master file for website to read 
        update_website_buoy_info(buoy_info, SpotData); 
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
                limit = 1;         
                realtime_archive_text(buoy_info, data, limit);             
                
                %output MEM and SST plots 
                plot_idx = find(data.time>archive_data.time(end)); 
                if strcmp(buoy_info.DataType,'spectral')                        
                    for ii = 1:size(plot_idx,1); 
                        [NS, NE, ndirec] = lygre_krogstad_MC(data.a1(plot_idx(ii),:),data.a2(plot_idx(ii),:),data.b1(plot_idx(ii),:),data.b2(plot_idx(ii),:),data.E(plot_idx(ii),:),3);
                        make_MEM_plot(ndirec, data.frequency, NE, data.hsig(plot_idx(ii)), data.tp(plot_idx(ii)), data.dp(plot_idx(ii)), data.time(plot_idx(ii)), buoy_info)    
                    end
                    %             elseif strcmp(buoy_info.version, 'V2');
                    %                 make_SST_plot(buoy_info, dw_data.temp_time, dw_data.time, plot_idx); 
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
        limit = 1; 
        realtime_archive_text(buoy_info, dw_data, limit); 
        
        %output MEM and SST plots 
        if strcmp(buoy_info.DataType,'spectral')        
            for ii = 1:size(dw_data.a1,1); 
                [NS, NE, ndirec] = lygre_krogstad_MC(data.a1(plot_idx(ii),:),data.a2(plot_idx(ii),:),data.b1(plot_idx(ii),:),data.b2(plot_idx(ii),:),data.E(plot_idx(ii),:),3);
                make_MEM_plot(ndirec, data.frequency, NE, data.hsig(plot_idx(ii)), data.tp(plot_idx(ii)), data.dp(plot_idx(ii)), data.time(plot_idx(ii)), buoy_info)    
            end
            %     elseif buoy_info.plot_SST==1;
            %         plot_idx = 0; %plot all available time points         
            %         make_SST_plot(buoy_info, dw_data.temp_time, dw_data.temp)
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










        

        
        
       




