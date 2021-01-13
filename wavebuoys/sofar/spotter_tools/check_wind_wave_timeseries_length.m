[m,~] = size(SpotData.time); 
[n,~] = size(SpotData.wind_time); 

if m~=n
    %missing wind data point
    if m>n
        idx_check = find(diff(SpotData.wind_time)>0.04); 
        SpotData.wind_time = [SpotData.wind_time(1:idx_check); SpotData.time(idx_check+1); SpotData.wind_time(idx_check+1:end)];
        SpotData.wind_speed = [SpotData.wind_speed(1:idx_check); nan; SpotData.wind_speed(idx_check+1:end)]; 
        SpotData.wind_dir = [SpotData.wind_dir(1:idx_check); nan; SpotData.wind_dir(idx_check+1:end)]; 
        SpotData.wind_seasurfaceId = [SpotData.wind_seasurfaceId(1:idx_check); nan; SpotData.wind_seasurfaceId(idx_check+1:end)]; 
    %missing wave data point
    elseif n>m
        idx_check = find(diff(SpotData.time)>0.04); 
        SpotData.time = [SpotData.time(1:idx_check); SpotData.wind_time(idx_check+1); SpotData.time(idx_check+1:end)];
        SpotData.serialID = [SpotData.serialID(1:idx_check); SpotData.serialID(1); SpotData.serialID(idx_check+1:end)]; 
        SpotData.hsig = [SpotData.hsig(1:idx_check); nan; SpotData.hsig(idx_check+1:end)]; 
        SpotData.tp = [SpotData.tp(1:idx_check); nan; SpotData.tp(idx_check+1:end)]; 
        SpotData.tm = [SpotData.tm(1:idx_check); nan; SpotData.tm(idx_check+1:end)]; 
        SpotData.dp = [SpotData.dp(1:idx_check); nan; SpotData.dp(idx_check+1:end)]; 
        SpotData.dpspr = [SpotData.dpspr(1:idx_check); nan; SpotData.dpspr(idx_check+1:end)]; 
        SpotData.dm = [SpotData.dm(1:idx_check); nan; SpotData.dm(idx_check+1:end)]; 
        SpotData.dmspr = [SpotData.dmspr(1:idx_check); nan; SpotData.dmspr(idx_check+1:end)]; 
        SpotData.lat = [SpotData.lat(1:idx_check); nan; SpotData.lat(idx_check+1:end)]; 
        SpotData.lon = [SpotData.lon(1:idx_check); nan; SpotData.lon(idx_check+1:end)];                 
    end
end

    
