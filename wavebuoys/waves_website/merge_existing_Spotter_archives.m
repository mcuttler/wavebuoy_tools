%% merge existing archives

function [merged_data] = merge_existing_Spotter_archives(buoy_info)

%first loop through pre-existing archives and collate data
if strcmp(buoy_info.type,'sofar')
    original_archive_path = ['E:\SpoondriftBuoys\' buoy_info.serial '_' buoy_info.name '\MAT'];
    %only waves or version 2 buoys
    if strcmp(buoy_info.version,'V2')
        original_data = struct('time',[],'hsig',[],'tp',[],'tm',[],'dp',[],'dpspr',[],'dm',[],...
            'dmspr',[],'lat',[],'lon',[],'temp',[],'temp_time',[],'wind_speed',[],'wind_dir',[],'wind_seasurfaceId',[]); 
    else
        original_data = struct('time',[],'hsig',[],'tp',[],'tm',[],'dp',[],'dpspr',[],'dm',[],...
            'dmspr',[],'lat',[],'lon',[],'wind_speed',[],'wind_dir',[],'wind_seasurfaceId',[]); 
    end
    
    %loop through existing years/months 
    fields = fieldnames(original_data);
    if exist(original_archive_path)
        original_yrs = dir(original_archive_path); original_yrs = original_yrs(3:end); 
        for i = 1:size(original_yrs,1)
            original_mths = dir([original_archive_path '\' original_yrs(i).name]); original_mths = original_mths(3:end); 
            for ii = 1:size(original_mths,1)
                original_hrs = dir([original_archive_path '\' original_yrs(i).name '\' original_mths(ii).name]); 
                original_hrs = original_hrs(3:end); 
                for iii = 1:size(original_hrs,1)
                    dum = load([original_archive_path '\' original_yrs(i).name '\' original_mths(ii).name '\' original_hrs(iii).name]); 
                    for j = 1:length(fields)
                        if isfield(dum.SpotData, fields{j})
                            original_data.(fields{j}) = [original_data.(fields{j}); dum.SpotData.(fields{j})]; 
                        else
                            if strcmp(fields{j},'temp_time')
                                original_data.(fields{j}) = [original_data.(fields{j}); dum.SpotData.time];
                            else
                                original_data.(fields{j}) = [original_data.(fields{j}); nan];
                            end
                        end
                    end
                end
            end
        end
        %check that wind and waves are right size
        [m,~] = size(original_data.time); 
        [n,~] = size(original_data.wind_time); 
        if m~=n  
            if n>m %missing waves
                data = original_data; 
                fields = {'hsig';'tp';'tm';'dp';'dpspr';'dm';'dmspr';'lat';'lon'}; 
                for jj = 1:length(fields); 
                    data.(fields{jj}) = ones(size(original_data.time,1),1).*nan; 
                end
                data.time = original_data.wind_time;
                for j = 1:n
                    dum = find(original_data.time==original_data.wind_time(j)); 
                    if isempty(dum)
                        data.serialID{j,1} = buoy_info.serial;                 
                        for jj = 1:length(fields)
                            data.(fields{jj})(j,1) = nan;
                        end
                    else
                        data.serialID{j,1} = buoy_info.serial;
                        for jj = 1:length(fields)
                            data.(fields{jj})(j,1) = original_data.(fields{jj})(dum,1);
                        end
                    end
                end
                fields = {'time';'serialID';'hsig';'tp';'tm';'dp';'dpspr';'dm';'dmspr';'lat';'lon'};
                for jj = 1:length(fields)
                    original_data.(fields{jj}) = data.(fields{jj}); 
                end
                
            elseif m>n %missing wind
                data = original_data; 
                fields = {'wind_speed';'wind_dir';'wind_seasurfaceId'};
                for jj = 1:length(fields); 
                    data.(fields{jj}) = ones(size(original_data.time,1),1).*nan; 
                end
                data.wind_time = original_data.time;
                for j = 1:m
                    dum = find(original_data.wind_time==original_data.time(j)); 
                    if isempty(dum)                                
                        for jj = 1:length(fields)
                            data.(fields{jj})(j,1) = nan;
                        end
                    else
                        for jj = 1:length(fields)
                            data.(fields{jj})(j,1) = original_data.(fields{jj})(dum,1);
                        end
                    end
                end
                fields = {'wind_time';'wind_speed';'wind_dir';'wind_seasurfaceId'};
                for jj = 1:length(fields)
                    original_data.(fields{jj}) = data.(fields{jj}); 
                end
            end
        end
    end
    % Datawell
elseif strcmp(buoy_info.type,'datawell')
    original_archive_path = 'E:\DatawellBuoys\TorbayInshore\MAT'; 
end
%% load current formatted data
mat_years = dir([buoy_info.archive_path '\' buoy_info.name '\mat_archive']); 
mat_years = mat_years(3:end); 
for i = 1:size(mat_years,1); 
    mat_months = dir([buoy_info.archive_path '\' buoy_info.name '\mat_archive\' mat_years(i).name]); 
    mat_months = mat_months(3:end); 
    for ii = 1:size(mat_months,1)
        load([buoy_info.archive_path '\' buoy_info.name '\mat_archive\' mat_years(i).name '\' mat_months(ii).name]); 
        if i == 1
            current_data = SpotData;
        else
            fields = fieldnames(SpotData);
            for j = 1:length(fields)
                if isfields(current_data, fields{j])
                    current_data.(fields{j]) = [current_data.(fields{j}); SpotData.(fields{j})]; 
                else
                    current_data.(fields{j}) = SpotData.(fields{j]); 
                end
            end
        end
    end
end

%%




end
                
                
                
            
        
    
    
