%test for aqualink
clear; clc; 

SpotterID = 'SPOT-0936';
limit = 2; 
import matlab.net.*
import matlab.net.http.*
header = matlab.net.http.HeaderField('token','a1b3c0dbaa16bb21d5f0befcbcca51','spotterId',SpotterID);
r = RequestMessage('GET', header);
%wave data
uri_waves= URI(['https://api.sofarocean.com/api/wave-data?spotterId=' SpotterID...
    '&includeSurfaceTempData=true&includeWindData=true&limit=' num2str(limit)]);
resp_waves = send(r,uri_waves);
status = resp_waves.StatusCode;
disp(status)
for i = 1:size(resp_waves.Body.Data.data.waves,1); 
    waves.time(i,1) = datenum(resp_waves.Body.Data.data.waves(i).timestamp,'yyyy-mm-ddTHH:MM:SS'); 
    waves.hsig(i,1) = resp_waves.Body.Data.data.waves(i).significantWaveHeight; 
end

%sensor (temp or pressure) data
utc_offset = 8; 
tstart = datestr(waves.time(end) - datenum(0,0,0,4,0,0),30); 
tend = datestr(waves.time(end)+datenum(0,0,0,0,10,0),30); 
startDate = [tstart 'Z']; 
endDate = [tend 'Z']; 



uri_sensor= URI(['https://api.sofarocean.com/api/sensor-data?spotterId=' SpotterID '&startDate=' startDate '&endDate=' endDate]); 
resp_sensor = send(r,uri_sensor);
status = resp_sensor.StatusCode;
disp(status)

%temp data
temp = struct('surf_time',[],'surf_temp',[],'bott_time',[],'bott_temp',[]); 

for i = 1:size(resp_sensor.Body.Data.data,1)   
    if resp_sensor.Body.Data.data(i).sensorPosition==1
        temp.surf_time = [temp.surf_time;  datenum(resp_sensor.Body.Data.data(i).timestamp,'yyyy-mm-ddTHH:MM:SS')]; 
        temp.surf_temp = [temp.surf_temp; resp_sensor.Body.Data.data(i).value]; 
    elseif resp_sensor.Body.Data.data(i).sensorPosition==2
        temp.bott_time = [temp.bott_time;  datenum(resp_sensor.Body.Data.data(i).timestamp,'yyyy-mm-ddTHH:MM:SS')]; 
        temp.bott_temp = [temp.bott_temp; resp_sensor.Body.Data.data(i).value]; 
    end
end

