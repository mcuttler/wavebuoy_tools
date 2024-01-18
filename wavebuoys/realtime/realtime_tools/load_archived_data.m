%% load archived data to incorporate into QA/QC


%note, this only runs after a site has been created - so data should exist
%for current or preceding month 

function [data] = load_archived_data(buoy_info)
data  = []; 
dyr = dir([buoy_info.archive_path '\' buoy_info.name '\mat_archive\']); 
%only use latest
dyr = dyr(end); 
%now get all files in each year                
dmths = dir([buoy_info.archive_path '\' buoy_info.name '\mat_archive\' dyr.name]); 
%only keep latest
dmths = dmths(end); 
monthly_file = fullfile(dmths.folder, dmths.name); 
if exist(monthly_file)
    try                
        dum = load(monthly_file);
    catch
        monthly_file = [buoy_info.backup_path '\' buoy_info.name '\mat_archive\' dyr.name '\' dmths.name];
        dum = load(monthly_file); 
    end
    if strcmp(buoy_info.type,'sofar')
        data = dum.SpotData;
    elseif strcmp(buoy_info.type,'datawell')
        data = dum.dw_data;
    end
end


%%        
% dv = datevec(SpotData.time); 
% ddv = unique(dv(:,1:2),'rows'); 
% %if one month 
% if size(ddv,1)==1
%     monthly_file = [archive_path '\' buoy_info.name '\mat_archive\' num2str(ddv(1,1)) '\' buoy_info.name '_' num2str(ddv(1,1)) num2str(ddv(1,2),'%02d') '.mat'];
%     if exist(monthly_file)
%         try
%             dum = load(monthly_file);
%         catch
%             monthly_file = [buoy_info.backup_path '\' buoy_info.name '\mat_archive\' num2str(ddv(1,1)) '\' buoy_info.name '_' num2str(ddv(1,1)) num2str(ddv(1,2),'%02d') '.mat'];
%             dum = load(monthly_file);
%         end
%         data = dum.SpotData;
%     else
%         %if new month, then load previous data - get list of all years files in the archive 
%         dyr = dir([archive_path '\' buoy_info.name '\mat_archive\']); 
%         %only use latest
%         dyr = dyr(end); 
%         %now get all files in each year                
%         dmths = dir([archive_path '\' buoy_info.name '\mat_archive\' dyr.name]); 
%         %only keep latest
%         dmths = dmths(end); 
%         monthly_file = fullfile(dmths.folder, dmths.name); 
%         if exist(monthly_file)
%             try                
%                 dum = load(monthly_file);
%             catch
%                 monthly_file = [buoy_info.backup_path '\' buoy_info.name '\mat_archive\' dyr.name '\' dmths.name];
%                 dum = load(monthly_file); 
%             end
%             data = dum.SpotData;
%         end
%     end
% %if two months, load the first month as second month won't exist  
% else
%     monthly_file = [archive_path '\' buoy_info.name '\mat_archive\' num2str(ddv(1,1)) '\' buoy_info.name '_' num2str(ddv(1,1)) num2str(ddv(1,2),'%02d') '.mat'];
%     if exist(monthly_file)
%         try
%             dum = load(monthly_file);
%         catch
%             monthly_file = [buoy_info.backup_path '\' buoy_info.name '\mat_archive\' num2str(ddv(1,1)) '\' buoy_info.name '_' num2str(ddv(1,1)) num2str(ddv(1,2),'%02d') '.mat'];
%             dum = load(monthly_file); 
%         end
%         
%         data = dum.SpotData; 
%     end         

end

    




