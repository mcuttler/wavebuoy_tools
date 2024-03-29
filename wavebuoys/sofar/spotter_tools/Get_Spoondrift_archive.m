%% Get Spoondrift Buoy Data

% Code for Sofar Smart Moorings - can be wave (parameters or spectral) +
% temp sensors or pressure sensors

% AQL token: a1b3c0dbaa16bb21d5f0befcbcca51
% Please don't use the latest-data endpoint
% Instead use the sensor-data endpoint rather than the wave-data endpoint


%%
function [Spotter,flag] = Get_Spoondrift_archive(buoy_info, start_time, end_time);

import matlab.net.*
import matlab.net.http.*
header = matlab.net.http.HeaderField('token',buoy_info.sofar_token,'spotterId',buoy_info.serial);
r = RequestMessage('GET', header);
%wave data
tstart = datestr(start_time,30); 
tend = datestr(end_time,30); 
startDate = [tstart 'Z']; 
endDate = [tend 'Z']; 

uri_waves= URI(['https://api.sofarocean.com/api/wave-data?spotterId=' buoy_info.serial '&startDate=' startDate '&endDate=' endDate...
    '&includeSurfaceTempData=true&includeWindData=true']); 
resp_waves = send(r,uri_waves);
status = resp_waves.StatusCode;
disp([status]); 


tstart = datestr(datenum(resp_waves.Body.Data.data.waves(end).timestamp,'yyyy-mm-ddTHH:MM:SS') - datenum(0,0,0,3,0,0),30); 
tend = datestr(datenum(resp_waves.Body.Data.data.waves(end).timestamp,'yyyy-mm-ddTHH:MM:SS'),30); 
startDate = [tstart 'Z']; 
endDate = [tend 'Z']; 


%% WAVES AND WIND
%check for wave parameters
if isfield(resp_waves.Body.Data.data,'waves')
    for j = 1:size(resp_waves.Body.Data.data.waves)
        Spotter.serialID{j,1} = buoy_info.serial; 
        Spotter.time(j,1) = datenum(resp_waves.Body.Data.data.waves(j).timestamp,'yyyy-mm-ddTHH:MM:SS');
        Spotter.hsig(j,1) = resp_waves.Body.Data.data.waves(j).significantWaveHeight;        
        Spotter.tp(j,1) = resp_waves.Body.Data.data.waves(j).peakPeriod;
        Spotter.tm(j,1) = resp_waves.Body.Data.data.waves(j).meanPeriod;
        Spotter.dp(j,1) = resp_waves.Body.Data.data.waves(j).peakDirection;
        Spotter.dpspr(j,1) = resp_waves.Body.Data.data.waves(j).peakDirectionalSpread;
        Spotter.dm(j,1) = resp_waves.Body.Data.data.waves(j).meanDirection;
        Spotter.dmspr(j,1) = resp_waves.Body.Data.data.waves(j).meanDirectionalSpread;       
        Spotter.lat(j,1) = resp_waves.Body.Data.data.waves(j).latitude;
        Spotter.lon(j,1) = resp_waves.Body.Data.data.waves(j).longitude;
    end
end


%check for wind data 
if isfield(resp_waves.Body.Data.data,'wind')
    for j = 1:size(resp_waves.Body.Data.data.wind)
        Spotter.wind_speed(j,1) = resp_waves.Body.Data.data.wind(j).speed;
        Spotter.wind_dir(j,1) = resp_waves.Body.Data.data.wind(j).direction;
        Spotter.wind_time(j,1) = datenum(resp_waves.Body.Data.data.wind(j).timestamp,'yyyy-mm-ddTHH:MM:SS');
        Spotter.wind_seasurfaceId(j,1) = resp_waves.Body.Data.data.wind(j).seasurfaceId;
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









