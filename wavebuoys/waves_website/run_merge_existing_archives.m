%% run merge existing archives
clear; clc; 

buoy_info.type = 'sofar'; 
buoy_info.serial = 'SPOT-0551'; %spotter serial number, or just Datawell 
buoy_info.name = 'GoodrichBank'; 
buoy_info.datawell_name = 'nan'; 
buoy_info.version = 'V2'; %or DWR4 for Datawell, for example
buoy_info.sofar_token = 'e0eb70b6d9e0b5e00450929139ea34'; 
buoy_info.utc_offset = 8; 
buoy_info.DeployLoc = 'GoodrichBank';
buoy_info.DeployDepth = 90; 
buoy_info.DeployLat = -10.416983; 
buoy_info.DeployLon = 130.000567; 
buoy_info.UpdateTime =  1; %hours
buoy_info.DataType = 'parameters'; %can be parameters if only bulk parameters, or spectral for including spectral coefficients
buoy_info.archive_path = 'E:\wawaves';
buoy_info.backup_path = 'X:\LOWE_IMOS_Deakin_Collab_JUN2020\Data\waves_website\realtime_archive_backup';
buoy_info.datawell_datapath = 'E:\waved'; %top level directory for Datawell CSVs


%%
% start_date = datenum(2020,01,01); 
% end_date = datenum(2021,03,01); 


[merged_data] = merge_existing_archives(buoy_info); 

%% quality control
bulkparams = merged_data; 
qaqc.time = bulkparams.time; 
qaqc.WVHGT = bulkparams.hsig; 
qaqc.WVPD = bulkparams.tp; 
if isfield(bulkparams, 'temp_time')
    qaqc.time_temp = bulkparams.temp_time; 
    qaqc.SST = bulkparams.surf_temp; 
    qaqc.BOTT_TEMP = bulkparams.bott_temp; 
end

%settings for range test (QARTOD19) 
qaqc.MINWH = 0.01;
qaqc.MAXWH = 12;
qaqc.MINWP = 1; 
qaqc.MAXWP = 25;
qaqc.MAXT = 45; 
qaqc.MINT = 0; 

%settings UWA 'master flag' test (combination of QARTOD19 and QARTOD20) -
%requires 3 data points 
qaqc.rocHs =0.5; 
qaqc.HsLim = 10; 
qaqc.rocTp = 10; 
qaqc.TpLim = 25; 
qaqc.rocSST = 2; 

if isfield(qaqc, 'time_temp')
    [bulkparams.qf_waves, bulkparams.qf_sst, bulkparams.qf_bott_temp] = qaqc_uwa_waves_website(qaqc); 
else
    [bulkparams.qf_waves, ~, ~] = qaqc_uwa_waves_website(qaqc);
end

%%
merged_data_qc = bulkparams; 

dv = datevec(bulkparams.time); 
tt = unique(dv(:,1:2),'rows'); 
for jj = 1:size(tt,1)
    idx = find(dv(:,1)==tt(jj,1)&dv(:,2)==tt(jj,2)); 
    
    

%% back fill 
% site = 'GoodrichBank'; 
% % site = buoy_info.name;  
% data_path = 'E:\wawaves'; 
% %remove text archive
% rmdir([data_path '\' site  '\text_archive'],'s'); 
% backfill_RT_text_archive(data_path, site); 


