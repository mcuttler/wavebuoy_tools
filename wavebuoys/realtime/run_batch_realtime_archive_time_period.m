%% run batch process

% tic

clear; clc;
%add wavebuoy_tools to path 
addpath(genpath('C:\Data\wavebuoy_tools')); 

%suppress warnings
warning('off')

%read in metadata for buoys to run
dpath = 'Y:\CUTTLER_wawaves\Data\vicwaves'; 
dname = 'vicwaves_backfill.csv'; 

buoy_metadata_master = readtable(fullfile(dpath,dname),'VariableNamingRule','preserve'); 

%get data by site
sites = unique(buoy_metadata_master.name); 
%%
for dd = 1:size(sites,1)            
        buoy_metadata = buoy_metadata_master(strcmp(buoy_metadata_master.name,sites{dd}),:); 
        
        yrs = 2018:2025; 
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
                    
                    if isstruct(data)
                        fields = fieldnames(SpotData); 
                        for mm = 1:length(fields)
                            if contains(fields{mm},'1') | contains(fields{mm},'2') | contains(fields{mm},'freq') | contains(fields{mm},'direction') | contains(fields{mm},'variance') | contains(fields{mm},'df')
                                %check size of columns
                                dc = size(data.(fields{mm}),2); ds = size(SpotData.(fields{mm}),2);                                     
                                if dc < ds
                                    data.(fields{mm})(:,end+1:size(SpotData.(fields{mm}),2)) = nan; 
                                elseif ds < dc
                                    SpotData.(fields{mm})(:,end+1:size(data.(fields{mm}),2)) = nan;  
                                end                                                                                                                                     
                            end
                            
                            data.(fields{mm}) = [data.(fields{mm}); SpotData.(fields{mm})]; 
                        end                        
                    else
                        data = SpotData;                          
                    end    
                catch
                    disp(['no data for: ' datestr(tloop(kk))]); 
                end
            end    
            % clear tstart_master tend_master tloop 
        end
        
         if ~isempty(data)
             for i = 1:size(data.time,1)
                 data.name{i,1} = buoy_info.name; 
             end             
             
             disp(['qaqc data']);         
             [data] = qaqc_bulkparams_realtime_website(buoy_info, data, SpotData);   
             
             disp(['archiving mat files']);      
             if ~isfield(data,'systime')
                 data.systime = data.time; 
                 data.batteryVoltage = ones(size(data.hsig,1),1).*nan; 
                 data.batteryPower = ones(size(data.hsig,1),1).*nan; 
                 data.humidity = ones(size(data.hsig,1),1).*nan; 
                 data.solarVoltage = ones(size(data.hsig,1),1).*nan; 
             end
             realtime_archive_mat(buoy_info, data);          
             
             disp(['archiving text files']); 
             realtime_archive_text(buoy_info, data, size(data.time,1)); 
         end
        
        clear data buoy_metadata SpotData
end


% toc
        
%%




   
 





