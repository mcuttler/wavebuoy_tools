%% run batch process

%read in metadata for buoys to run
dpath = 'C:\Users\00084142\CUTTLER_GitHub\wavebuoy_tools\wavebuoys\realtime'; 
dname = 'buoys_metadata.csv'; 

buoy_metadata = readtable(fullfile(dpath,dname),'VariableNamingRule','preserve'); 

%create log file for this run
log_path = dpath; %modify this in future `
log_name = ['buoys_log_file_' datestr(now,'yyyymmdd_HHMMSS') '.log']; 
fid = fopen(fullfile(log_path,log_name),'a'); 

% loop over buoys and execute 
for jj = 1:size(buoy_metadata)
    %build buoy info from metadata
    buoy_info_fields = buoy_metadata.Properties.VariableNames; 
    for kk = 1:length(buoy_info_fields)
        if iscell(buoy_metadata.(buoy_info_fields{kk}))
            buoy_info.(buoy_info_fields{kk}) = buoy_metadata.(buoy_info_fields{kk}){jj};
        else
            buoy_info.(buoy_info_fields{kk}) = buoy_metadata.(buoy_info_fields{kk}); 
        end
    end
    
    %run the realtime workflow 
    try
        batch_realtime(buoy_info); 
    catch
        %add message to log if a buoy fails 
        fprintf(fid, [buoy_info.name ' could not be completed \n']); 
    end
end

fclose(fid);
