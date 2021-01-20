%% load archived data to incorporate into QA/QC

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
        disp('No monthly file exists');
        data = SpotData; 
    end

else   
    for i = 1:size(ddv,1)
        monthly_file = [archive_path '\' buoy_info.name '\mat_archive\' num2str(ddv(i,1)) '\' buoy_info.name '_' num2str(ddv(i,1)) num2str(ddv(i,2),'%02d') '.mat'];
        
        if exist(monthly_file)
            dum = load(monthly_file);
            data.(['data' num2str(i)]) = dum.SpotData; 
        else
            disp('No monthly file exists');
            data.(['data' num2str(i)]) = SpotData; 
        end
    end
    
    %merge together
    fields = fieldnames(data); 
    for i = 1:size(fields,1) 
        if i ==1 
            dum = data.(fields{i}); 
        else
            fields2 = fieldnames(dum); 
            dum2 = data.(fields{i}); 
            for j = 1:size(fields2,1)
                dum.(fields2{j}) = [dum.(fields2{j}); dum2.(fields2{j})]; 
            end
        end
    end
end

end

    




