%% Update archive 

%First grab most recent 500 data points for buoy 
clear; clc

%location of wavebuoy_tools repo
% buoycodes = 'C:\Data\wavebuoy_tools\wavebuoys'; 
% addpath(genpath(buoycodes))

%buoy type and deployment info number and deployment info 
buoy_info.type = 'sofar'; 
buoy_info.serial = 'SPOT-1292'; %spotter serial number, or just Datawell 
buoy_info.name = 'GoodrichBank'; 
buoy_info.datawell_name = 'nan'; 
buoy_info.version = 'V2'; %or DWR4 for Datawell, for example
buoy_info.sofar_token = 'e0eb70b6d9e0b5e00450929139ea34'; 
buoy_info.utc_offset = 8; 
buoy_info.DeployLoc = 'GoodrichBank';
buoy_info.DeployDepth = 90; 
buoy_info.DeployLat = -10.416133; 
buoy_info.DeployLon = 130.000700; 
buoy_info.UpdateTime =  1; %hours
buoy_info.DataType = 'parameters'; %can be parameters if only bulk parameters, or spectral for including spectral coefficients
buoy_info.archive_path = 'E:\wawaves';
buoy_info.backup_path = '\\drive.irds.uwa.edu.au\OGS-COD-001\CUTTLER_wawaves\Data\realtime_archive_backup'; 
buoy_info.datawell_datapath = 'E:\waved'; %top level directory for Datawell CSVs
buoy_info.time_cutoff = 3; %hours
buoy_info.search_rad = 190; %meters for watch circle radius 

%%

limit = 500; %note, for AQL they only transmit 2 points even though it's 2 hour update time       
[SpotData] = Get_Spoondrift_Data_realtime(buoy_info, limit);   
flag = 1; 

for i = 1:size(SpotData.time,1)
    SpotData.name{i,1} = buoy_info.name; 
end

%get archive data
[archive_data] = load_archived_data(buoy_info.archive_path, buoy_info, SpotData);     

%find data that is newer than archive data
idx = find(SpotData.time>archive_data.time(end)); 
if isfield(SpotData, 'temp_time')
    idx_t = find(SpotData.temp_time>archive_data.time(end)); 
end

%clip new data to idx
fields = fieldnames(SpotData); 
for i = 1:size(fields,1)
    if strcmp(fields{i},'temp_time')|strcmp(fields{i},'surf_temp')|strcmp(fields{i},'bott_temp')
        SpotData.(fields{i}) = SpotData.(fields{i})(idx_t,:); 
    else
        SpotData.(fields{i}) = SpotData.(fields{i})(idx,:);
    end
end

%qaqc and archive
[data] = qaqc_bulkparams_realtime_website(buoy_info, archive_data, SpotData);                        

%save data to different formats        
realtime_archive_mat(buoy_info, data);
realtime_backup_mat(buoy_info, data);
realtime_archive_text(buoy_info, data, size(SpotData.time,1)); 
