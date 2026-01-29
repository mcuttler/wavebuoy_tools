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
for jj = 13:size(buoy_metadata)
    %build buoy info from metadata
    buoy_info_fields = buoy_metadata.Properties.VariableNames; 
    for kk = 1:length(buoy_info_fields)
        if iscell(buoy_metadata.(buoy_info_fields{kk}))
            buoy_info.(buoy_info_fields{kk}) = buoy_metadata.(buoy_info_fields{kk}){jj};
        else
            buoy_info.(buoy_info_fields{kk}) = buoy_metadata.(buoy_info_fields{kk})(jj);  
        end
    end
    
    buoy_info.backfill_start = datetime(buoy_info.backfill_start,'InputFormat','dd-MM-uuuu'); 
    % buoy_info.backfill_start = datetime(2025,7,12); 
    buoy_info.backfill_end = datetime(buoy_info.backfill_end,'InputFormat','dd-MM-uuuu');         
    

    %run the realtime workflow 
    disp(['running ' buoy_info.name]); %comment out when running for real 

    %if need to retrieve missing data (i.e., data for time period doesn't
    %exist)
    if buoy_info.get_missing_data==1 & buoy_info.text_archive_backfill==1
        %set start/end date for data grab
        tstart_master = datenum(buoy_info.backfill_start); 
        tend_master = datenum(buoy_info.backfill_end); 
        tloop = tstart_master:1:tend_master;    
        
        %loop over every date     
        data = []; 
        for kk = 1:length(tloop)-1
            try
                disp(['fetching data for: ' buoy_info.name '-' datestr(tloop(kk))]); 
                [SpotData] = get_sofar_realtime_time_period(buoy_info,tloop(kk), tloop(kk+1));        
                
                if isstruct(data)
                    fields = fieldnames(SpotData); 
                    for mm = 1:length(fields)
                        if contains(fields{mm},'1') | contains(fields{mm},'2') | contains(fields{mm},'freq') | contains(fields{mm},'direction') | contains(fields{mm},'variance') | contains(fields{mm},'df')
                            % check size of columns
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

        if ~isempty(data)        
            for kk = 1:size(data.time,1)
                data.name{kk,1} = buoy_info.name; 
            end
            
            %merge with existing data
            %load most recent data - could be customised to load more specific time period
            [archive_data] = load_archived_data(buoy_info);        
            fields = fieldnames(archive_data); 
            for mm = 1:length(fields)
                if contains(fields{mm},'qf')
                    archive_data = rmfield(archive_data,fields{mm});
                end
            end
            fields = fieldnames(archive_data); 
            
            for mm = 1:length(fields)
                
                if contains(fields{mm},'1') | contains(fields{mm},'2') | contains(fields{mm},'freq') | contains(fields{mm},'direction') | contains(fields{mm},'variance') | contains(fields{mm},'df')
                    % check size of columns
                    dc = size(archive_data.(fields{mm}),2); ds = size(data.(fields{mm}),2);                                     
                    if dc < ds
                        archive_data.(fields{mm})(:,end+1:size(data.(fields{mm}),2)) = nan; 
                    elseif ds < dc
                        data.(fields{mm})(:,end+1:size(archive_data.(fields{mm}),2)) = nan;  
                    end  
                end
                
                archive_data.(fields{mm}) = [archive_data.(fields{mm}); data.(fields{mm})];
            end                        
            
            %sort by time
            [archive_data.time, idx_w] = sort(archive_data.time); 
            [archive_data.temp_time, idx_t] = sort(archive_data.temp_time);             
            [archive_data.press_time, idx_press] = sort(archive_data.press_time); 
            [archive_data.press_std_time, idx_press_std] = sort(archive_data.press_std_time); 
            [archive_data.spec_time, idx_spec] = sort(archive_data.spec_time); 
            [archive_data.part_time, idx_part] = sort(archive_data.part_time); 
            [archive_data.systime, idx_sys] = sort(archive_data.systime); 
            [archive_data.curr_time, idx_curr] = sort(archive_data.curr_time); 
            
            fields = fieldnames(archive_data);
            for j = 1:length(fields)              
                if strcmp(fields{j},'qf_bott_temp') |strcmp(fields{j},'qf_sst') |strcmp(fields{j},'surf_temp') | strcmp(fields{j},'bott_temp')| strcmp(fields{j},'w') | strcmp(fields{j},'w_std')               
                    archive_data.(fields{j})=archive_data.(fields{j})(idx_t,:); 
                elseif contains(fields{j},'curr')
                    if strcmp(buoy_info.type,'datawell')
                        archive_data.(fields{j}) = archive_data.(fields{j})(idx_t,:); 
                    else
                        archive_data.(fields{j}) = archive_data.(fields{j})(idx_curr,:); 
                    end
                    
                elseif strcmp(fields{j},'pressure_std')
                    archive_data.(fields{j}) = archive_data.(fields{j})(idx_press_std,:); 
                    
                elseif strcmp(fields{j},'pressure')
                    archive_data.(fields{j}) = archive_data.(fields{j})(idx_press,:);  
                    
                elseif strcmp(fields{j},'a1')|strcmp(fields{j},'a2')|strcmp(fields{j},'b1')|...
                        strcmp(fields{j},'b2')|strcmp(fields{j},'direction')|strcmp(fields{j},'directionalSpread')|...
                        strcmp(fields{j},'frequency')|strcmp(fields{j},'varianceDensity')|strcmp(fields{j},'df')
                    if strcmp(buoy_info.type,'datawell')
                        if strcmp(fields{j},'frequency')
                            archive_data.(fields{j}) = archive_data.(fields{j}); 
                        else
                            archive_data.(fields{j}) = archive_data.(fields{j})(idx_w,:);
                        end                        
                    else
                        archive_data.(fields{j}) = archive_data.(fields{j})(idx_spec,:);
                    end
                    
                elseif (contains(fields{j},'sea')&&~contains(fields{j},'wind'))||contains(fields{j},'swell')
                    archive_data.(fields{j}) = archive_data.(fields{j})(idx_part,:);  
                    
                elseif contains(fields{j},'battery')||strcmp(fields{j},'humidity')||contains(fields{j},'solar')||strcmp(fields{j},'systime')
                    archive_data.(fields{j}) = archive_data.(fields{j})(idx_sys,:);
                elseif contains(fields{j},'time')
                    continue
                else
                    archive_data.(fields{j})=archive_data.(fields{j})(idx_w);                
                end
            end        
            
            %run qaqc
            [data] = qaqc_bulkparams_realtime_website(buoy_info, archive_data, archive_data);
            
            %save new mat files
            [check] = check_archive_path(buoy_info, data);
            realtime_archive_mat(buoy_info, data);
            realtime_backup_mat(buoy_info, data);
            
            clear archive_data fields ff mm dc ds dt idx_curr idx_part idx_press idx_press_std idx_spec idx_sys idx_t idx_w j kk SpotData tend_master tloop tstart_master
        end
        
    elseif buoy_info.get_missing_data==0 & buoy_info.text_archive_backfill==1
        %load most recent data - could be customised to load more specific time period
        [data] = load_archived_data(buoy_info);  
    end
    
    if ~isempty(data)
        %index data for backfill dates
        dt = datetime(data.time,'convertfrom','datenum'); 
        ind = find(dt>=buoy_info.backfill_start & dt<buoy_info.backfill_end);    
        
        %write text files and copy to aws
        if ~isempty(ind)
            realtime_archive_text(buoy_info, data, ind);
        end
    end
    
    clear buoy_info data dt ind 
end


