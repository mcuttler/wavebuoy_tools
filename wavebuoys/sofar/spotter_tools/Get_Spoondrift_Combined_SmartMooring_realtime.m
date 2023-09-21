%% Get Spoondrift Buoy Data

% Code for Sofar Smart Moorings - can be wave (parameters or spectral) +
% temp sensors or pressure sensors

% AQL token: a1b3c0dbaa16bb21d5f0befcbcca51
% Please don't use the latest-data endpoint
% Instead use the sensor-data endpoint rather than the wave-data endpoint


%%
function [Spotter] = Get_Spoondrift_Combined_SmartMooring_realtime(buoy_info, limit);

%re-code so that it just grabs the 'limit' for waves, and the last 1
import matlab.net.*
import matlab.net.http.*
header = matlab.net.http.HeaderField('token',buoy_info.sofar_token,'spotterId',buoy_info.serial);
r = RequestMessage('GET', header);
%wave data
uri_waves= URI(['https://api.sofarocean.com/api/wave-data?spotterId=' buoy_info.serial...
    '&includeSurfaceTempData=true&includeWindData=true&limit=' num2str(limit)]);
resp_waves = send(r,uri_waves);
status = resp_waves.StatusCode;
disp([status]); 


tstart = datestr(datenum(resp_waves.Body.Data.data.waves(1).timestamp,'yyyy-mm-ddTHH:MM:SS') - datenum(0,0,0,12,0,0),30); 
tend = datestr(datenum(resp_waves.Body.Data.data.waves(end).timestamp,'yyyy-mm-ddTHH:MM:SS')+ datenum(0,0,0,2,0,0),30); 
startDate = [tstart 'Z']; 
endDate = [tend 'Z']; 
uri_sensor= URI(['https://api.sofarocean.com/api/sensor-data?spotterId=' buoy_info.serial '&startDate=' startDate '&endDate=' endDate]); 
resp_sensor = send(r,uri_sensor);
status = resp_sensor.StatusCode;
disp([status]); 


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
        for jj = 1:length(fields); 
            data.(fields{jj}) = ones(size(Spotter.time,1),1).*nan; 
        end
        data.time = Spotter.wind_time; 
        for j = 1:n
           dum = find(Spotter.time==Spotter.wind_time(j)); 
           if isempty(dum)
                data.serialID{j,1} = buoy_info.serial;                 
                for jj = 1:length(fields)
                    data.(fields{jj})(j,1) = nan;
                end
           else
               data.serialID{j,1} = buoy_info.serial;                 
               for jj = 1:length(fields)
                    data.(fields{jj})(j,1) = Spotter.(fields{jj})(dum,1);
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
        for jj = 1:length(fields); 
            data.(fields{jj}) = ones(size(Spotter.time,1),1).*nan; 
        end
        data.wind_time = Spotter.time; 
        for j = 1:m
            dum = find(Spotter.wind_time==Spotter.time(j)); 
            if isempty(dum)                                
                for jj = 1:length(fields)
                    data.(fields{jj})(j,1) = nan;
                end
            else               
                for jj = 1:length(fields)
                    data.(fields{jj})(j,1) = Spotter.(fields{jj})(dum,1);
                end
            end
        end
        fields = {'wind_time';'wind_speed';'wind_dir';'wind_seasurfaceId'}; 
        for jj = 1:length(fields)
            Spotter.(fields{jj}) = data.(fields{jj}); 
        end      
    end
end
%% Get smart mooring data --- temperature 
 

%check for temperature data
%assume surface and bottom sensor   
Spotter.temp_time = []; 
Spotter.surf_temp = []; 
Spotter.bott_temp = []; 
Spotter.pressure =[]; 
Spotter.pressure_std = []; 
Spotter.press_time = []; 
Spotter.press_std_time=[]; 

if ~isempty(resp_sensor.Body.Data.data)    
    for j = 1:size(resp_sensor.Body.Data.data,1)
        if strcmp(resp_sensor.Body.Data.data(j).unit_type,'temperature')
            if resp_sensor.Body.Data.data(j).sensorPosition==1
                Spotter.surf_temp = [Spotter.surf_temp; resp_sensor.Body.Data.data(j).value];                 
                Spotter.temp_time = [Spotter.temp_time; datenum(resp_sensor.Body.Data.data(j).timestamp,'yyyy-mm-ddTHH:MM:SS')]; 
            elseif resp_sensor.Body.Data.data(j).sensorPosition==2
                Spotter.bott_temp = [Spotter.bott_temp; resp_sensor.Body.Data.data(j).value]; 
            else
                Spotter.surf_temp = [Spotter.surf_temp; NaN];
                Spotter.bott_temp = [Spotter.bott_temp; NaN]; 
                Spotter.temp_time = [Spotter.temp_time; datenum(resp_sensor.Body.Data.data(j).timestamp,'yyyy-mm-ddTHH:MM:SS')];
            end
        elseif strcmp(resp_sensor.Body.Data.data(j).unit_type,'pressure')
            %check whether mean or std
            if contains(resp_sensor.Body.Data.data(j).data_type_name,'mean')                
                Spotter.press_time = [Spotter.press_time; datenum(resp_sensor.Body.Data.data(j).timestamp,'yyyy-mm-ddTHH:MM:SS')]; 
                %pressure recorded in micro-bar so divide by 1000000 to get to dbar
                if ~isempty(resp_sensor.Body.Data.data(j).value)
                    Spotter.pressure = [Spotter.pressure; resp_sensor.Body.Data.data(j).value/100000]; 
                else
                    Spotter.pressure = [Spotter.pressure; nan]; 
                end
            else
                Spotter.press_std_time = [Spotter.press_std_time; datenum(resp_sensor.Body.Data.data(j).timestamp,'yyyy-mm-ddTHH:MM:SS')]; 
                %pressure recorded in micro-bar so divide by 100000 to get to dbar
                if ~isempty(resp_sensor.Body.Data.data(j).value)
                    Spotter.pressure_std = [Spotter.pressure_std; resp_sensor.Body.Data.data(j).value/100000]; 
                else
                    Spotter.pressure_std = [Spotter.pressure_std; nan];
                end
            end
        end
    end
%if no sensor data, act like normal wave buoy
else
    Spotter.temp_time = Spotter.time; 
    Spotter.press_time = Spotter.time;
    Spotter.surf_temp = ones(size(Spotter.time,1),1).*-9999; 
    Spotter.bott_temp = ones(size(Spotter.time,1),1).*-9999; 
    Spotter.pressure = ones(size(Spotter.time,1),1).*-9999; 
    Spotter.pressure_std =ones(size(Spotter.time,1),1).*-9999; 
end        

%check temperature 
if isempty(Spotter.surf_temp)&&isempty(Spotter.bott_temp)
    Spotter.temp_time = Spotter.time; 
    Spotter.surf_temp = ones(size(Spotter.time,1),1).*-9999;    
    Spotter.bott_temp = ones(size(Spotter.time,1),1).*-9999; 
elseif ~isempty(Spotter.surf_temp)&&isempty(Spotter.bott_temp)
    Spotter.bott_temp = ones(size(Spotter.temp_time,1),1).*-9999; 
end



end









