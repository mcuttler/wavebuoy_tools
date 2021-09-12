%% run modify smart mooring archive
clear; clc

%location of wavebuoy_tools repo
% buoycodes = 'C:\Data\wavebuoy_tools\wavebuoys'; 
% addpath(genpath(buoycodes))

%buoy type and deployment info number and deployment info 
buoy_info.type = 'sofar'; 
buoy_info.serial = 'SPOT-0757'; %spotter serial number, or just Datawell 
buoy_info.name = 'TorbayWest'; 
buoy_info.datawell_name = 'nan'; 
buoy_info.version = 'V1'; %or DWR4 for Datawell, for example
buoy_info.sofar_token = 'e0eb70b6d9e0b5e00450929139ea34'; 
buoy_info.utc_offset = 8; 
buoy_info.DeployLoc = 'TorbayWest';
buoy_info.DeployDepth = 30; 
buoy_info.DeployLat = -35.0695; 
buoy_info.DeployLon = 117.7707; 
buoy_info.UpdateTime =  1; %hours
buoy_info.DataType = 'parameters'; %can be parameters if only bulk parameters, or spectral for including spectral coefficients
buoy_info.archive_path = 'E:\wawaves';
buoy_info.backup_path = '\\drive.irds.uwa.edu.au\OGS-COD-001\CUTTLER_wawaves\Data\realtime_archive_backup'; 
buoy_info.datawell_datapath = 'E:\waved'; %top level directory for Datawell CSVs

%data for search radius and alert
buoy_info.time_cutoff = 3; %hours
buoy_info.search_rad = 190; %meters for watch circle radius 
limit = 150; 
%%
% modify_smart_mooring_archive; 
% 
% %%
%run backfill
% clear; clc; 
% site = 'TorbayWest'; 
% % site = buoy_info.name;  
% data_path = 'E:\wawaves'; 
% %remove text archive
% rmdir([data_path '\' site  '\text_archive'],'s'); 
% backfill_RT_text_archive(data_path, site); 
