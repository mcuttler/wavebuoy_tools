%% download sofar archive

function [Spot_archive] = download_Spotter_archive(buoy_info, start_date, end_date)
%get monthly time vector from start/end dates
t = datevec(start_date:end_date); 
t = unique(t(:,1:2),'rows'); 

for i = 1:size(t,1)
    tstart = datestr(datenum(t(i,1), t(i,2), 1),30); 
    tend = datestr(datenum(t(i,1), t(i,2), eomday(t(i,1), t(i,2)),23,59,59),30); 
    startDate = [tstart 'Z']; 
    endDate = [tend 'Z'];     
    
    import matlab.net.*
    import matlab.net.http.*
    header = matlab.net.http.HeaderField('token',buoy_info.sofar_token,'spotterId',buoy_info.serial);
    r = RequestMessage('GET', header);    
    
    uri = URI(['https://api.sofarocean.com/api/wave-data?spotterId=' buoy_info.serial '&startDate=' startDate '&endDate=' endDate...
    '&includeSurfaceTempData=true&includeWindData=true&includeFrequencyData=true&includeDirectionalMoments=true&limit=500']); 
    
    resp = send(r,uri);
    status = resp.StatusCode;
end


 



