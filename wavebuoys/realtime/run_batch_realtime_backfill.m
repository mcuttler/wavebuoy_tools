%% run batch process

%add wavebuoy_tools to path 

addpath(genpath('D:\CUTTLER_GitHub\wavebuoy_tools'));  

%suppress warnings
warning('off')

%read in metadata for buoys to run
dpath = '\\drive.irds.uwa.edu.au\OGS-COD-001\CUTTLER_wawaves\Data\website\auswaves'; 
dname = 'auswaves_backfill.csv'; 

buoy_metadata = readtable(fullfile(dpath,dname),'VariableNamingRule','preserve'); 

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
    
    % buoy_info.backfill_start = datetime(buoy_info.backfill_start,'InputFormat','dd-MM-uuuu'); 
    buoy_info.backfill_start = datetime(2025,7,12); 
    buoy_info.backfill_end = datetime(buoy_info.backfill_end,'InputFormat','dd-MM-uuuu');         
    
    %run the realtime workflow 
    disp(['running ' buoy_info.name]); %comment out when running for real 

    %load most recent data - could be customised to load more specific time period
    [data] = load_archived_data(buoy_info);  

    %index data for backfill dates
    dt = datetime(data.time,'convertfrom','datenum'); 
    ind = find(dt>=buoy_info.backfill_start & dt<buoy_info.backfill_end); 
    
    %write text files and copy to aws
    realtime_archive_text(buoy_info, data, ind);
    
    clear buoy_info data dt  ind 
end


