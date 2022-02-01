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
    
    
    %file format:
    %         1. timestamp, 
    %         2. site name, 
    %         3. buoy id, 
    %         4. hs, 
    %         5. tp, 
    %         6. tm, 
    %         7. dp, 
    %         8. dpspr, 
    %         9. dm, 
    %         10. dmspr, 
    %         11. qf_waves, 
    %         12. sst, 
    %         13. qf_sst, 
    %         14. bott_temp,
    %         15. qf_bott_temp
    %         16. wind_speed
    %         17. wind_direction,
    %         18. current_magnitude,
    %         19. current_direction,
    %         20. latitude,
    %         21. longitude,
            
    
    if ~exist(archive_path)
        mkdir(archive_path); 
        day_file = [archive_path '\' buoy_info.name '_' num2str(dv(1)) num2str(dv(2),'%02d') num2str(dv(3),'%02d') '.csv'];     
        fid = fopen(day_file,'a'); 
        fprintf(fid,'Time (UNIX/UTC), Timestamp (UTC), Site, BuoyID, Hsig (m), Tp (s), Tm (s), Dp (deg), DpSpr (deg), Dm (deg), DmSpr (deg), QF_waves, SST (degC), QF_sst, Bottom Temp (degC), QF_bott_temp, WindSpeed (m/s), WindDirec (deg), CurrmentMag (m/s), CurrentDir (deg), Latitude (deg), Longitude (deg) \n');                             
        fmt = {'%d,','%s,','%s,', '%s,', '%.2f,', '%.2f,', '%.2f,', '%.2f,','%.2f,', '%.2f,', '%.2f,', '%d,', '%.1f,' ,'%d,', '%.1f,','%d,','%.2f,','%.2f,','%.2f,','%.2f,','%.4f,','%.4f \n'};        
        fields = {'time','timestamp','sitename','buoy_id','hsig','tp','tm','dp','dpspr','dm','dmspr','qf_waves','sst','qf_sst','bott_temp','qf_bott_temp','wind_speed','wind_dir','curr_mag','curr_dir', 'lat','lon'}; 
        for j = 1:length(fields); 
            fprintf(fid, fmt{j}, dataout.(fields{j}));
        end
        fclose(fid);
    else
        day_file = [archive_path '\' buoy_info.name '_' num2str(dv(1)) num2str(dv(2),'%02d') num2str(dv(3),'%02d') '.csv'];
        if exist(day_file)
            fid = fopen(day_file,'a'); 
            fmt = {'%d,','%s,','%s,', '%s,', '%.2f,', '%.2f,', '%.2f,', '%.2f,','%.2f,', '%.2f,', '%.2f,', '%d,', '%.1f,' ,'%d,', '%.1f,','%d,','%.2f,','%.2f,','%.2f,','%.2f,','%.4f,','%.4f \n'};        
            fields = {'time','timestamp','sitename','buoy_id','hsig','tp','tm','dp','dpspr','dm','dmspr','qf_waves','sst','qf_sst','bott_temp','qf_bott_temp','wind_speed','wind_dir','curr_mag','curr_dir', 'lat','lon'}; 
            for j = 1:length(fields); 
                fprintf(fid, fmt{j}, dataout.(fields{j}));
            end
            fclose(fid);
        else
            fid = fopen(day_file,'a');
            fprintf(fid,'Time (UNIX/UTC), Timestamp (UTC), Site, BuoyID, Hsig (m), Tp (s), Tm (s), Dp (deg), DpSpr (deg), Dm (deg), DmSpr (deg), QF_waves, SST (degC), QF_sst, Bottom Temp (degC), QF_bott_temp, WindSpeed (m/s), WindDirec (deg), CurrmentMag (m/s), CurrentDir (deg), Latitude (deg), Longitude (deg) \n');                             
            fmt = {'%d,','%s,','%s,', '%s,', '%.2f,', '%.2f,', '%.2f,', '%.2f,','%.2f,', '%.2f,', '%.2f,', '%d,', '%.1f,' ,'%d,', '%.1f,','%d,','%.2f,','%.2f,','%.2f,','%.2f,','%.4f,','%.4f \n'};        
            fields = {'time','timestamp','sitename','buoy_id','hsig','tp','tm','dp','dpspr','dm','dmspr','qf_waves','sst','qf_sst','bott_temp','qf_bott_temp','wind_speed','wind_dir','curr_mag','curr_dir', 'lat','lon'}; 
        for j = 1:length(fields); 
            fprintf(fid, fmt{j}, dataout.(fields{j}));
        end
            for j = 1:length(fields); 
                fprintf(fid, fmt{j}, dataout.(fields{j}));
            end
            fclose(fid);
        end
    end
    
end


end

                    
                
                
                
            
            
            
            
            
        
            
        
        

    
    
    

