%% archive buoy data to text file

function [] = realtime_archive_text(buoy_info, data); 

%determine if path for current day exists
t1 = datenum(data.time(1)); 
dv = datevec(t1); 

year_path =[buoy_info.archive_path '\' buoy_info.name '\text_archive\' num2str(dv(1))]; 
month_path = [buoy_info.archive_path '\' buoy_info.name '\text_archive\' num2str(dv(1)) '\' num2str(dv(2),'%02d')]; 
day_path = [buoy_info.archive_path '\' buoy_info.name '\text_archive\' num2str(dv(1)) '\' num2str(dv(2),'%02d') '\' num2str(dv(3),'%02d')];

            
        
        

    
    
    

