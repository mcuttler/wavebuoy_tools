%% archive buoy data to text file

function [] = realtime_archive_text(buoy_info, data,limit); 
% either add just recent data (limit) to file; or all time points
if limit>0
    num = size(data.time,1)-(limit-1):size(data.time,1);     
else
    num = [1:size(data.time)]; 
end

%% check that wind and waves are same size
%loop through each time point
for ii = 1:length(num)
    dv = datevec(data.time(num(ii)));         
    archive_path =  [buoy_info.archive_path '\' buoy_info.name '\text_archive\' num2str(dv(1)) '\' num2str(dv(2),'%02d')]; 
    
    dataout.time = posixtime(datetime(dv));
    dataout.timestamp = datestr(dv); 
    dataout.sitename = buoy_info.name; 
    dataout.buoy_id = buoy_info.serial; 
    fields = {'hsig','tp','tm','dp','dpspr','dm','dmspr','qf_waves','wind_speed','wind_dir','curr_mag','curr_dir','lat','lon'};
    for jj = 1:length(fields)
        if isfield(data,fields{jj})
            %round directional data
            if strcmp(fields{jj},'dp')|strcmp(fields{jj},'dpspr')|strcmp(fields{jj},'dm')|strcmp(fields{jj},'dmspr')
                dataout.(fields{jj})=round(data.(fields{jj})(num(ii)),2); 
            else
                dataout.(fields{jj}) = data.(fields{jj})(num(ii));
            end
        else
            dataout.(fields{jj}) = -9999; 
        end
    end        
    
    %temperature data for text file 
    if isfield(data, 'temp_time')       
        tidx = find(data.temp_time==data.time(num(ii))); 
        if isempty(tidx)
            tidx1 = find(abs(data.temp_time-data.time(num(ii)))==min(abs(data.temp_time-data.time(num(ii)))));
            if length(tidx1)>1
                tidx1 = tidx1(1); 
            end            
            max_diff = 30/(60*24); 
            if abs(data.temp_time(tidx1)-data.time(num(ii))) < max_diff
                tidx = tidx1;
            else
                tidx = [];
            end
        end
                
        if isempty(tidx)            
            dataout.sst = -9999; 
            dataout.qf_sst = 4; 
            dataout.bott_temp = -9999; 
            dataout.qf_bott_temp = 4; 
        else
            dataout.sst = data.surf_temp(tidx);
            dataout.qf_sst = data.qf_sst(tidx); 
            dataout.bott_temp = data.bott_temp(tidx); 
            dataout.qf_bott_temp = data.qf_bott_temp(tidx); 
        end
    else
        dataout.sst = -9999; 
        dataout.qf_sst = 4; 
        dataout.bott_temp = -9999; 
        dataout.qf_bott_temp = 4; 
    end
    
    %partitioned wavedata for text file
    pfields = {'hsig_swell','hsig_sea','tm_swell','tm_sea','dm_swell','dm_sea','dmspr_swell','dmspr_sea'}; 
    if isfield(data, 'part_time')       
        tidx = find(data.part_time==data.time(num(ii))); 
        if isempty(tidx)
            tidx1 = find(abs(data.part_time-data.time(num(ii)))==min(abs(data.part_time-data.time(num(ii)))));
            if length(tidx1)>1
                tidx1 = tidx1(1); 
            end            
            max_diff = 30/(60*24); 
            if abs(data.part_time(tidx1)-data.time(num(ii))) < max_diff
                tidx = tidx1;
            else
                tidx = [];
            end
        end
        
        
        if isempty(tidx)   
            for k = 1:length(pfields)
                dataout.(pfields{k}) = -9999; 
            end      
        else
            for k = 1:length(pfields)
                dataout.(pfields{k}) = data.(pfields{k})(tidx,:);
            end
        end
    else
        for k = 1:length(pfields)
            dataout.(pfields{k}) = -9999; 
        end
    end
    
    
    %file format: 
    %         1. time %d, 
    %         2. timestamp %s,     
    %         3. site name %s, 
    %         4. buoy id %s, 
    %         5. hs %.2f, 
    %         6. hs_swell, 
    %         7. hs_sea, 
    %         8. tp %.2f, 
    %         9. tm_swell,
    %         10. tm_sea,
    %         11. tm %.2f,
    %         12. dp %.2f, 
    %         13. dpspr %.2f, 
    %         14. dm %.2f, 
    %         15. dm_swell, 
    %         16. dm_sea, 
    %         17. dmspr %.2f,
    %         18. dmspr_swell,
    %         19. dmspr_sea,
    %         20. qf_waves %d, 
    %         21. sst %.1f, 
    %         22. qf_sst %d, 
    %         23. bott_temp %.1f,
    %         24. qf_bott_temp %d,
    %         25. wind_speed %.2f,
    %         26. wind_direction %.2f,
    %         27. current_magnitude %.2f,
    %         28. current_direction %.2f,
    %         29. latitude %.4f,
    %         30. longitude %.4f,
            
    
    if ~exist(archive_path)
        mkdir(archive_path); 
        day_file = [archive_path '\' buoy_info.name '_' num2str(dv(1)) num2str(dv(2),'%02d') num2str(dv(3),'%02d') '.csv'];     
        fid = fopen(day_file,'a'); 
        fprintf(fid,['Time (UNIX/UTC), Timestamp (UTC), Site, BuoyID, Hsig (m), Hsig_swell (m), Hsig_sea (m), Tp (s),'...
            'Tm (s), Tm_swell (s), Tm_sea (s), Dp (deg), DpSpr (deg), Dm (deg), Dm_swell (deg), Dm_sea (deg), DmSpr (deg), DmSpr_swell (deg), DmSpr_sea (deg),'...
            'QF_waves, SST (degC), QF_sst, Bottom Temp (degC), QF_bott_temp, WindSpeed (m/s), WindDirec (deg), CurrmentMag (m/s),'...
            'CurrentDir (deg), Latitude (deg), Longitude (deg) \n']);                             
        fmt = {'%d,','%s,','%s,', '%s,', '%.2f,', '%.2f,', '%.2f,', '%.2f,',...
            '%.2f,', '%.2f,', '%.2f,', '%.2f,','%.2f,', '%.2f,', '%.2f,', '%.2f,', '%.2f,', '%.2f,', '%.2f,',...
            '%d,', '%.1f,' ,'%d,', '%.1f,','%d,','%.2f,','%.2f,','%.2f,','%.2f,','%.4f,','%.4f \n'};       
        fields = {'time','timestamp','sitename','buoy_id','hsig','hsig_swell','hsig_sea','tp',...
            'tm','tm_swell','tm_sea','dp','dpspr','dm','dm_swell','dm_sea','dmspr','dmspr_swell','dmspr_sea',...
            'qf_waves','sst','qf_sst','bott_temp','qf_bott_temp','wind_speed','wind_dir','curr_mag',...
            'curr_dir', 'lat','lon'}; 
        for j = 1:length(fields) 
            fprintf(fid, fmt{j}, dataout.(fields{j}));
        end
        fclose(fid);
        
    else
        day_file = [archive_path '\' buoy_info.name '_' num2str(dv(1)) num2str(dv(2),'%02d') num2str(dv(3),'%02d') '.csv'];
        if exist(day_file)
            fid = fopen(day_file,'a'); 
            
            fmt = {'%d,','%s,','%s,', '%s,', '%.2f,', '%.2f,', '%.2f,', '%.2f,',...
                '%.2f,', '%.2f,', '%.2f,', '%.2f,','%.2f,', '%.2f,', '%.2f,', '%.2f,', '%.2f,', '%.2f,', '%.2f,',...
                '%d,', '%.1f,' ,'%d,', '%.1f,','%d,','%.2f,','%.2f,','%.2f,','%.2f,','%.4f,','%.4f \n'};               
            
            fields = {'time','timestamp','sitename','buoy_id','hsig','hsig_swell','hsig_sea','tp',...
                'tm','tm_swell','tm_sea','dp','dpspr','dm','dm_swell','dm_sea','dmspr','dmspr_swell','dmspr_sea',...
                'qf_waves','sst','qf_sst','bott_temp','qf_bott_temp','wind_speed','wind_dir','curr_mag',...
                'curr_dir', 'lat','lon'}; 
            
            for j = 1:length(fields); 
                fprintf(fid, fmt{j}, dataout.(fields{j}));
            end
            fclose(fid);
            
        else
            fid = fopen(day_file,'a');            
            fprintf(fid,['Time (UNIX/UTC), Timestamp (UTC), Site, BuoyID, Hsig (m), Hsig_swell (m), Hsig_sea (m), Tp (s),'...
                'Tm (s), Tm_swell (s), Tm_sea (s), Dp (deg), DpSpr (deg), Dm (deg), Dm_swell (deg), Dm_sea (deg), DmSpr (deg), DmSpr_swell (deg), DmSpr_sea (deg),'...
                'QF_waves, SST (degC), QF_sst, Bottom Temp (degC), QF_bott_temp, WindSpeed (m/s), WindDirec (deg), CurrmentMag (m/s),'...
                'CurrentDir (deg), Latitude (deg), Longitude (deg) \n']);                             
            fmt = {'%d,','%s,','%s,', '%s,', '%.2f,', '%.2f,', '%.2f,', '%.2f,',...
                '%.2f,', '%.2f,', '%.2f,', '%.2f,','%.2f,', '%.2f,', '%.2f,', '%.2f,', '%.2f,', '%.2f,', '%.2f,',...
                '%d,', '%.1f,' ,'%d,', '%.1f,','%d,','%.2f,','%.2f,','%.2f,','%.2f,','%.4f,','%.4f \n'};       
            fields = {'time','timestamp','sitename','buoy_id','hsig','hsig_swell','hsig_sea','tp',...
                'tm','tm_swell','tm_sea','dp','dpspr','dm','dm_swell','dm_sea','dmspr','dmspr_swell','dmspr_sea',...
                'qf_waves','sst','qf_sst','bott_temp','qf_bott_temp','wind_speed','wind_dir','curr_mag',...
                'curr_dir', 'lat','lon'}; 
 
            for j = 1:length(fields); 
                fprintf(fid, fmt{j}, dataout.(fields{j}));
            end
            fclose(fid);
        end
    end
    
end


end

                    
                
                
                
            
            
            
            
            
        
            
        
        

    
    
    

