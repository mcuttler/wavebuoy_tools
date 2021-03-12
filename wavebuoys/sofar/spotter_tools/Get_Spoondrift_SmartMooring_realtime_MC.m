%% Get Spoondrift Buoy Data

% Code for Sofar Smart Moorings - can be wave (parameters or spectral) +
% temp sensors or pressure sensors

% AQL token: a1b3c0dbaa16bb21d5f0befcbcca51
% Please don't use the latest-data endpoint
% Instead use the sensor-data endpoint rather than the wave-data endpoint


%%
function [Spotter,flag] = Get_Spoondrift_SmartMooring_realtime_MC(buoy_info, limit);

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


tstart = datestr(datenum(resp_waves.Body.Data.data.waves(end).timestamp,'yyyy-mm-ddTHH:MM:SS') - datenum(0,0,0,3,0,0),30); 
tend = datestr(datenum(resp_waves.Body.Data.data.waves(end).timestamp,'yyyy-mm-ddTHH:MM:SS'),30); 
startDate = [tstart 'Z']; 
endDate = [tend 'Z']; 

uri_sensor= URI(['https://api.sofarocean.com/api/sensor-data?spotterId=' buoy_info.serial '&startDate=' startDate '&endDate=' endDate]); 
resp_sensor = send(r,uri_sensor);
status = resp_sensor.StatusCode;
if ~isempty(resp_sensor.Body.Data.data)
    disp([status]); 
else
    disp(['No sensor data for that time period']); 
end

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

%% TEMPERATURE
%check for temperature data
%assume surface and bottom sensor   
Spotter.temp_time = []; 
Spotter.surf_temp = []; 
Spotter.bott_temp =[]; 
Spotter.bott_temp_time = []; 
if ~isempty(resp_sensor.Body.Data.data)    
    for j = 1:size(resp_sensor.Body.Data.data,1)
        if resp_sensor.Body.Data.data(j).sensorPosition==1
            Spotter.surf_temp = [Spotter.surf_temp; resp_sensor.Body.Data.data(j).value]; 
            Spotter.temp_time = [Spotter.temp_time; datenum(resp_sensor.Body.Data.data(j).timestamp,'yyyy-mm-ddTHH:MM:SS')]; 
        elseif resp_sensor.Body.Data.data(j).sensorPosition==2 
            Spotter.bott_temp_time = [Spotter.bott_temp_time; datenum(resp_sensor.Body.Data.data(j).timestamp,'yyyy-mm-ddTHH:MM:SS')]; 
            Spotter.bott_temp = [Spotter.bott_temp; resp_sensor.Body.Data.data(j).value]; 
        end
    end
end

%make sure bottom and surface timestamps are same
if length(Spotter.temp_time)~=length(Spotter.bott_temp_time)
    if length(Spotter.temp_time)>length(Spotter.bott_temp_time)
        for j = 1:length(Spotter.temp_time)
            try
                Spotter.temp_time(j,1)==Spotter.bott_temp_time(j,1);
            catch
                Spotter.bott_temp(j,1)=nan; 
            end
        end
        Spotter = rmfield(Spotter, 'bott_temp_time');     
    elseif length(Spotter.temp_temp)<length(Spotter.bott_temp_time)
        for j = 1:length(Spotter.bott_temp_time)
             try
                Spotter.bott_time(j,1)==Spotter.temp_time(j,1);
            catch
                Spotter.surf_temp(j,1)=nan; 
             end
        end
        Spotter.temp_time = Spotter.bott_temp_time;         
    end
else
    Spotter = rmfield(Spotter, 'bott_temp_time');     
end
        


%% check that mooring data has correc time stamps to continue
% t1 = datevec(Spotter.time(end)-datenum(0,0,0,1,40,0)); 
% t2 = datevec(Spotter.time(end)); 
% dv = datevec(Spotter.temp_time); 
% t1idx = find(dv(:,1)==t1(1)&dv(:,2)==t1(2)&dv(:,3)==t1(3)&dv(:,4)==t1(4)&dv(:,5)==t1(5)&dv(:,6)==t1(6)); 
% t2idx = find(dv(:,1)==t2(1)&dv(:,2)==t2(2)&dv(:,3)==t2(3)&dv(:,4)==t2(4)&dv(:,5)==t2(5)&dv(:,6)==t2(6)); 
%     
% if ~isempty(t1idx)&~isempty(t2idx)
%     flag = 1; 
%     Spotter.temp_time = Spotter.temp_time(t1idx:t2idx); 
%     Spotter.surf_temp = Spotter.surf_temp(t1idx:t2idx); 
%     Spotter.bott_temp = Spotter.bott_temp(t1idx:t2idx);                             
% else
%     t1idx = find(abs(Spotter.temp_time-datenum(t1))==min(abs(Spotter.temp_time-datenum(t1))));
%     t2idx = find(abs(Spotter.temp_time-datenum(t2))==min(abs(Spotter.temp_time-datenum(t2))));
%     min_diff = 10/(60*24); 
%     if (Spotter.temp_time(t1idx)-datenum(t1))<min_diff & (Spotter.temp_time(t2idx)-datenum(t2))<min_diff &t1idx~=t2idx
%         flag = 1; 
%         Spotter.temp_time = Spotter.temp_time(t1idx:t2idx); 
%         Spotter.surf_temp = Spotter.surf_temp(t1idx:t2idx); 
%         Spotter.bott_temp = Spotter.bott_temp(t1idx:t2idx);                             
%     else
%         flag = 0;
%     end   
%   
% end   
%     
flag = 1; 

end









