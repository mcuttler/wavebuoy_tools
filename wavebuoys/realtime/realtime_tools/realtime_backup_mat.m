%% backup buoy monthly matlab file
%essentially same as 'realtime_archive_mat' code, but different directory
%could be integrated into 'realtime_archive_mat' code, but separating
%allows for disabling this addtional backup if desired 

function [] = realtime_backup_mat(buoy_info, buoy_data); 

dv = datevec(buoy_data.time); 
ddv = unique(dv(:,1:2),'rows'); 

if size(ddv,1)==1
    backup_path = [buoy_info.backup_path '\' buoy_info.name '\mat_archive\' num2str(ddv(1,1))]; 
    if isfield(buoy_info,'backup_path2')
        backup_path2 = [buoy_info.backup_path2 '\' buoy_info.name '\mat_archive\' num2str(ddv(1,1))]; 
    end
    
    filename = [buoy_info.name '_' num2str(ddv(1,1)) num2str(ddv(1,2),'%02d') '.mat']; 
    if strcmp(buoy_info.type,'sofar')
        SpotData = buoy_data; 
        save([backup_path '\' filename],'SpotData','-v7.3');
        if isfield(buoy_info,'backup_path2')
            save([backup_path2 '\' filename],'SpotData','-v7.3');
        end            
    elseif strcmp(buoy_info.type,'datawell')
        dw_data = buoy_data; 
        save([backup_path '\' filename],'dw_data','-v7.3');
        if isfield(buoy_info,'backup_path2')
            save([backup_path2 '\' filename],'dw_data','-v7.3');
        end
    elseif strcmp(buoy_info.type,'triaxys')
        axys_data = buoy_data;         
        save([backup_path '\' filename],'axys_data','-v7.3');
        if isfield(buoy_info,'backup_path2')
            save([backup_path2 '\' filename],'axys_data','-v7.3');
        end
    end
    
else
    data = buoy_data; 
    for i = 1:size(ddv,1)
        dt = datevec(data.time); 
        idx = find(dt(:,1)==ddv(i,1)&dt(:,2)==ddv(i,2)); 
        %account for temperature
        if isfield(data,'temp_time'); 
            dt_temp = datevec(data.temp_time);    
            idx_temp = find(dt_temp(:,1)==ddv(i,1)&dt_temp(:,2)==ddv(i,2)); 
        end
        %account for pressure std
        if isfield(data,'press_std_time'); 
            dt_press_std = datevec(data.press_std_time);    
            idx_press_std = find(dt_press_std(:,1)==ddv(i,1)&dt_press_std(:,2)==ddv(i,2)); 
        end
        %account for pressure 
        if isfield(data,'press_time'); 
            dt_press = datevec(data.press_time);    
            idx_press = find(dt_press(:,1)==ddv(i,1)&dt_press(:,2)==ddv(i,2)); 
        end
        %account for spectral
        if isfield(data,'spec_time'); 
            dt_spec = datevec(data.spec_time); 
            idx_spec = find(dt_spec(:,1)==ddv(i,1) & dt_spec(:,2)==ddv(i,2)); 
        end        
        
        %account for partitioned
        if isfield(data,'part_time'); 
            dt_part = datevec(data.part_time); 
            idx_part = find(dt_part(:,1)==ddv(i,1) & dt_part(:,2)==ddv(i,2)); 
        end
        
        fields = fieldnames(data);
        for j = 1:length(fields)
            if strcmp(fields{j},'qf_bott_temp') |strcmp(fields{j},'qf_sst') |strcmp(fields{j},'surf_temp') | strcmp(fields{j},'bott_temp')|strcmp(fields{j},'temp_time') | strcmp(fields{j},'curr_mag') | strcmp(fields{j},'curr_dir') | strcmp(fields{j},'curr_mag_std') | strcmp(fields{j},'curr_dir_std') | strcmp(fields{j},'w') | strcmp(fields{j},'w_std')                
                buoy_data.(fields{j})=data.(fields{j})(idx_temp,:); 
                
            elseif strcmp(fields{j},'press_std_time')|strcmp(fields{j},'pressure_std')
                buoy_data.(fields{j}) = data.(fields{j})(idx_press_std,:); 
                
            elseif strcmp(fields{j},'press_time')|strcmp(fields{j},'pressure')
                buoy_data.(fields{j}) = data.(fields{j})(idx_press,:); 
                
            elseif strcmp(fields{j},'spec_time')|strcmp(fields{j},'a1')|strcmp(fields{j},'a2')|strcmp(fields{j},'b1')|...
                    strcmp(fields{j},'b2')|strcmp(fields{j},'direction')|strcmp(fields{j},'directionalSpread')|...
                    strcmp(fields{j},'frequency')|strcmp(fields{j},'varianceDensity')|strcmp(fields{j},'df')
                 if strcmp(buoy_info.type,'datawell')
                    if strcmp(fields{j},'frequency')
                        buoy_data.(fields{j}) = data.(fields{j}); 
                    else
                        buoy_data.(fields{j}) = data.(fields{j})(idx,:); 
                    end
                    
                else
                    buoy_data.(fields{j}) = data.(fields{j})(idx_spec,:);
                end
                 
                
            elseif strcmp(fields{j},'part_time')|(contains(fields{j},'sea')&~contains(fields{j},'wind'))|contains(fields{j},'swell')
                buoy_data.(fields{j}) = data.(fields{j})(idx_part,:); 
                
            else
                if size(data.(fields{j}),1)>1
                    buoy_data.(fields{j})=data.(fields{j})(idx,:);
                else
                    buoy_data.(fields{j})=data.(fields{j}); 
                end
            end
        end
        
        
        
        clear idx idx_temp
        backup_path = [buoy_info.backup_path '\' buoy_info.name '\mat_archive\' num2str(ddv(i,1))];
        if isfield(buoy_info,'backup_path2')
            backup_path2 = [buoy_info.backup_path2 '\' buoy_info.name '\mat_archive\' num2str(ddv(1,1))]; 
        end
        filename = [buoy_info.name '_' num2str(ddv(i,1)) num2str(ddv(i,2),'%02d') '.mat']; 
         if strcmp(buoy_info.type,'sofar')
             SpotData = buoy_data; 
             save([backup_path '\' filename],'SpotData','-v7.3');
             if isfield(buoy_info,'backup_path2')
                 save([backup_path2 '\' filename],'SpotData','-v7.3');
             end 
         elseif strcmp(buoy_info.type,'datawell')
             dw_data = buoy_data; 
             save([backup_path '\' filename],'dw_data','-v7.3');
             if isfield(buoy_info,'backup_path2')
                 save([backup_path2 '\' filename],'dw_data','-v7.3');
             end
         elseif strcmp(buoy_info.type,'triaxys')
             axys_data = buoy_data; 
             save([backup_path '\' filename],'axys_data','-v7.3');
             if isfield(buoy_info,'backup_path2')
                 save([backup_path2 '\' filename],'axys_data','-v7.3');
             end
         end
        
    end
end

end
        
    
        

    
    
    

