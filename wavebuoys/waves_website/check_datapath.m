%% check if path exists and make path if not for data archive and load

function [check] = check_archive_path(datapath,time); 

dv = datevec(time); 

if exist([datapath '\' dv(1)])
    if exist([datapath '\' dv(1) '\' dv(2)])
        check=1; 
    else
        mkdir([datapath '\' dv(1) '\' dv(2)])
        check=1; 
    end
else
    mkdir([datapath '\' dv(1) '\' dv(2)])
    check=1; 
end

end
