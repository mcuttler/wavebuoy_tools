%% merge existing archives

function [merged_data, original_data, current_data] = merge_existing_Spotter_archives(buoy_info)

%first loop through pre-existing archives and collate data
if strcmp(buoy_info.type,'sofar')
    original_archive_path = ['F:\SpoondriftBuoys\' buoy_info.serial '_' buoy_info.name '\MAT'];
    %only waves or version 2 buoys
    if strcmp(buoy_info.version,'V2')
        original_data = struct('time',[],'hsig',[],'tp',[],'tm',[],'dp',[],'dpspr',[],'dm',[],...
            'dmspr',[],'lat',[],'lon',[],'temp',[],'temp_time',[],'wind_time',[],'wind_speed',[],'wind_dir',[],'wind_seasurfaceId',[]); 
        merged_data = struct('time',[],'hsig',[],'tp',[],'tm',[],'dp',[],'dpspr',[],'dm',[],...
            'dmspr',[],'lat',[],'lon',[],'surf_temp',[],'temp_time',[],'bott_temp',[],'wind_time',[],'wind_speed',[],'wind_dir',[],'wind_seasurfaceId',[]); 
    elseif strcmp(buoy_info.version,'V1')
        original_data = struct('time',[],'hsig',[],'tp',[],'tm',[],'dp',[],'dpspr',[],'dm',[],...
            'dmspr',[],'lat',[],'lon',[],'wind_time',[],'wind_speed',[],'wind_dir',[],'wind_seasurfaceId',[],...
            'a1',[],'a2',[],'b1',[],'b2',[],'varianceDensity',[],'frequency',[],'df',[],'directionalSpread',[],'direction',[],'spec_time',[]);
        merged_data = struct('time',[],'hsig',[],'tp',[],'tm',[],'dp',[],'dpspr',[],'dm',[],...
            'dmspr',[],'lat',[],'lon',[],'wind_time',[],'wind_speed',[],'wind_dir',[],'wind_seasurfaceId',[],...
            'a1',[],'a2',[],'b1',[],'b2',[],'varianceDensity',[],'frequency',[],'df',[],'directionalSpread',[],'direction',[],'spec_time',[]);
    end
    
    %loop through existing years/months 
    fields = fieldnames(original_data);    
    original_yrs = dir(original_archive_path); original_yrs = original_yrs(3:end); 
    for i = 1:size(original_yrs,1)
        original_mths = dir([original_archive_path '\' original_yrs(i).name]); original_mths = original_mths(3:end); 
        for ii = 1:size(original_mths,1)
            original_hrs = dir([original_archive_path '\' original_yrs(i).name '\' original_mths(ii).name]); 
            original_hrs = original_hrs(3:end); 
            for iii = 1:size(original_hrs,1)
                try
                    dum = load([original_archive_path '\' original_yrs(i).name '\' original_mths(ii).name '\' original_hrs(iii).name]); 
                    disp(original_hrs(iii).name);
                    %check lenght of wind/wave data
                    if isfield(dum.SpotData,'wind_speed'); 
                        [dum.SpotData] = check_spotter_wind_wave_data(dum.SpotData); 
                    end
                    for j = 1:length(fields)
                        if isfield(dum.SpotData, fields{j})
                            if ~isempty(dum.SpotData.(fields{j}))
                                if strcmp(fields{j},'a1')|strcmp(fields{j},'a2')|strcmp(fields{j},'b1')|strcmp(fields{j},'b2')|strcmp(fields{j},'varianceDensity')|strcmp(fields{j},'frequency')|strcmp(fields{j},'df')|strcmp(fields{j},'directionalSpread')|strcmp(fields{j},'direction')
                                    original_data.(fields{j}) = [original_data.(fields{j}); dum.SpotData.(fields{j})'];  
                                elseif strcmp(fields{j},'spec_time')
                                    original_data.(fields{j}) = [original_data.(fields{j}); dum.SpotData.time]; 
                                else                                    
                                    original_data.(fields{j}) = [original_data.(fields{j}); dum.SpotData.(fields{j})];
                                end
                            else
                                if strcmp(fields{j},'a1')|strcmp(fields{j},'a2')|strcmp(fields{j},'b1')|strcmp(fields{j},'b2')|strcmp(fields{j},'varianceDensity')|strcmp(fields{j},'frequency')|strcmp(fields{j},'df')|strcmp(fields{j},'directionalSpread')|strcmp(fields{j},'direction')
                                    original_data.(fields{j}) = [original_data.(fields{j}); ones(1,39).*nan]; 
                                else
                                    original_data.(fields{j}) = [original_data.(fields{j}); nan];
                                end
                            end
                        else
                            if strcmp(fields{j},'temp_time')|strcmp(fields{j},'wind_time')
                                original_data.(fields{j}) = [original_data.(fields{j}); dum.SpotData.time];
                            else
                                if strcmp(fields{j},'a1')|strcmp(fields{j},'a2')|strcmp(fields{j},'b1')|strcmp(fields{j},'b2')|strcmp(fields{j},'varianceDensity')|strcmp(fields{j},'frequency')|strcmp(fields{j},'df')|strcmp(fields{j},'directionalSpread')|strcmp(fields{j},'direction')
                                    original_data.(fields{j}) = [original_data.(fields{j}); ones(1,39).*nan]; 
                                else
                                    original_data.(fields{j}) = [original_data.(fields{j}); nan];
                                end
                            end
                        end
                    end
                catch
                    disp(['Cant load ' original_hrs(iii).name]);
                end
            end
        end
    end
    
    %% load current formatted data
    mat_years = dir([buoy_info.archive_path '\' buoy_info.name '\mat_archive']); 
    mat_years = mat_years(3:end); 
    for i = 1:size(mat_years,1); 
        mat_months = dir([buoy_info.archive_path '\' buoy_info.name '\mat_archive\' mat_years(i).name]); 
        mat_months = mat_months(3:end); 
        for ii = 1:size(mat_months,1)
            load([buoy_info.archive_path '\' buoy_info.name '\mat_archive\' mat_years(i).name '\' mat_months(ii).name]); 
            if ii == 1
                current_data = SpotData;
            else
                fields = fieldnames(SpotData);
                for j = 1:length(fields)
                    if isfield(current_data, fields{j})
                        current_data.(fields{j}) = [current_data.(fields{j}); SpotData.(fields{j})]; 
                    else
                        current_data.(fields{j}) = SpotData.(fields{j});
                    end
                end
            end
            clear SpotData
        end
    end
    
    %add spec_time if doesn't exist
    if ~isfield(current_data,'spec_time')&isfield(current_data,'a1')
        if size(current_data.time,1)==size(current_data.a1,1)
            current_data.spec_time = current_data.time; 
        end
    end
        
    
    %% combine
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
    
    % find duplicate times
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
    if isfield(merged_data,'temp_time')
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
    end
    %spectral data
    if isfield(merged_data,'a1')
        t_spec = merged_data.spec_time(~isnan(merged_data.spec_time));
        t_spec = unique(t_spec); 
        for i = 1:size(t_spec,1)
            merged_data2.spec_time(i,1) = t_spec(i); 
            idx = find(merged_data.time==t_spec(i)); 
            fields = {'a1','a2','b1','b2','varianceDensity','frequency','df','directionalSpread','direction'};
            for j = 1:length(fields)
                if length(idx)>1                                                           
                    t1 = merged_data.(fields{j})(idx(1),:); 
                    t2 = merged_data.(fields{j})(idx(2),:);  
                    
                    %all NaN
                    if all(isnan(t1))&all(isnan(t2))
                        merged_data2.(fields{j}) = [merged_data2.(fields{j}); nan]; 
                    %t1 NaN, t2 not NaN
                    elseif all(isnan(t1))&all(~isnan(t2))
                        merged_data2.(fields{j}) = [merged_data2.(fields{j}); merged_data.(fields{j})(idx(2))]; 
                    elseif all(~isnan(t1))&all(isnan(t2))
                        merged_data2.(fields{j}) = [merged_data2.(fields{j}); merged_data.(fields{j})(idx(1))]; 
                    else
                        merged_data2.(fields{j})=[merged_data2.(fields{j}); merged_data.(fields{j})(idx(1))];
                    end
                else
                    merged_data2.(fields{j}) = [merged_data2.(fields{j}); merged_data.(fields{j})(idx)];
                end
            end
        end
    end
        
    merged_data = merged_data2; 
    
    %%  sort to make sure all in right order
    [merged_data.time, sorted] = sort(merged_data.time); 
    
    fields = {'hsig','tp','tm','dp','dpspr','dm','dmspr','lat','lon','wind_time','wind_speed','wind_dir','wind_seasurfaceId'};
    for j = 1:length(fields)
        merged_data.(fields{j}) = merged_data.(fields{j})(sorted); 
    end
    
    if isfield(merged_data,'temp_time')
        [merged_data.temp_time, sorted_t] = sort(merged_data.temp_time);
        fields = {'surf_temp','bott_temp'};
        for j = 1:length(fields)
            merged_data.(fields{j}) = merged_data.(fields{j})(sorted_t); 
        end
    end
    
    if isfield(merged_data,'spec_time')
        [merged_data.spec_time, sorted_s] = sort(merged_data.spec_time);
        fields = {'a1','a2','b1','b2','varianceDensity','frequency','df','directionalSpread','direction'};
        for j = 1:length(fields)
            merged_data.(fields{j}) = merged_data.(fields{j})(sorted_s,:); 
        end
    end
        
end
end

    
                    
                
    
                
                
                
            
        
    
    
