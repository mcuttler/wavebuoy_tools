%% load archived data to incorporate into QA/QC


%note, this only runs after a site has been created - so data should exist
%for current or preceding month 

function [data] = load_archived_data(archive_path, buoy_info, SpotData); 
data  = []; 
dv = datevec(SpotData.time); 
ddv = unique(dv(:,1:2),'rows'); 

if size(ddv,1)==1
    monthly_file = [archive_path '\' buoy_info.name '\mat_archive\' num2str(ddv(1,1)) '\' buoy_info.name '_' num2str(ddv(1,1)) num2str(ddv(1,2),'%02d') '.mat'];
    if exist(monthly_file)
        dum = load(monthly_file);
        data = dum.SpotData; 
    else
        %check if new month, then load previous data
         monthly_file = [archive_path '\' buoy_info.name '\mat_archive\' num2str(ddv(1,1)) '\' buoy_info.name '_' num2str(ddv(1,1)) num2str(ddv(1,2)-1,'%02d') '.mat'];
         if exist(monthly_file)
             dum = load(monthly_file);
             data = dum.SpotData; 
         end         
    end
else
    monthly_file = [archive_path '\' buoy_info.name '\mat_archive\' num2str(ddv(1,1)) '\' buoy_info.name '_' num2str(ddv(1,1)) num2str(ddv(1,2),'%02d') '.mat'];
    if exist(monthly_file)
        dum = load(monthly_file);
        data = dum.SpotData; 
    end         

end

    




