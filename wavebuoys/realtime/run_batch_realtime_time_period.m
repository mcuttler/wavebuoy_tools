%% run batch process

%add wavebuoy_tools to path 
addpath(genpath('D:\CUTTLER_GitHub\wavebuoy_tools')); 

%suppress warnings
warning('off')

%read in metadata for buoys to run
dpath = 'G:\wawaves'; 
dname = 'buoys_metadata.csv'; 

buoy_metadata = readtable(fullfile(dpath,dname),'VariableNamingRule','preserve'); 

%set start/end date for data grab
tstart_master = datenum(2024,12,1,0,0,0); 
tend_master = datenum(2025,1,1,0,0,0);  
tloop = tstart_master:1:tend_master;

% loop over buoys and execute 
for jj = 1:size(buoy_metadata)
    %build buoy info from metadata
    buoy_info_fields = buoy_metadata.Properties.VariableNames; 
    for kk = 1:length(buoy_info_fields)
        if iscell(buoy_metadata.(buoy_info_fields{kk}))
            buoy_info.(buoy_info_fields{kk}) = buoy_metadata.(buoy_info_fields{kk}){jj};
        else
            buoy_info.(buoy_info_fields{kk}) = buoy_metadata.(buoy_info_fields{kk})(jj);  
        end
    end
    
    %run the realtime workflow 
    disp(['running ' buoy_info.name]); %comment out when running for real 

    %loop over every date 
    for kk = 1:length(tloop)-1
        [SpotData] = get_sofar_realtime_time_period(buoy_info,tloop(kk), tloop(kk+1));
        for i = 1:size(SpotData.time,1)
            SpotData.name{i,1} = buoy_info.name; 
        end

        if kk ==1
            data = SpotData; 
        else
            fields = fieldnames(SpotData); 
            for mm = 1:length(fields)
                data.(fields{mm}) = [data.(fields{mm}); SpotData.(fields{mm})]; 
            end
        end            
    end    
    
    [data] = qaqc_bulkparams_realtime_website(buoy_info, data, SpotData);   
    realtime_archive_mat(buoy_info, data);
    realtime_backup_mat(buoy_info, data);            

    clear buoy_info 
end


