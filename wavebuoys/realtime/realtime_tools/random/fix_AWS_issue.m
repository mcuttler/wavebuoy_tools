clear; clc

%buoy type and deployment info number and deployment info 
clear; clc

%location of wavebuoy_tools repo
% buoycodes = 'C:\Data\wavebuoy_tools\wavebuoys'; 
% addpath(genpath(buoycodes))

%buoy type and deployment info number and deployment info 
buoy_info.type = 'sofar'; 
buoy_info.serial = 'SPOT-1034'; %spotter serial number, or just Datawell 
buoy_info.name = 'ClerkeReef'; 
buoy_info.datawell_name = 'nan'; 
buoy_info.version = 'smart_mooring'; %V1, V2, smart_mooring, Datawell, Triaxys
buoy_info.sofar_token = 'a1b3c0dbaa16bb21d5f0befcbcca51'; 
buoy_info.utc_offset = 8; 
buoy_info.DeployLoc = 'ClerkeReef';
buoy_info.DeployDepth = 26; 
buoy_info.DeployLat = -17.30585; 
buoy_info.DeployLon = 119.31218; 
buoy_info.UpdateTime =  1; %hours
buoy_info.DataType = 'parameters'; %can be parameters if only bulk parameters, or spectral for including spectral coefficients
buoy_info.archive_path = 'E:\wawaves';
buoy_info.backup_path = '\\drive.irds.uwa.edu.au\OGS-COD-001\CUTTLER_wawaves\Data\realtime_archive_backup'; 
buoy_info.datawell_datapath = 'E:\waved'; %top level directory for Datawell CSVs

%% get historical data 
limit = 100; 
modify_smart_mooring_archive; 
% [SpotData] = Get_Spoondrift_Data_realtime(buoy_info, limit);  

clear data dum endDate fields header i idx idxt idxw j jj m n options qaqc r resp_sensor...
    resp_waves start_time startDate status tend tstart uri_sensor uri_waves bulkparams Spotter
%% or define time period
% t1 = datenum(2021,5,1);
% tend = ceil(datenum(now)); 
% 
% for i = t1:tend-1
%     startDatewaves = datestr(i,'yyyy-mm-ddTHH:MM:SS'); 
%     endDatewaves = datestr(i+0.9993,'yyyy-mm-ddTHH:MM:SS'); 
%     startDatewaves = [startDatewaves 'Z']; 
%     endDatewaves = [endDatewaves 'Z']; 
%         
%     [Spotter,flag] = Get_Spoondrift_SmartMooring_time_period(buoy_info, startDatewaves, endDatewaves);
%     if i == t1
%         SpotData = Spotter; 
%     else
%         fields = fieldnames(SpotData); 
%         for j = 1:length(fields)
%             SpotData.(fields{j}) = [SpotData.(fields{j}); Spotter.(fields{j})]; 
%         end
%     end        
% end
% idxt = find(SpotData.temp_time>=t1); 
% idxw = find(SpotData.time>=t1); 
% fields = fieldnames(SpotData); 
% for j = 1:length(fields)
%     if strcmp(fields{j},'temp_time')|strcmp(fields{j},'surf_temp')|strcmp(fields{j},'bott_temp')
%         SpotData.(fields{j}) = SpotData.(fields{j})(idxt);
%     else
%         SpotData.(fields{j}) = SpotData.(fields{j})(idxw);
%     end
% end
% 
SpotData = remove_duplicates(SpotData); 
%% quality control for linking with archive 
bulkparams = SpotData; 
%bulkparams data 
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
qaqc.rocTp = 8; 
qaqc.TpLim = 25; 
qaqc.rocSST = 2; 

if isfield(qaqc, 'time_temp')
    [bulkparams.qf_waves, bulkparams.qf_sst, bulkparams.qf_bott_temp] = qaqc_uwa_waves_website(qaqc); 
else
    [bulkparams.qf_waves, ~, ~] = qaqc_uwa_waves_website(qaqc);
end
SpotData = bulkparams;     
% 


%% load from backup_path 
archive = load(fullfile(buoy_info.backup_path,buoy_info.name,'mat_archive','2021',[buoy_info.name '_202105.mat'])); 
if ~isfield(archive.SpotData,'name')
    for i = 1:length(archive.SpotData.time)
        archive.SpotData.name{i,1} = buoy_info.name; 
    end
end

%% join the two archives
if size(SpotData.name,1)~=size(SpotData.time,1)
    for i = 1:size(SpotData.time)
        SpotData.name{i,1} = buoy_info.name;
    end
end

idxw = find(SpotData.time>archive.SpotData.time(end)); 
if isfield(SpotData,'temp_time')
    idxt = find(SpotData.temp_time>archive.SpotData.temp_time(end)); 
end
fields = fieldnames(SpotData); 
for j = 1:length(fields)
    if strcmp(fields{j},'temp_time')|strcmp(fields{j},'surf_temp')|strcmp(fields{j},'bott_temp')|strcmp(fields{j},'qf_sst')|strcmp(fields{j},'qf_bott_temp')        
        archive.SpotData.(fields{j}) = [archive.SpotData.(fields{j});SpotData.(fields{j})(idxt)]; 
    else
        archive.SpotData.(fields{j}) = [archive.SpotData.(fields{j});SpotData.(fields{j})(idxw)];
    end
end

%% save
data = archive.SpotData; 

%save data to different formats        
realtime_archive_mat(buoy_info, data);
realtime_backup_mat(buoy_info, data);
realtime_archive_text(buoy_info, data, length(idxw));         
update_website_buoy_info(buoy_info, data); 



