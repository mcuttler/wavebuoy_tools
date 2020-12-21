%% Get Spoondrift Buoy Data

% Accesses Spoondrift API to get most recent data from specified Spotter
% SpotterID is string of Spotter name - i.e. 'SPOT-0093'

%v1 Nov 2018
%M Cuttler

%v2 - May 2020
%   finished writing code to archive Bremer and Perth Canyon data
%     M Cuttler

%%
function [Spot_history] = Get_Spoondrift_Data_history_fullwaves_MC(SpotterID);

import matlab.net.*
import matlab.net.http.*
header = matlab.net.http.HeaderField('token','e0eb70b6d9e0b5e00450929139ea34','spotterId',SpotterID);
r = RequestMessage('GET', header);
uri = URI(['https://wavefleet.spoondriftspotter.co/api/wave-data?spotterId=' SpotterID '&includeDirectionalMoments=true']);
resp = send(r,uri);
status = resp.StatusCode;

disp(status);
[m,~] = size(resp.Body.Data.data.waves);
for i = 1:m
    dum = resp.Body.Data.data.waves(i);
    
    Spot_history(i,1) = datenum(dum.timestamp,'yyyy-mm-ddTHH:MM:SS'); 
    Spot_history(i,2) = dum.latitude; 
    Spot_history(i,3) = dum.longitude;
    Spot_history(i,4) = dum.significantWaveHeight;
    Spot_history(i,5) = dum.peakPeriod;
    Spot_history(i,6) = dum.meanPeriod;
    Spot_history(i,7) = dum.peakDirection;
    Spot_history(i,8) = dum.peakDirectionalSpread;
    Spot_history(i,9) = dum.meanDirection;
    Spot_history(i,10) = dum.meanDirectionalSpread;  
    
    dum2 = resp.Body.Data.data
    Spot_history(i,11) = resp.Body.Data.data.frequencyData.a1;
Spotter.a2 = resp.Body.Data.data.frequencyData.a2;
Spotter.b1 = resp.Body.Data.data.frequencyData.b1;
Spotter.b2 = resp.Body.Data.data.frequencyData.b2;
Spotter.varianceDensity = resp.Body.Data.data.frequencyData.varianceDensity;
Spotter.frequency = resp.Body.Data.data.frequencyData.frequency;
Spotter.df = resp.Body.Data.data.frequencyData.df;
Spotter.directionalSpread = resp.Body.Data.data.frequencyData.directionalSpread;
Spotter.direction = resp.Body.Data.data.frequencyData.direction;
end
end










