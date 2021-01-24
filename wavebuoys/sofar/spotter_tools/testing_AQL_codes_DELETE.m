%test for aqualink
clear; clc; 

SpotterID = 'SPOT-0936';
limit = 10; 
import matlab.net.*
import matlab.net.http.*
header = matlab.net.http.HeaderField('token','a1b3c0dbaa16bb21d5f0befcbcca51','spotterId',SpotterID);
r = RequestMessage('GET', header);
startDate = [datestr(datenum(now)-datenum(0,0,7,8,0,0),30),'Z'];
endDate = [datestr(datenum(now),30),'Z'];

uri_sensor= URI(['https://api.sofarocean.com/api/sensor-data?spotterId=' SpotterID '&startDate=' startDate '&endDate=' endDate]); 
uri_waves= URI(['https://api.sofarocean.com/api/wave-data?spotterId=' SpotterID...
    '&includeSurfaceTempData=true&includeWindData=true&limit=' num2str(limit)]);

resp_sensor = send(r,uri_sensor);
status = resp_sensor.StatusCode;
disp(status)

resp_waves = send(r,uri_waves);
status = resp_waves.StatusCode;
disp(status)