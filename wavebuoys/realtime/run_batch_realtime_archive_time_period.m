%% run batch process

tic

clear; clc;
%add wavebuoy_tools to path 
addpath(genpath('D:\CUTTLER_GitHub\wavebuoy_tools')); 

%suppress warnings
warning('off')

%read in metadata for buoys to run
dpath = 'X:\CUTTLER_wawaves\Data\wawaves'; 
dname = 'wawaves_buoy_log_metadata.csv'; 

buoy_metadata_master = readtable(fullfile(dpath,dname),'VariableNamingRule','preserve'); 

%get data by site
sites = unique(buoy_metadata_master.name); 

for dd = 1:size(sites,1)            
        buoy_metadata = buoy_metadata_master(strcmp(buoy_metadata_master.name,sites{dd}),:); 
        
        yrs = 2019:2025; 
        for yy = 1:length(yrs)
            if ~isfolder(fullfile(buoy_metadata.archive_path{1}, sites{dd},'mat_archive', num2str(yrs(yy))))
                mkdir(fullfile(buoy_metadata.archive_path{1}, sites{dd},'mat_archive', num2str(yrs(yy)))); 
            end
            
            if ~isfolder(fullfile(buoy_metadata.web_path{1}, sites{dd},'text_archive', num2str(yrs(yy))))
                mkdir(fullfile(buoy_metadata.web_path{1}, sites{dd},'text_archive', num2str(yrs(yy)))); 
            end
        end
        %run the realtime workflow 
        % disp(['running ' sites{dd}]); 
        
        
        data = []; 
        
        for jj = 1:size(buoy_metadata,1)
            %build buoy info from metadata
            buoy_info_fields = buoy_metadata.Properties.VariableNames; 
            for kk = 1:length(buoy_info_fields)
                if iscell(buoy_metadata.(buoy_info_fields{kk}))
                    buoy_info.(buoy_info_fields{kk}) = buoy_metadata.(buoy_info_fields{kk}){jj};
                else
                    buoy_info.(buoy_info_fields{kk}) = buoy_metadata.(buoy_info_fields{kk})(jj);  
                end
            end       
            
            %set start/end date for data grab
            tstart_master = datenum(buoy_info.DeployDate); 
            tend_master = datenum(buoy_info.RetrieveDate); 
            tloop = tstart_master:1:tend_master;    
            
            %loop over every date 
            for kk = 1:length(tloop)-1
                try
                    disp(['fetching data for: ' sites{dd} '-' datestr(tloop(kk))]); 
                    [SpotData] = get_sofar_realtime_time_period(buoy_info,tloop(kk), tloop(kk+1));
                    for i = 1:size(SpotData.time,1)
                        SpotData.name{i,1} = buoy_info.name; 
                    end               
                    
                    if isstruct(data)
                        fields = fieldnames(SpotData); 
                        for mm = 1:length(fields)
                            data.(fields{mm}) = [data.(fields{mm}); SpotData.(fields{mm})]; 
                        end
                        clear SpotData; 
                    else
                        data = SpotData; 
                        clear SpotData; 
                    end                        
                catch
                    disp(['no data for: ' datestr(tloop(kk))]); 
                end
            end    
            clear tstart_master tend_master tloop buoy_info
        end

        disp(['qaqc data']); 
        [data] = qaqc_bulkparams_realtime_website(buoy_info, data, SpotData);   

        disp(['archiving mat files']); 
        realtime_archive_mat(buoy_info, data);          

        disp(['archiving text files']); 
        realtime_archive_text(buoy_info, data, size(data.time,1)); 
        
        clear data buoy_metadata  
end


toc
        
%%




   
 





