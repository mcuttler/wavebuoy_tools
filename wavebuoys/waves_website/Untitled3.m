    fields = fieldnames(original_data);     
    for i = 1:length(fields)
        
        if strcmp(fields{i},'temp_time')|strcmp(fields{i},'temp')
            if strcmp(fields{i},'temp')
                merged_data.surf_temp = [original_data.temp; current_data.surf_temp]; 
                merged_data.bott_temp= [ones(size(original_data.temp,1),1).*-9999; current_data.bott_temp]; 
            elseif strcmp(fields{i},'temp_time')
                merged_data.temp_time = [original_data.temp_time; current_data.temp_time]; 
            end
        else
            merged_data.(fields{i}) = [original_data.(fields{i}); current_data.(fields{i})];
        end
    end   
    
    %% find duplicate times
    fields = fieldnames(merged_data); 
    for j = 1:length(fields); 
        merged_data2.(fields{j}) = [];     
    end
    
    t_wave = unique(merged_data.time);            
    %wave data        
    for i = 1:size(t_wave,1)
        merged_data2.time(i,1) = t_wave(i); 
        idx = find(merged_data.time==t_wave(i)); 
        fields = {'hsig','tp','tm','dp','dpspr','dm','dmspr','lat','lon','wind_time','wind_speed','wind_dir','wind_seasurfaceId'};
        for j = 1:length(fields)
            if length(idx)>1                                                           
                t1 = merged_data.(fields{j})(idx(1)); 
                t2 = merged_data.(fields{j})(idx(2)); 
                
                if isnan(t1)&isnan(t2)
                    merged_data2.(fields{j}) = [merged_data2.(fields{j}); nan]; 
                elseif isnan(t1)&~isnan(t2)
                    merged_data2.(fields{j}) = [merged_data2.(fields{j}); merged_data.(fields{j})(idx(2))]; 
                elseif ~isnan(t1)&isnan(t2)
                    merged_data2.(fields{j}) = [merged_data2.(fields{j}); merged_data.(fields{j})(idx(1))]; 
                else
                    merged_data2.(fields{j})=[merged_data2.(fields{j}); merged_data.(fields{j})(idx(1))];
                end
            else
                merged_data2.(fields{j}) = [merged_data2.(fields{j}); merged_data.(fields{j})(idx)];
            end
        end
    end
    %temp data
    t_temp = unique(merged_data.temp_time); 
    for i = 1:size(t_temp,1)
        merged_data2.temp_time(i,1) = t_temp(i); 
        idx = find(merged_data.temp_time==t_temp(i)); 
        fields = {'surf_temp','bott_temp'};
        for j = 1:length(fields)
            if length(idx)>1                                                           
                t1 = merged_data.(fields{j})(idx(1)); 
                t2 = merged_data.(fields{j})(idx(2)); 
                
                if isnan(t1)&isnan(t2)
                    merged_data2.(fields{j}) = [merged_data2.(fields{j}); nan]; 
                elseif isnan(t1)&~isnan(t2)
                    merged_data2.(fields{j}) = [merged_data2.(fields{j}); merged_data.(fields{j})(idx(2))]; 
                elseif ~isnan(t1)&isnan(t2)
                    merged_data2.(fields{j}) = [merged_data2.(fields{j}); merged_data.(fields{j})(idx(1))]; 
                else
                    merged_data2.(fields{j})=[merged_data2.(fields{j}); merged_data.(fields{j})(idx(1))];
                end
            else
                merged_data2.(fields{j}) = [merged_data2.(fields{j}); merged_data.(fields{j})(idx)];
            end
        end
    end    
    
    merged_data = merged_data2; 
    
                    
                
    