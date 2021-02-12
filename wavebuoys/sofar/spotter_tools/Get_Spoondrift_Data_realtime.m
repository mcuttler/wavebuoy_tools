%% Get Spoondrift Buoy Data

% Accesses Spoondrift API to get most recent data from specified Spotter
% SpotterID is string of Spotter name - i.e. 'SPOT-0093'

%v1 Nov 2018
%M Cuttler

% AQL token: a1b3c0dbaa16bb21d5f0befcbcca51
% Please don't use the latest-data endpoint
% Instead use the sensor-data endpoint rather than the wave-data endpoint


%%
function [Spotter] = Get_Spoondrift_Data_realtime(buoy_info,limit);

import matlab.net.*
import matlab.net.http.*
header = matlab.net.http.HeaderField('token',buoy_info.sofar_token,'spotterId',buoy_info.serial);
r = RequestMessage('GET', header);


uri = URI(['https://api.sofarocean.com/api/wave-data?spotterId=' buoy_info.serial...
    '&includeSurfaceTempData=true&includeWindData=true&limit=' num2str(limit)]);

resp = send(r,uri);
status = resp.StatusCode;

disp(status);

%check for wave parameters
if isfield(resp.Body.Data.data,'waves')
    for j = 1:size(resp.Body.Data.data.waves)
        Spotter.serialID{j,1} = buoy_info.serial; 
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

%check that wind and waves have same time, duplicate temp for the hour so
%it matches timestamps of wind and waves
[m,~] = size(Spotter.time); 
[n,~] = size(Spotter.wind_time); 
if m~=n  
    if n>m %missing waves
        data = Spotter; 
        fields = {'hsig';'tp';'tm';'dp';'dpspr';'dm';'dmspr';'lat';'lon'};                 
        for j = 1:n
           dum = find(Spotter.time==Spotter.wind_time(j)); 
           if isempty(dum)
                data.serialID{j,1} = buoy_info.serial; 
                data.time(j,1) = Spotter.wind_time(j); 
                for jj = 1:length(fields)
                    data.(fields{jj})(j,1) = nan;
                end
           else
               data.serialID{j,1} = buoy_info.serial;  
               data.time(j,1) = Spotter.wind_time(j);
               for jj = 1:length(fields)
                    data.(fields{jj})(j,1) = data.(fields{jj})(dum,1);
               end
           end
        end
        fields = {'time';'serialID';'hsig';'tp';'tm';'dp';'dpspr';'dm';'dmspr';'lat';'lon'}; 
        for jj = 1:length(fields)
            Spotter.(fields{jj}) = data.(fields{jj}); 
        end                         
                
    elseif m>n %missing wind
        data = Spotter; 
        fields = {'wind_speed';'wind_dir';'wind_seasurfaceId'};      
        for j = 1:m
            dum = find(Spotter.wind_time==Spotter.time(j)); 
            if isempty(dum)                
                data.wind_time(j,1) = Spotter.time(j); 
                for jj = 1:length(fields)
                    data.(fields{jj})(j,1) = nan;
                end
            else
               data.wind_time(j,1) = Spotter.time(j); 
                for jj = 1:length(fields)
                    data.(fields{jj})(j,1) = data.(fields{jj})(dum,1);
                end
            end
        end
        fields = {'wind_time';'wind_speed';'wind_dir';'wind_seasurfaceId'}; 
        for jj = 1:length(fields)
            Spotter.(fields{jj}) = data.(fields{jj}); 
        end      
    end
end


end









