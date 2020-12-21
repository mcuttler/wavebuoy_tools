%% Get Spoondrift Buoy Data

% Accesses Spoondrift API to get most recent data from specified Spotter
% SpotterID is string of Spotter name - i.e. 'SPOT-0093'

%v1 Nov 2018
%M Cuttler

%%
function [Spotter] = Get_Spoondrift_Data_history(SpotterID);

import matlab.net.*
import matlab.net.http.*
header = matlab.net.http.HeaderField('token','e0eb70b6d9e0b5e00450929139ea34','spotterId',SpotterID);
r = RequestMessage('GET', header);
uri = URI(['https://wavefleet.spoondriftspotter.co/api/wave-data?spotterId=' SpotterID '&limit=500']);
resp = send(r,uri);
status = resp.StatusCode;

disp(status);
[m,~] = size(resp.Body.Data.data.waves)
for i = 1:m
    dum = resp.Body.Data.data.waves(i);
    
    out(i,1) = dum.significantWaveHeight;
    out(i,2) = dum.peakPeriod;
    out(i,3) = dum.meanPeriod;
    out(i,4) = dum.peakDirection;
    out(i,5) = dum.peakDirectionalSpread;
    out(i,6) = dum.meanDirection;
    out(i,7) = dum.meanDirectionalSpread;
    out(i,8) = datenum(
    
    Spotter.hsig = [resp.Body.Data.data.waves.significantWaveHeight]';
    Spotter.tp = [resp.Body.Data.data.waves.peakPeriod]';
    Spotter.tm = [resp.Body.Data.data.waves.meanPeriod]';
    Spotter.dp = [resp.Body.Data.data.waves.peakDirection]';
    Spotter.dpspr = [resp.Body.Data.data.waves.peakDirectionalSpread]';
    Spotter.dm = [resp.Body.Data.data.waves.meanDirection]';
    Spotter.dmspr = [resp.Body.Data.data.waves.meanDirectionalSpread]';
    Spotter.time = datenum(resp.Body.Data.data.waves.timestamp,'yyyy-mm-ddTHH:MM:SS');
    Spotter.lat = [resp.Body.Data.data.waves.latitude]';
    Spotter.lon = [resp.Body.Data.data.waves.longitude]';
end









