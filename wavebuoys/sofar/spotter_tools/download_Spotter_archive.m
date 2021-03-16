%% download sofar archive

function [Spot_archive] = download_Spotter_archive(buoy_info, start_date, end_date)
%get monthly time vector from start/end dates
t = datevec(start_date:end_date); 
t = unique(t(:,1:2),'rows'); 
t = datenum(t(:,1), t(:,2),1); 

for i = 1:size(t,1)
    t1 = datestr(
import matlab.net.*
import matlab.net.http.*
header = matlab.net.http.HeaderField('token',buoy_info.sofar_token,'spotterId',buoy_info.serial);
r = RequestMessage('GET', header);


uri = URI(['https://api.sofarocean.com/api/wave-data?spotterId=' buoy_info.serial...
    '&includeSurfaceTempData=true&includeWindData=true&limit=' num2str(limit)]);

resp = send(r,uri);
status = resp.StatusCode;

tstart = datestr(datenum(resp_waves.Body.Data.data.waves(end).timestamp,'yyyy-mm-ddTHH:MM:SS') - datenum(0,0,0,3,0,0),30); 
tend = datestr(datenum(resp_waves.Body.Data.data.waves(end).timestamp,'yyyy-mm-ddTHH:MM:SS'),30); 
startDate = [tstart 'Z']; 
endDate = [tend 'Z']; 
uri_sensor= URI(['https://api.sofarocean.com/api/sensor-data?spotterId=' buoy_info.serial '&startDate=' startDate '&endDate=' endDate]);


