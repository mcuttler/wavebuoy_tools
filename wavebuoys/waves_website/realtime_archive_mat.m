%% archive buoy data to text file

function [] = realtime_archive_mat(buoy_info, buoy_data); 

dv = datevec(buoy_data.time); 
ddv = unique(dv(:,1:2),'rows'); 

if size(ddv,1)==1
    archive_path = [buoy_info.archive_path '\' buoy_info.name '\mat_archive\' num2str(ddv(1,1))]; 
    filename = [buoy_info.name '_' num2str(ddv(1,1)) num2str(ddv(1,2),'%02d') '.mat']; 
    if strcmp(buoy_info.type,'sofar')
        SpotData = buoy_data; 
        save([archive_path '\' filename],'SpotData','-v7.3');
    elseif strcmp(buoy_info.type,'datawell')
        dw_data = buoy_data; 
        save([archive_path '\' filename],'dw_data','-v7.3');
    elseif strcmp(buoy_info.type,'triaxys')
        axys_data = buoy_data; 
        save([archive_path '\' filename],'axys_data','-v7.3');
    end
    
else
    data = buoy_data; 
    for i = 1:size(ddv,1)
        dt = datevec(data.time); 
        dt_temp = datevec(data.temp_time); 
        idx = find(dt(:,1)==ddv(i,1)&dt(:,2)==ddv(i,2)); 
        idx_temp = find(dt_temp(:,1)==ddv(i,1)&dt_temp(:,2)==ddv(i,2)); 
        fields = fieldnames(data); 
        for j = 1:length(fields)
            if strcmp(fields{j},'temp') | strcmp(fields{j},'temp_time') | strcmp(fields{j},'curr_mag') | strcmp(fields{j},'curr_dir') | strcmp(fields{j},'curr_mag_std') | strcmp(fields{j},'curr_dir_std') | strcmp(fields{j},'w') | strcmp(fields{j},'w_std')
                buoy_data.(fields{j})=data.(fields{j})(idx_temp); 
            else
                buoy_data.(fields{j})=data.(fields{j})(idx);
            end
        end
        clear idx; 
        archive_path = [buoy_info.archive_path '\' buoy_info.name '\mat_archive\' num2str(ddv(i,1))];
        filename = [buoy_info.name '_' num2str(ddv(i,1)) num2str(ddv(i,2),'%02d') '.mat']; 
        if strcmp(buoy_info.type,'sofar')
            SpotData = buoy_data; 
            save([archive_path '\' filename],'SpotData','-v7.3');
        elseif strcmp(buoy_info.type,'datawell')
            SpotData = buoy_data; 
            save([archive_path '\' filename],'SpotData','-v7.3');
        elseif strcmp(buoy_info.type,'triaxys')
            SpotData = buoy_data; 
            save([archive_path '\' filename],'SpotData','-v7.3');
        end
        
    end
end

end
        
    
        

    
    
    

