%% archive buoy data to text file

function [] = realtime_archive_text(buoy_info, data,limit); 

%either add just recent data (limit) to file; or all time points
if limit>0
    num = size(data.time,1)-(limit-1):size(data.time,1);     
else
    num = [1:size(data.time)]; 
end

%%
%loop through each time point
for ii = 1:length(num)
    dv = datevec(data.time(num(ii)));         
    %         year_path =[buoy_info.archive_path '\' buoy_info.name '\text_archive\' num2str(dv(1))]; 
    %         month_path = [buoy_info.archive_path '\' buoy_info.name '\text_archive\' num2str(dv(1)) '\' num2str(dv(2),'%02d')]; 
    %         day_path = [buoy_info.archive_path '\' buoy_info.name '\text_archive\' num2str(dv(1)) '\' num2str(dv(2),'%02d') '\' num2str(dv(3),'%02d')];
    
    archive_path =  [buoy_info.archive_path '\' buoy_info.name '\text_archive\' num2str(dv(1)) '\' num2str(dv(2),'%02d')]; 
    
    dataout.time = posixtime(datetime(dv)); 
    dataout.sitename = buoy_info.name; 
    dataout.buoy_id = buoy_info.serial; 
    fields = {'hsig','tp','tm','dp','dpspr','dm','dmspr','qf_waves','wind_speed','wind_dir','curr_mag','curr_dir','blank1','blank2','blank3'};
    for jj = 1:length(fields)
        if isfield(data,fields{jj})
            dataout.(fields{jj}) = data.(fields{jj})(num(ii));
        else
            dataout.(fields{jj}) = -9999; 
        end
    end        
    
    if isfield(data, 'temp_time')
        tidx = find(data.temp_time==data.time(num(ii))); 
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
    %         20. blank,
    %         21. blank,
    %         22. blank                  
    
    if ~exist(archive_path)
        mkdir(archive_path); 
        day_file = [archive_path '\' buoy_info.name '_' num2str(dv(1)) num2str(dv(2),'%02d') num2str(dv(3),'%02d') '.csv'];     
        fid = fopen(day_file,'a'); 
        fprintf(fid,'Time (UTC), Site, BuoyID, Hsig (m), Tp (s), Tm (s), Dp (deg), DpSpr (deg), Dm (deg), DmSpr (deg), QF_waves, SST (degC), QF_sst, Bottom Temp (degC), QF_bott_temp, WindSpeed (m/s), WindDirec (deg), CurrmentMag (m/s), CurrentDir (deg), blank, blank, blank \n');                 
        fmt = {'%f,','%s,', '%s,', '%f,', '%f,', '%f,', '%f,','%f,', '%f,', '%f,', '%f,', '%f,' ,'%f,', '%f,','%f,','%f,','%f,','%f,','%f,','%f,','%f,','%f \n'};
        fields = {'time','sitename','buoy_id','hsig','tp','tm','dp','dpspr','dm','dmspr','qf_waves','sst','qf_sst','bott_temp','qf_bott_temp','wind_speed','wind_dir','curr_mag','curr_dir','blank1','blank2','blank3'}; 
        for j = 1:length(fields); 
            fprintf(fid, fmt{j}, dataout.(fields{j}));
        end
        fclose(fid);
    else
        day_file = [archive_path '\' buoy_info.name '_' num2str(dv(1)) num2str(dv(2),'%02d') num2str(dv(3),'%02d') '.csv'];
        if exist(day_file)
            fid = fopen(day_file,'a'); 
            fmt = {'%f,','%s,', '%s,', '%f,', '%f,', '%f,', '%f,','%f,', '%f,', '%f,', '%f,', '%f,' ,'%f,', '%f,','%f,','%f,','%f,','%f,','%f,','%f,','%f,','%f \n'};
            fields = {'time','sitename','buoy_id','hsig','tp','tm','dp','dpspr','dm','dmspr','qf_waves','sst','qf_sst','bott_temp','qf_bott_temp','wind_speed','wind_dir','curr_mag','curr_dir','blank1','blank2','blank3'}; 
            for j = 1:length(fields); 
                fprintf(fid, fmt{j}, dataout.(fields{j}));
            end
            fclose(fid);
        else
            fid = fopen(day_file,'a');
            fprintf(fid,'Time (UTC), Site, BuoyID, Hsig (m), Tp (s), Tm (s), Dp (deg), DpSpr (deg), Dm (deg), DmSpr (deg), QF_waves, SST (degC), QF_sst, Bottom Temp (degC), QF_bott_temp, WindSpeed (m/s), WindDirec (deg), CurrmentMag (m/s), CurrentDir (deg), blank, blank, blank \n');                 
            fmt = {'%f,','%s,', '%s,', '%f,', '%f,', '%f,', '%f,','%f,', '%f,', '%f,', '%f,', '%f,' ,'%f,', '%f,','%f,','%f,','%f,','%f,','%f,','%f,','%f,','%f \n'};
            fields = {'time','sitename','buoy_id','hsig','tp','tm','dp','dpspr','dm','dmspr','qf_waves','sst','qf_sst','bott_temp','qf_bott_temp','wind_speed','wind_dir','curr_mag','curr_dir','blank1','blank2','blank3'}; 
            for j = 1:length(fields); 
                fprintf(fid, fmt{j}, dataout.(fields{j}));
            end
            fclose(fid);
        end
    end
    
end


end

                    
                
                
                
            
            
            
            
            
        
            
        
        

    
    
    

