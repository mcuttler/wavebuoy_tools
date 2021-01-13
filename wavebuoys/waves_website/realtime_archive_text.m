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
    dataout.hs = data.hsig(num(ii)); 
    dataout.tp = data.tp(num(ii)); 
    dataout.tm = data.tm(num(ii)); 
    dataout.dp = data.dp(num(ii)); 
    dataout.dpspr = data.dpspr(num(ii)); 
    dataout.dm = data.dm(num(ii)); 
    dataout.dmspr = data.dmspr(num(ii)); 
    dataout.qf_waves = data.qf_waves(num(ii)); 
    dataout.wind_speed = data.wind_speed(num(ii)); 
    dataout.wind_dir = data.wind_dir(num(ii)); 
    dataout.blank1 = -9999;
    dataout.blank2 = -9999;
    dataout.blank3 = -9999;
    dataout.blank4 = -9999;
    dataout.blank5 = -9999;
    
    if isfield(data, 'temp_time')
        tidx = find(data.temp_time==data.time(num(ii))); 
        if isempty(tidx)            
            dataout.sst = -9999; 
            dataout.qf_sst = 4; 
        else
            dataout.sst = data.temp(tidx);
            dataout.qf_sst = data.qf_sst(tidx); 
        end
    else
        dataout.sst = -9999; 
        dataout.qf_sst = 4; 
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
    %         14. wind_speed
    %         15. wind_direction,
    %         16. blank,
    %         17. blank,
    %         18. blank,
    %         19. blank,
    %         20. blank                  
    if ~exist(archive_path)
        mkdir(archive_path); 
        day_file = [archive_path '\' buoy_info.name '_' num2str(dv(1)) num2str(dv(2),'%02d') num2str(dv(3),'%02d') '.csv'];     
        fid = fopen(day_file,'a'); 
        fprintf(fid,'Time (UTC), Site, BuoyID, Hs (m), Tp (s), Tm (s), Dp (deg), DpSpr (deg), Dm (deg), DmSpr (deg), QF_waves, SST (degC), QF_sst, WindSpeed (m/s), WindDirec (deg), blank, blank, blank, blank, blank \n');                 
        fmt = {'%f,','%s,', '%s,', '%f,', '%f,', '%f,', '%f,','%f,', '%f,', '%f,', '%f,', '%f,' ,'%f,', '%f,','%f,','%f,','%f,','%f,','%f,','%f \n'};
        fields = {'time','sitename','buoy_id','hs','tp','tm','dp','dpspr','dm','dmspr','qf_waves','sst','qf_sst','wind_speed','wind_dir','blank1','blank2','blank3','blank4','blank5'}; 
        for j = 1:length(fields); 
            fprintf(fid, fmt{j}, dataout.(fields{j}));
        end
        fclose(fid);
    else
        day_file = [archive_path '\' buoy_info.name '_' num2str(dv(1)) num2str(dv(2),'%02d') num2str(dv(3),'%02d') '.csv'];
        if exist(day_file)
            fid = fopen(day_file,'a'); 
            fmt = {'%f,','%s,', '%s,', '%f,', '%f,', '%f,', '%f,','%f,', '%f,', '%f,', '%f,', '%f,' ,'%f,', '%f,','%f,','%f,','%f,','%f,','%f,','%f \n'};
            fields = {'time','sitename','buoy_id','hs','tp','tm','dp','dpspr','dm','dmspr','qf_waves','sst','qf_sst','wind_speed','wind_dir','blank1','blank2','blank3','blank4','blank5'}; 
            for j = 1:length(fields); 
                fprintf(fid, fmt{j}, dataout.(fields{j}));
            end
            fclose(fid);
        else
            fid = fopen(day_file,'a');
            fprintf(fid,'Time (UTC), Site, BuoyID, Hs (m), Tp (s), Tm (s), Dp (deg), DpSpr (deg), Dm (deg), DmSpr (deg), QF_waves, SST (degC), QF_sst, WindSpeed (m/s), WindDirec (deg), blank, blank, blank, blank, blank \n');                 
            fmt = {'%f,','%s,', '%s,', '%f,', '%f,', '%f,', '%f,','%f,', '%f,', '%f,', '%f,', '%f,' ,'%f,', '%f,','%f,','%f,','%f,','%f,','%f,','%f \n'};
            fields = {'time','sitename','buoy_id','hs','tp','tm','dp','dpspr','dm','dmspr','qf_waves','sst','qf_sst','wind_speed','wind_dir','blank1','blank2','blank3','blank4','blank5'}; 
            for j = 1:length(fields); 
                fprintf(fid, fmt{j}, dataout.(fields{j}));
            end
            fclose(fid);
        end
    end
    
end


end

                    
                
                
                
            
            
            
            
            
        
            
        
        

    
    
    

