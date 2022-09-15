%% Back-fill daily text file archive using existing mat files
   
function [] = backfill_RT_text_archive(data_path, site)

%loop through years and months
mat_yrs = dir([data_path '\' site '\mat_archive']); 
mat_yrs = mat_yrs(3:end); 

for j = 1:size(mat_yrs,1)
    mat_mnth = dir([data_path '\' site '\mat_archive\' mat_yrs(j).name]); 
    mat_mnth = mat_mnth(3:end); 
    for jj = 1:size(mat_mnth)
        data = load([data_path '\' site '\mat_archive\' mat_yrs(j).name '\' mat_mnth(jj).name]);
        fields = fieldnames(data);
        data = data.(fields{1});
        buoy_info.archive_path = data_path; 
        if strcmp(site,'Torbay')
            buoy_info.serial = 'Datawell-74103';  
            buoy_info.name = 'Torbay'; 
        else
            buoy_info.serial = data.serialID{1};
            buoy_info.name = site; 
        end
            
        realtime_archive_text(buoy_info, data, 0); 
    end
end
end
