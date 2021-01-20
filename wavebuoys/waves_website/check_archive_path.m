%% check if path exists and make path if not for data archive and load
%checks for existing MATLAB monthly file



%%
function [check] = check_archive_path(datapath,buoy_info, data); 
check = [];
dv = datevec(data.time); 

%check to see if the time points are same month or different months
if dv(1,1)==dv(end,1) %same year
    if ~exist([datapath '\' buoy_info.name '\mat_archive\' num2str(dv(1,1))]); 
        mkdir([datapath '\' buoy_info.name '\mat_archive\' num2str(dv(1,1))]); 
        check = 0; 
    else
        check =1; 
    end
else
    for i = 1:size(dv,1)
        if ~exist([datapath '\' buoy_info.name '\mat_archive\' num2str(dv(i,1))]); 
            mkdir([datapath '\' buoy_info.name '\mat_archive\' num2str(dv(i,1))]); 
            check(i,1) = 0; 
        else
            check(i,1) = 1; 
        end
    end    
end

end




