%% run modify smart mooring archive
clear; clc; 


%buoy type and deployment info number and deployment info 
buoy_info.type = 'sofar'; 
buoy_info.serial = 'SPOT-1037'; %spotter serial number, or just Datawell 
buoy_info.name = 'Thevenard'; 
buoy_info.datawell_name = 'nan'; 
buoy_info.version = 'smart_mooring'; %V1, V2, smart_mooring, Datawell, Triaxys
buoy_info.sofar_token = 'a1b3c0dbaa16bb21d5f0befcbcca51'; 
buoy_info.utc_offset = 8; 
buoy_info.DeployLoc = 'Thevenard';
buoy_info.DeployDepth = 20; 
buoy_info.DeployLat = -21.418817; 
buoy_info.DeployLon = 114.892167; 
buoy_info.UpdateTime =  1; %hours
buoy_info.DataType = 'parameters'; %can be parameters if only bulk parameters, or spectral for including spectral coefficients
buoy_info.archive_path = 'E:\wawaves';
buoy_info.backup_path = '\\drive.irds.uwa.edu.au\OGS-COD-001\CUTTLER_wawaves\Data\realtime_archive_backup'; 
buoy_info.datawell_datapath = 'E:\waved'; %top level directory for Datawell CSVs
limit = 500; 
%%
modify_smart_mooring_archive; 

%%
%run backfill
clear; clc; 
site = 'BremerCanyon_Drifting'; 
% site = buoy_info.name;  
data_path = 'E:\wawaves'; 
%remove text archive
rmdir([data_path '\' site  '\text_archive'],'s'); 
backfill_RT_text_archive(data_path, site); 
