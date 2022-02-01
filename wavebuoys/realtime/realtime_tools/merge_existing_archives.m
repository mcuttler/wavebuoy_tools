%% merge existing archives

function [merged_data] = merge_existing_archives(buoy_info)

%first loop through pre-existing archives and collate data
if strcmp(buoy_info.type,'sofar')
    original_archive_path = ['E:\SpoondriftBuoys\' buoy_info.serial '_' buoy_info.name '\MAT'];
elseif strcmp(buoy_info.type,'datawell')
    original_archive_path = 'E:\DatawellBuoys\TorbayInshore\MAT'; 
end

%only waves or version 2 buoys
if strcmp(buoy_info.version
original_data = struct('time',[],'hsig',[],'tp',[],'tm',[],'dp',[],'dpspr',[],'dm',[],...
    'dmspr',[],'lat',[],'lon',[],'temp',[],'temp_time',[],'wind_speed',[],'wind_dir',[],'wind_seasurfaceId',[]); 
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
                        original_data.(fields{j}) = [original_data.(fields{j}); nan]; 
                    end
                end
            end
        end
    end
    
end
                
                
                
            
        
    
    
