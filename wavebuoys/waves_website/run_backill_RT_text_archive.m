%% run modify smart mooring archive
clear; clc; 


%buoy type and deployment info number and deployment info 
clear; clc

%location of wavebuoy_tools repo
% buoycodes = 'C:\Data\wavebuoy_tools\wavebuoys'; 
% addpath(genpath(buoycodes))

%buoy type and deployment info number and deployment info 
%buoy type and deployment info number and deployment info 
buoy_info.type = 'sofar'; 
buoy_info.serial = 'SPOT-1159'; %spotter serial number, or just Datawell 
buoy_info.name = 'ClerkeLagoon'; 
buoy_info.datawell_name = 'nan'; 
buoy_info.version = 'smart_mooring'; %V1, V2, smart_mooring, Datawell, Triaxys
buoy_info.sofar_token = 'a1b3c0dbaa16bb21d5f0befcbcca51'; 
buoy_info.utc_offset = 8; 
buoy_info.DeployLoc = 'ClerkeLagoon';
buoy_info.DeployDepth = 20; 
buoy_info.DeployLat = -17.2902; 
buoy_info.DeployLon = 119.36061; 
buoy_info.UpdateTime =  1; %hours
buoy_info.DataType = 'parameters'; %can be parameters if only bulk parameters, or spectral for including spectral coefficients
buoy_info.archive_path = 'E:\wawaves';
buoy_info.backup_path = '\\drive.irds.uwa.edu.au\OGS-COD-001\CUTTLER_wawaves\Data\realtime_archive_backup'; 
buoy_info.datawell_datapath = 'E:\waved'; %top level directory for Datawell CSVs
%data for search radius and alert
buoy_info.time_cutoff = 6; %hours
buoy_info.search_rad = 190; %meters for watch circle radius 

%use this website to calculate magnetic declination: https://www.ngdc.noaa.gov/geomag/calculators/magcalc.shtml#declination
% buoy_info.MagDec = 1.98; 

%use this website to calculate magnetic declination: https://www.ngdc.noaa.gov/geomag/calculators/magcalc.shtml#declination

limit = 70; 
%%
modify_smart_mooring_archive; 
% 
% %%
% %run backfill
% clear; clc; 
% site = 'BremerCanyon_Drifting'; 
% % site = buoy_info.name;  
% data_path = 'E:\wawaves'; 
% %remove text archive
% rmdir([data_path '\' site  '\text_archive'],'s'); 
% backfill_RT_text_archive(data_path, site); 
