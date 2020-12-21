%% Get Spoondrift Buoy Data

% Accesses Spoondrift API to get most recent data from specified Spotter
% SpotterID is string of Spotter name - i.e. 'SPOT-0093'

%v1 Nov 2018
%M Cuttler

%%
function [Spotter] = Get_Spoondrift_Data_realtime(SpotterID,limit);

import matlab.net.*
import matlab.net.http.*
header = matlab.net.http.HeaderField('token','e0eb70b6d9e0b5e00450929139ea34','spotterId',SpotterID);
r = RequestMessage('GET', header);
uri = URI(['https://wavefleet.spoondriftspotter.co/api/wave-data?spotterId=' SpotterID...
    '&includeSurfaceTempData=true&includeWindData=true&limit=' num2str(limit)]);
resp = send(r,uri);
status = resp.StatusCode;

disp(status);

if isstruct(resp.Body.Data.data.waves)
    for j = 1:size(resp.Body.Data.data.waves)
        Spotter.hs(j,1) = resp.Body.Data.data.waves(j).significantWaveHeight;
        Spotter.tp(j,1) = resp.Body.Data.data.waves(j).peakPeriod;
        Spotter.tm(j,1) = resp.Body.Data.data.waves(j).meanPeriod;
        Spotter.dp(j,1) = resp.Body.Data.data.waves(j).peakDirection;
        Spotter.pkspr(j,1) = resp.Body.Data.data.waves(j).peakDirectionalSpread;
        Spotter.dm(j,1) = resp.Body.Data.data.waves(j).meanDirection;
        Spotter.meanspr(j,1) = resp.Body.Data.data.waves(j).meanDirectionalSpread;
        Spotter.time(j,1) = datenum(resp.Body.Data.data.waves(j).timestamp,'yyyy-mm-ddTHH:MM:SS');
        Spotter.lat(j,1) = resp.Body.Data.data.waves(j).latitude;
        Spotter.lon(j,1) = resp.Body.Data.data.waves(j).longitude;
    end
end

if isstruct(resp.Body.Data.data.surfaceTemp)
    for j = 1:size(resp.Body.Data.data.surfaceTemp)
        Spotter.temp(j,1) = resp.Body.Data.data.surfaceTemp(j).degrees;
        Spotter.temp_time(j,1) = datenum(resp.Body.Data.data.surfaceTemp(j).timestamp,'yyyy-mm-ddTHH:MM:SS');
    end
end

if isstruct(resp.Body.Data.data.wind)    
    for j = 1:size(resp.Body.Data.data.wind)
        Spotter.wind_speed(j,1) = resp.Body.Data.data.wind(j).speed;
        Spotter.wind_dir(j,1) = resp.Body.Data.data.wind(j).direction;
        Spotter.wind_time(j,1) = datenum(resp.Body.Data.data.wind(j).timestamp,'yyyy-mm-ddTHH:MM:SS');
        Spotter.wind_seasurfaceId(j,1) = resp.Body.Data.data.wind(j).seasurfaceId;
    end
end
end









