%% run modify smart mooring archive
%% set initial paths for wave buoy data to process and parser script
clear; clc

%location of wavebuoy_tools repo
% buoycodes = 'C:\Data\wavebuoy_tools\wavebuoys'; 
% addpath(genpath(buoycodes))
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


%%
tstart = datenum(2021,11,28);
tend = datenum(2021,11,29); 

[archive_data] = load('E:\wawaves\ClerkeLagoon\mat_archive\2021\ClerkeLagoon_202111.mat'); 
archive_data = archive_data.SpotData; 
idx_w = find(archive_data.time>tstart); 
idx_t = find(archive_data.temp_time>tstart); 
ff = fieldnames(archive_data); 
SpotData = archive_data; 
for f = 1:length(ff)
    if strcmp(ff{f},'temp_time')|strcmp(ff{f},'surf_temp')|strcmp(ff{f},'bott_temp')|strcmp(ff{f},'qf_sst')|strcmp(ff{f},'qf_bott_temp')
        SpotData.(ff{f}) = SpotData.(ff{f})(idx_t,:); 
    else
        SpotData.(ff{f}) = SpotData.(ff{f})(idx_w,:);
    end
end
clear ff idx_w idx_t f

realtime_archive_text(buoy_info, SpotData, size(SpotData.time,1)); 
update_website_buoy_info(buoy_info, SpotData); 