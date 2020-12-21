%% Get Spoondrift Buoy Data

% Accesses SoFar Ocean API to get most recent data from specified Spotter
% SpotterID is string of Spotter name - i.e. 'SPOT-0093'

%v1 Nov 2018

%v2 April 2019 - updated from Get_Spoondrift_Data_realtime to include
%spectral data

%M Cuttler

%%
function [Spotter] = Get_Spoondrift_Data_realtime_fullwaves(SpotterID);

import matlab.net.*
import matlab.net.http.*
header = matlab.net.http.HeaderField('token','e0eb70b6d9e0b5e00450929139ea34','spotterId',SpotterID);
r = RequestMessage('GET', header);
uri = URI(['https://api.sofarocean.com/api/latest-data?spotterId=' SpotterID '&includeDirectionalMoments=true']);
resp = send(r,uri);
status = resp.StatusCode;

disp(status);
%Buoy info
Spotter.time = datenum(resp.Body.Data.data.waves.timestamp,'yyyy-mm-ddTHH:MM:SS');
Spotter.lat = [resp.Body.Data.data.waves.latitude]';
Spotter.lon = [resp.Body.Data.data.waves.longitude]';

%Parametric variables
Spotter.hsig = [resp.Body.Data.data.waves.significantWaveHeight]';
Spotter.tp = [resp.Body.Data.data.waves.peakPeriod]';
Spotter.tm = [resp.Body.Data.data.waves.meanPeriod]';
Spotter.dp = [resp.Body.Data.data.waves.peakDirection]';
Spotter.dpspr = [resp.Body.Data.data.waves.peakDirectionalSpread]';
Spotter.dm = [resp.Body.Data.data.waves.meanDirection]';
Spotter.dmspr = [resp.Body.Data.data.waves.meanDirectionalSpread]';

%Spectral variables
Spotter.a1 = resp.Body.Data.data.frequencyData.a1;
Spotter.a2 = resp.Body.Data.data.frequencyData.a2;
Spotter.b1 = resp.Body.Data.data.frequencyData.b1;
Spotter.b2 = resp.Body.Data.data.frequencyData.b2;
Spotter.varianceDensity = resp.Body.Data.data.frequencyData.varianceDensity;
Spotter.frequency = resp.Body.Data.data.frequencyData.frequency;
Spotter.df = resp.Body.Data.data.frequencyData.df;
Spotter.directionalSpread = resp.Body.Data.data.frequencyData.directionalSpread;
Spotter.direction = resp.Body.Data.data.frequencyData.direction;

end









