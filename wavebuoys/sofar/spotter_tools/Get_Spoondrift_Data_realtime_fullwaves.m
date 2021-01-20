%% Get Spoondrift Buoy Data

% Accesses SoFar Ocean API to get most recent data from specified Spotter
% SpotterID is string of Spotter name - i.e. 'SPOT-0093'

%v1 Nov 2018

%v2 April 2019 - updated from Get_Spoondrift_Data_realtime to include
%spectral data

%M Cuttler

%%
function [Spotter] = Get_Spoondrift_Data_realtime_fullwaves(SpotterID, limit);

import matlab.net.*
import matlab.net.http.*
header = matlab.net.http.HeaderField('token','e0eb70b6d9e0b5e00450929139ea34','spotterId',SpotterID);
r = RequestMessage('GET', header);

uri = URI(['https://api.sofarocean.com/api/wave-data?spotterId=' SpotterID...
    '&includeSurfaceTempData=true&includeWindData=true&includeFrequencyData=true&includeDirectionalMoments=true&limit=' num2str(limit)]);

resp = send(r,uri);
status = resp.StatusCode;

disp(status);

if isfield(resp.Body.Data.data,'waves')
    for j = 1:size(resp.Body.Data.data.waves)
        Spotter.serialID{j,1} = SpotterID; 
         Spotter.time(j,1) = datenum(resp.Body.Data.data.waves(j).timestamp,'yyyy-mm-ddTHH:MM:SS');
        Spotter.hsig(j,1) = resp.Body.Data.data.waves(j).significantWaveHeight;        
        Spotter.tp(j,1) = resp.Body.Data.data.waves(j).peakPeriod;
        Spotter.tm(j,1) = resp.Body.Data.data.waves(j).meanPeriod;
        Spotter.dp(j,1) = resp.Body.Data.data.waves(j).peakDirection;
        Spotter.dpspr(j,1) = resp.Body.Data.data.waves(j).peakDirectionalSpread;
        Spotter.dm(j,1) = resp.Body.Data.data.waves(j).meanDirection;
        Spotter.dmspr(j,1) = resp.Body.Data.data.waves(j).meanDirectionalSpread;       
        Spotter.lat(j,1) = resp.Body.Data.data.waves(j).latitude;
        Spotter.lon(j,1) = resp.Body.Data.data.waves(j).longitude;
    end
end

%check for temperature data
if isfield(resp.Body.Data.data,'surfaceTemp')
    for j = 1:size(resp.Body.Data.data.surfaceTemp)
        Spotter.surf_temp(j,1) = resp.Body.Data.data.surfaceTemp(j).degrees;
        Spotter.temp_time(j,1) = datenum(resp.Body.Data.data.surfaceTemp(j).timestamp,'yyyy-mm-ddTHH:MM:SS');
    end
    %check for bottom temperature data
    if isfield(resp.Body.Data.data,'bottomTemp')
        for j = 1:size(resp.Body.Data.data.bottomTemp)
            Spotter.bott_temp(j,1) = resp.Body.Data.data.bottomTemp(j).degrees;
        end
    else
        for j = 1:size(resp.Body.Data.data.surfaceTemp)
            Spotter.bott_temp(j,1)= -9999; 
        end
    end               
end
%

%check for wind data 
if isfield(resp.Body.Data.data,'wind')
    for j = 1:size(resp.Body.Data.data.wind)
        Spotter.wind_speed(j,1) = resp.Body.Data.data.wind(j).speed;
        Spotter.wind_dir(j,1) = resp.Body.Data.data.wind(j).direction;
        Spotter.wind_time(j,1) = datenum(resp.Body.Data.data.wind(j).timestamp,'yyyy-mm-ddTHH:MM:SS');
        Spotter.wind_seasurfaceId(j,1) = resp.Body.Data.data.wind(j).seasurfaceId;
    end
end

%Spectral variables
if isfield(resp.Body.Data.data,'frequencyData')
    for j = 1:size(resp.Body.Data.data.frequencyData)
        Spotter.a1 = resp.Body.Data.data.frequencyData.a1';
        Spotter.a2 = resp.Body.Data.data.frequencyData.a2';
        Spotter.b1 = resp.Body.Data.data.frequencyData.b1';
        Spotter.b2 = resp.Body.Data.data.frequencyData.b2';
        Spotter.varianceDensity = resp.Body.Data.data.frequencyData.varianceDensity';
        Spotter.frequency = resp.Body.Data.data.frequencyData.frequency';
        Spotter.df = resp.Body.Data.data.frequencyData.df';
        Spotter.directionalSpread = resp.Body.Data.data.frequencyData.directionalSpread';
        Spotter.direction = resp.Body.Data.data.frequencyData.direction';
    end
end

end









