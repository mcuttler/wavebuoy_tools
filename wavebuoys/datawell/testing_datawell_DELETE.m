%% Testing Datawell workflows
clear; clc

%location of wavebuoy_tools repo
buoycodes = 'E:\CUTTLER_GitHub\wavebuoy_tools\wavebuoys'; 
addpath(genpath(buoycodes))

%buoy type and deployment info number and deployment info 
buoy_info.type = 'datawell'; 
buoy_info.serial = 'Datawell'; %spotter serial number, or just Datawell 
buoy_info.name = 'Torbay'; 
buoy_info.datawell_name = 'Dev_site'; 
buoy_info.version = 'DWR4'; %or DWR4 for Datawell, for example
buoy_info.DeployLoc = 'Torbay';
buoy_info.DeployDepth = 30; 
buoy_info.DeployLat = -35.079667; 
buoy_info.DeployLon = 117.97900; 
buoy_info.UpdateTime =  1; %hours
buoy_info.DataType = 'parameters'; %can be parameters if only bulk parameters, or spectral for including spectral coefficients
buoy_info.archive_path = 'E:\CUTTLER_GitHub\wavebuoy_tools\wavebuoys\example_archive';
buoy_info.datawell_datapath = 'D:\Active_Projects\LOWE_IMOS_WaveBuoys\Data\waves_website\CodeTesting\waved'; %top level directory for Datawell CSVs

%%
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


%%
%export plots and text data
%     make_MEM_plot(ndirec, freq, NE(:,:,ii), hs, tp, dp, timewave, buoyname, pathMEMplot);

%write 1D and 2D spectra to text
%     [spec1D] = export_spec1d_spec2d(path1D, path2D, freq, ndirec, NE(:,:,ii), timewave, buoyname);
    