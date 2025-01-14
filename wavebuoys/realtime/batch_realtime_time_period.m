%%  Process wave buoys (real time) for display on wawaves.org


function [log_message] = batch_realtime_time_period(buoy_info)

%initiate empty log message
log_message = []; 
%% Sofar - Spotters and Smart Moorings 
if strcmp(buoy_info.type,'sofar')==1     
    
    %get buoy data
    try
        limit = buoy_info.UpdateTime*2; %not used in v2 code
        [SpotData] = get_sofar_realtime(buoy_info, limit);         
        flag = 1;                                
    catch
        [warning] = spotter_get_data_fail_warning(buoy_info);
        flag = 0; 
        log_message = [log_message,' (1) code failed on getting Spotter data - no new data or wrong API token'];
    end                            
    

    if flag == 1
        %only keep last 2 two observations 
        fields = fieldnames(SpotData); 
        for k = 1:length(fields)
            SpotData.(fields{k}) = SpotData.(fields{k})(end-1:end,:);
        end
        

        for i = 1:size(SpotData.time,1)
            SpotData.name{i,1} = buoy_info.name; 
        end
        
        %load in any existing data for this site and combine with new
        %measurements, then QAQC
        try
            [check] = check_archive_path(buoy_info, SpotData);    
            if buoy_info.send_alert_emails==1
                [warning] = spotter_buoy_search_radius_and_alert(buoy_info, SpotData);
            end
        catch
            log_message = [log_message,' (2) code failed on check or warning']; 
        end
        
        %check>0 means that directory already exists (and monthly file should
        %exist); otherwise, this is the first data for this location 
        
        if all(check)~=0        
            %load archived data
            try
                [archive_data] = load_archived_data(buoy_info);  
            catch
                log_message = [log_message,' (3) code failed loading archive data']; 
            end
            
            %add serial ID and name if not already there
            if ~isfield(archive_data,'serialID')
                for i = 1:size(archive_data.time,1)
                    archive_data.serialID{i,1} = buoy_info.serial;
                end
            end
            if ~isfield(archive_data,'name')
                for i = 1:size(archive_data.time,1)
                    archive_data.name{i,1} = buoy_info.name;
                end
            end   
            
            %get most recent data for all variable types 
            try
                idx_w = find(SpotData.time>archive_data.time(end)); 
                idx_t = find(SpotData.temp_time>archive_data.temp_time(end));             
                
                %add pressure data
                if isfield(SpotData,'press_time') & isfield(archive_data,'press_time')
                    idx_p = find(SpotData.press_time>archive_data.press_time(end)); 
                    idx_pstd = find(SpotData.press_std_time>archive_data.press_std_time(end));       
                elseif isfield(SpotData,'press_time') & ~isfield(archive_data,'press_time')
                    idx_p = [1:length(SpotData.press_time)]'; 
                    idx_pstd = [1:length(SpotData.press_std_time)]';
                else
                    idx_p = [];
                    idx_pstd = [];
                end
                
                %add spectral data if it exists in archive
                if isfield(SpotData,'spec_time') & isfield(archive_data,'spec_time')
                    idx_s = find(SpotData.spec_time>archive_data.spec_time(end));
                elseif isfield(SpotData,'spec_time') & ~isfield(archive_data,'spec_time'); 
                    idx_s = [1:length(SpotData.spec_time)]';
                else
                    idx_s = [];
                end
                
                %add spectral data if it exists in archive
                if isfield(SpotData,'part_time') & isfield(archive_data,'part_time')
                    idx_part = find(SpotData.part_time>archive_data.part_time(end));
                elseif isfield(SpotData,'part_time') & ~isfield(archive_data,'part_time')
                    idx_part = [1:length(SpotData.part_time)]';           
                else
                    idx_part = [];
                end
            catch
                log_message = [log_message, ' (4) code failed on indexing SpotData for new data']; 
            end
            
            if ~isempty(idx_w)&~isempty(idx_t)
                try
                    ff = fieldnames(SpotData); 
                    for f = 1:length(ff)
                        if strcmp(ff{f},'temp_time')|strcmp(ff{f},'surf_temp')|strcmp(ff{f},'bott_temp')
                            SpotData.(ff{f}) = SpotData.(ff{f})(idx_t,:); 
                        elseif strcmp(ff{f},'press_time')|strcmp(ff{f},'pressure')
                            SpotData.(ff{f}) = SpotData.(ff{f})(idx_p,:); 
                        elseif strcmp(ff{f},'press_std_time')|strcmp(ff{f},'pressure_std')
                            SpotData.(ff{f}) = SpotData.(ff{f})(idx_pstd,:); 
                        elseif (contains(ff{f},'swell')|contains(ff{f},'sea')|strcmp(ff{f},'part_time'))&~strcmp(ff{f},'wind_seasurfaceId')
                            SpotData.(ff{f}) = SpotData.(ff{f})(idx_part,:); 
                        elseif strcmp(ff{f},'spec_time')|size(SpotData.(ff{f}),2)>1
                            SpotData.(ff{f}) = SpotData.(ff{f})(idx_s,:); 
                        else
                            SpotData.(ff{f}) = SpotData.(ff{f})(idx_w,:);
                        end
                    end
                    clear ff idx_w idx_t f idx_p idx_pstd
                catch
                    log_message = [log_message, ' (5) code failed on cleaning up SpotData for new data']; 
                end                
                    
                %check that it's new data
                if SpotData.time(1)>archive_data.time(end)
                    %perform some QA/QC --- QARTOD 19 and QARTOD 20        
                    try
                        [data] = qaqc_bulkparams_realtime_website(buoy_info, archive_data, SpotData);                        
                    catch
                        log_message = [log_message, ' (6) code failed on running QAQC']; 
                    end
                
                    %save data to different formats 
                    try
                        realtime_archive_mat(buoy_info, data);
                        realtime_backup_mat(buoy_info, data);                        
                        realtime_archive_text(buoy_info, data, size(SpotData.time,1)); 
                    catch
                        log_message = [log_message, ' (7) code failed on archiving or writing text file'];
                    end
                    
                    
                    %output MEM and SST plots --- only most recent time point                     
                    if strcmp(buoy_info.DataType,'spectral')                        
                        try
                            [NS, NE, ndirec] = lygre_krogstad(SpotData.a1(end,:),SpotData.a2(end,:),SpotData.b1(end,:),...
                                SpotData.b2(end,:),SpotData.varianceDensity(end,:));
                            make_MEM_plot(ndirec, SpotData.frequency(end,:), NE, SpotData.hsig(end,1),...
                                SpotData.tp(end,1), SpotData.dp(end,1), SpotData.time(end,1), buoy_info)        
                        catch
                            log_message = [log_message, ' (8) code failed on making MEM'];
                        end                        
                    end
                    
                    %code to update the buoy info master file for website to read
                    try
                        update_website_buoy_info(buoy_info, data); 
                    catch
                        log_message = [log_message, ' (9) code failed on updating buoys.csv']; 
                    end                    
                end
            end
        else
            SpotData.qf_waves = ones(size(SpotData.time,1),1).*4;
            if isfield(SpotData,'temp_time')
                SpotData.qf_sst = ones(size(SpotData.temp_time,1),1).*4; 
                SpotData.qf_bott_temp = ones(size(SpotData.temp_time,1),1).*4;                 
            end
            
            try
                realtime_archive_mat(buoy_info, SpotData);
                realtime_backup_mat(buoy_info, SpotData);
                realtime_archive_text(buoy_info, SpotData, size(SpotData.time,1)); 
            catch
                log_message = [log_message, ' (7) code failed on archiving or writing text file'];
            end
                        
            %output MEM and SST plots 
            if strcmp(buoy_info.DataType,'spectral')        
                try
                    [NS, NE, ndirec] = lygre_krogstad(SpotData.a1(end,:),SpotData.a2(end,:),SpotData.b1(end,:),...
                        SpotData.b2(end,:),SpotData.varianceDensity(end,:));
                    make_MEM_plot(ndirec, SpotData.frequency(end,:), NE, SpotData.hsig(end,1),...                        
                    SpotData.tp(end,1), SpotData.dp(end,1), SpotData.time(end,1), buoy_info)      
                catch
                    log_message = [log_message, ' (8) code failed on making MEM'];
                end
            end
            
            %code to update the buoy info master file for website to read
            try
                update_website_buoy_info(buoy_info, SpotData); 
            catch
                log_message = [log_message, ' (9) code failed on updating buoys.csv']; 
            end
        end        
    end     
    
 %% Datawell DWR4 
elseif strcmp(buoy_info.type,'datawell')==1
    %check buoy position and send email if out of search radius
    [warning] = buoy_search_radius_and_alert(buoy_info);     
    
    data.time = datenum(now);   
    data.tnow = datevec(data.time); 
  
    data.file20 = [buoy_info.datawell_datapath '\' buoy_info.datawell_name '\' num2str(data.tnow(1)) '\' num2str(data.tnow(2),'%02d') '\' buoy_info.datawell_name '{0xF20}' num2str(data.tnow(1)) '-' num2str(data.tnow(2),'%02d') '.csv'];
    data.file21 = [buoy_info.datawell_datapath '\' buoy_info.datawell_name '\' num2str(data.tnow(1)) '\' num2str(data.tnow(2),'%02d') '\' buoy_info.datawell_name '{0xF21}' num2str(data.tnow(1)) '-' num2str(data.tnow(2),'%02d') '.csv'];
    data.file25 = [buoy_info.datawell_datapath '\' buoy_info.datawell_name '\' num2str(data.tnow(1)) '\' num2str(data.tnow(2),'%02d') '\' buoy_info.datawell_name '{0xF25}' num2str(data.tnow(1)) '-' num2str(data.tnow(2),'%02d') '.csv'];
    data.file28 = [buoy_info.datawell_datapath '\' buoy_info.datawell_name '\' num2str(data.tnow(1)) '\' num2str(data.tnow(2),'%02d') '\' buoy_info.datawell_name '{0xF28}' num2str(data.tnow(1)) '-' num2str(data.tnow(2),'%02d') '.csv'];
    data.file82 = [buoy_info.datawell_datapath '\' buoy_info.datawell_name '\' num2str(data.tnow(1)) '\' num2str(data.tnow(2),'%02d') '\' buoy_info.datawell_name '{0xF82}' num2str(data.tnow(1)) '-' num2str(data.tnow(2),'%02d') '.csv'];    
    
    %original code for Datawell buoys does all checking of directories and
    %grabbing archived data
    try
        [dw_data, archive_data,check] = Process_Datawell_realtime_website(buoy_info, data, data.file20, data.file21, data.file25, data.file28, data.file82);
    catch
        log_message = [log_message, ' (1) code failed on getting Datawell data']; 
    end        
    clear data;       
    
    [check] = check_archive_path(buoy_info, dw_data);   
    
    %add Spotter and Smart Mooring fields
    dd = ones(size(dw_data.time,1),1).*-9999; 
    dw_data.dm_sea = dd; 
    dw_data.dm_swell = dd; 
    dw_data.dmspr_sea = dd; 
    dw_data.dmspr_swell = dd; 
    dw_data.endFreq_sea = dd; 
    dw_data.endFreq_swell = dd; 
    dw_data.hsig_sea = dd; 
    dw_data.hsig_swell = dd; 
    dw_data.part_time = dw_data.time; 
    dw_data.press_std_time = dw_data.time; 
    dw_data.press_time = dw_data.time; 
    dw_data.pressure = dd; 
    dw_data.pressure_std = dd; 
    dw_data.spec_time = dw_data.time; 
    dw_data.startFreq_sea = dd; 
    dw_data.startFreq_swell = dd; 
    dw_data.tm_sea = dd; 
    dw_data.tm_swell = dd; 
    dw_data.varianceDensity = dw_data.E.*nan;      
    dw_data.wind_dir = dd; 
    dw_data.wind_speed = dd; 
    dw_data.wind_time = dw_data.time; 
    
    %check that it's new data
    if all(check)~=0
        if ~isempty(archive_data)
            if size(dw_data.time,1)>size(archive_data.time,1)
                %perform some QA/QC --- QARTOD 19 and QARTOD 20        
                try
                    [data] = qaqc_bulkparams_realtime_website(buoy_info, archive_data, dw_data);                        
                catch
                    log_message = [log_message, ' (2) code failed on running QAQC'];
                end

                %save data to different formats   
                try
                    realtime_archive_mat(buoy_info, data);
                    realtime_backup_mat(buoy_info, data);
                    limit = size(dw_data.time,1) - size(archive_data.time,1);       
                    realtime_archive_text(buoy_info, data, limit);             
                catch
                    log_message = [log_message, ' (3) code failed on archiving or making text file'];
                end                           
                
                %output MEM and SST plots 
                plot_idx = find(data.time>archive_data.time(end)); 
                if strcmp(buoy_info.DataType,'spectral')    
                    try
                        for ii = 1:size(plot_idx,1); 
                            [NS, NE, ndirec] = lygre_krogstad_MC(data.a1(plot_idx(ii),:),data.a2(plot_idx(ii),:),data.b1(plot_idx(ii),:),data.b2(plot_idx(ii),:),data.E(plot_idx(ii),:),3);
                            make_MEM_plot(ndirec, data.frequency, NE, data.hsig(plot_idx(ii)), data.tp(plot_idx(ii)), data.dp(plot_idx(ii)), data.time(plot_idx(ii)), buoy_info)    
                        end
                    catch
                        log_message = [log_message, ' (4) code failed on making MEM'];
                    end
                    
                end
                
                %code to update the buoy info master file for website to read
                try
                    update_website_buoy_info(buoy_info, data); 
                catch
                    log_message = [log_message, ' (5) code failed updating buoys.csv']; 
                end 

            end
        end
    else
        dw_data.qf_waves = ones(size(dw_data.time,1),1).*4;
        dw_data.qf_sst = ones(size(dw_data.temp_time,1),1).*4; 
        dw_data.qf_bott_temp =ones(size(dw_data.temp_time,1),1).*4;         
        
        % save data to different formats  
        try
            realtime_archive_mat(buoy_info, data);
            realtime_backup_mat(buoy_info, data);
            limit = size(dw_data.time,1) - size(archive_data.time,1);       
            realtime_archive_text(buoy_info, data, limit);  
        catch
            log_message = [log_message, ' (3) code failed on archiving or making text file'];
        end                                       

        
        %output MEM and SST plots 
        if strcmp(buoy_info.DataType,'spectral')  
            try
                for ii = 1:size(dw_data.a1,1); 
                    [NS, NE, ndirec] = lygre_krogstad_MC(dw_data.a1(ii,:),dw_data.a2(ii,:),dw_data.b1(ii,:),dw_data.b2(ii,:),dw_data.E(ii,:),3);
                    make_MEM_plot(ndirec, dw_data.frequency', NE, dw_data.hsig(ii), dw_data.tp(ii), dw_data.dp(ii), dw_data.time(ii), buoy_info)    
                end    
            catch
                log_message = [log_message, ' (4) code failed on making MEM'];
            end
        end
        
        %code to update the buoy info master file for website to read                       
        try
            update_website_buoy_info(buoy_info, data); 
        catch
            log_message = [log_message, ' (5) code failed updating buoys.csv']; 
        end 
    end
end


  
       




