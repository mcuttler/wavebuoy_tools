clear; clc; 

buoy_info.type = 'sofar'; 
buoy_info.serial = 'SPOT-0938'; %spotter serial number, or just Datawell 
buoy_info.name = 'SharkBay'; 
buoy_info.datawell_name = 'nan'; 
buoy_info.version = 'smart_mooring'; %V1, V2, smart_mooring, Datawell, Triaxys
buoy_info.sofar_token = 'a1b3c0dbaa16bb21d5f0befcbcca51'; 
buoy_info.utc_offset = 8; 
buoy_info.DeployLoc = 'SharkBay';
buoy_info.DeployDepth = 20; 
buoy_info.DeployLat = -25.418967; 
buoy_info.DeployLon = 113.125383; 
buoy_info.UpdateTime =  1; %hours
buoy_info.DataType = 'parameters'; %can be parameters if only bulk parameters, or spectral for including spectral coefficients
buoy_info.archive_path = 'E:\wawaves';
buoy_info.backup_path = '\\drive.irds.uwa.edu.au\OGS-COD-001\CUTTLER_wawaves\Data\realtime_archive_backup'; 
buoy_info.datawell_datapath = 'E:\waved'; %top level directory for Datawell CSVs

%%
yrs = 2021; 
files = dir(['E:\wawaves\' buoy_info.name '\mat_archive\' num2str(yrs)]);
files = files(3:end); 
for j = 1:length(files); 
    load(['E:\wawaves\' buoy_info.name '\mat_archive\' num2str(yrs) '\' files(j).name]);      
    t_temp = unique(SpotData.temp_time); 
    if length(t_temp)~=length(SpotData.temp_time)
        for i = 1:length(t_temp)
            idx_temp = find(SpotData.temp_time == t_temp(i));                         
            if length(idx_temp)>1
                idx_temp2 = find(SpotData.temp_time==t_temp(i),1,'first'); 
                fields = {'surf_temp','bott_temp','qf_sst','qf_bott_temp'};
                for ii = 1:length(fields)
                    data.(fields{ii})(i,1) = SpotData.(fields{ii})(idx_temp2); 
                end
                data.temp_time(i,1) = t_temp(i);
            else
                data.temp_time(i,1) = t_temp(i);
                data.surf_temp(i,1) = SpotData.surf_temp(idx_temp); 
                data.bott_temp(i,1) = SpotData.bott_temp(idx_temp); 
                data.qf_sst(i,1)  = SpotData.qf_sst(idx_temp); 
                data.qf_bott_temp(i,1) = SpotData.qf_bott_temp(idx_temp); 
            end
            clear idx_temp idx_temp2
        end
    else
        fields = {'temp_time','surf_temp','bott_temp','qf_sst','qf_bott_temp'};
        for ii = 1:length(fields)
            data.(fields{ii}) = SpotData.(fields{ii}); 
        end
    end
    
    t_wave = unique(SpotData.time); 
    if length(t_wave)~=length(SpotData.time)
         for i = 1:length(t_wave)
            idx_wave = find(SpotData.time == t_wave(i));                         
            if length(idx_wave)>1
                idx_wave2 = find(SpotData.time==t_wave(i),1,'first'); 
                fields = {'hsig','tp','tm','dp','dpspr','dm','dmspr','lat','lon','wind_time','wind_speed','wind_dir','wind_seasurfaceId','qf_waves'};
                for ii = 1:length(fields)
                    data.(fields{ii})(i,1) = SpotData.(fields{ii})(idx_wave2); 
                end
                data.time(i,1) = t_wave(i);
            else
                fields = {'hsig','tp','tm','dp','dpspr','dm','dmspr','lat','lon','wind_time','wind_speed','wind_dir','wind_seasurfaceId','qf_waves'};
                for ii = 1:length(fields) 
                    data.(fields{ii}) = SpotData.(fields{ii})(idx_wave); 
                end
            end
            clear idx_wave idx_wave2
        end
    else
        fields = {'time','hsig','tp','tm','dp','dpspr','dm','dmspr','lat','lon','wind_time','wind_speed','wind_dir','wind_seasurfaceId','qf_waves'};
        for ii = 1:length(fields)
            data.(fields{ii}) = SpotData.(fields{ii}); 
        end
    end
    realtime_archive_mat(buoy_info, data);
%     realtime_backup_mat(buoy_info, data);
    tt = datevec(data.time(1)); 
    rmdir([buoy_info.archive_path '\' buoy_info.name  '\text_archive\' num2str(tt(1)) '\' num2str(tt(2),'%02d')],'s'); 
    realtime_archive_text(buoy_info, data, 0); 
end
            
                
        
        

                