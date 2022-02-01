%% run merge existing archives
clear; clc; 

buoy_info.type = 'sofar'; 
buoy_info.serial = 'SPOT-0170'; %spotter serial number, or just Datawell 
buoy_info.name = 'BremerCanyon_Drifting'; 
buoy_info.datawell_name = 'nan'; 
buoy_info.version = 'V1'; %or DWR4 for Datawell, for example
buoy_info.sofar_token = 'e0eb70b6d9e0b5e00450929139ea34'; 
buoy_info.utc_offset = 8; 
buoy_info.DeployLoc = 'BremerCanyon';
buoy_info.DeployDepth = 0; 
buoy_info.DeployLat = 0; 
buoy_info.DeployLon = 0; 
buoy_info.UpdateTime =  1; %hours
buoy_info.DataType = 'spectral'; %can be parameters if only bulk parameters, or spectral for including spectral coefficients
buoy_info.archive_path = 'F:\wawaves';
buoy_info.backup_path = '\\drive.irds.uwa.edu.au\OGS-COD-001\CUTTLER_wawaves\Data\realtime_archive_backup'; 
buoy_info.datawell_datapath = 'E:\waved'; %top level directory for Datawell CSVs


%%
[merged_data, original_data, current_data] = merge_existing_Spotter_archives(buoy_info); 


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
qaqc.MINWH = 0.05;
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
qaqc.rocSST = 1; 

if isfield(qaqc, 'time_temp')
    [bulkparams.qf_waves, bulkparams.qf_sst, bulkparams.qf_bott_temp] = qaqc_uwa_waves_website(qaqc); 
else
    [bulkparams.qf_waves, ~, ~] = qaqc_uwa_waves_website(qaqc);
end

%% update archive
dataout = bulkparams; 
% save(['F:\Data\wawave_temp\' buoy_info.name '_archive.mat'],'dataout','-v7.3'); 

dv_wave = datevec(dataout.time); 
if isfield(dataout,'temp_time'); 
    dv_temp = datevec(dataout.temp_time); 
end

if isfield(dataout,'spec_time'); 
    dv_spec = datevec(dataout.spec_time); 
end

mths = unique(dv_wave(:,1:2),'rows');
%remove archive text file 
% rmdir([buoy_info.archive_path '\' buoy_info.name  '\text_archive'],'s'); 
for i = 1:size(mths,1)
    disp([buoy_info.name ' ' num2str(mths(i,1)) ' ' num2str(mths(i,2))]); 
    idx_wave = find(dv_wave(:,1)==mths(i,1)&dv_wave(:,2)==mths(i,2)); 
    if isfield(dataout,'temp_time')
        idx_temp = find(dv_temp(:,1)==mths(i,1)&dv_temp(:,2)==mths(i,2)); 
    end
    
    if isfield(dataout,'spec_time')
        idx_spec = find(dv_spec(:,1)==mths(i,1)&dv_spec(:,2)==mths(i,2)); 
    end
    %parse data for export and textfile writing
    fields = fieldnames(dataout); 
    monthly_data = dataout; 
    for j = 1:length(fields); 
        if strcmp(fields{j},'temp_time')|strcmp(fields{j},'surf_temp')|strcmp(fields{j},'bott_temp')|strcmp(fields{j},'qf_sst')|strcmp(fields{j},'qf_bott_temp')
            monthly_data.(fields{j}) = dataout.(fields{j})(idx_temp); 
        elseif strcmp(fields{j},'a1')|strcmp(fields{j},'a2')|strcmp(fields{j},'b1')|strcmp(fields{j},'b2')|strcmp(fields{j},'varianceDensity')|strcmp(fields{j},'frequency')|strcmp(fields{j},'df')|strcmp(fields{j},'directionalSpread')|strcmp(fields{j},'direction')|strcmp(fields{j},'spec_time')
            monthly_data.(fields{j}) = dataout.(fields{j})(idx_spec,:); 
        else
            monthly_data.(fields{j}) = dataout.(fields{j})(idx_wave); 
        end
    end
    for j = 1:size(monthly_data.time,1)
        monthly_data.serialID{j,1}= buoy_info.serial; 
        monthly_data.name{j,1} = buoy_info.name; 
    end    
    buoy_info.archive_path = 'F:\wawaves_test'; 
    [check] = check_archive_path(buoy_info.archive_path, buoy_info, monthly_data);  
    realtime_archive_mat(buoy_info, monthly_data);
    realtime_backup_mat(buoy_info, monthly_data);
%     realtime_archive_text(buoy_info, monthly_data, 0); 
clear idx_wave idx_temp idx_spec

end
    
    

    




