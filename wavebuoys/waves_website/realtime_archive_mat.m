%% archive buoy data to text file

function [] = realtime_archive_mat(buoy_info, SpotData); 

dv = datevec(SpotData.time); 
ddv = unique(dv(:,1:2),'rows'); 

if size(ddv,1)==1
    archive_path = [buoy_info.archive_path '\' buoy_info.name '\mat_archive\' num2str(ddv(1,1))]; 
    filename = [buoy_info.name '_' num2str(ddv(1,1)) num2str(ddv(1,2),'%02d') '.mat']; 
    
    save([archive_path '\' filename],'SpotData','-v7.3'); 
else
    data = SpotData; 
    for i = 1:size(ddv,1)
        dt = datevec(data.time); 
        idx = find(dt(:,1)==ddv(i,1)&dt(:,2)==ddv(i,2)); 
        fields = fieldnames(data); 
        for j = 1:length(fields)
            SpotData.(fields{j})=data.(fields{j})(idx);
        end
        clear idx; 
        archive_path = [buoy_info.archive_path '\' buoy_info.name '\mat_archive\' num2str(ddv(i,1))];
        filename = [buoy_info.name '_' num2str(ddv(i,1)) num2str(ddv(i,2),'%02d') '.mat']; 
        save([archive_path '\' filename],'SpotData','-v7.3'); 
    end
end

end
        
    
        

    
    
    

