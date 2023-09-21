%% Get Spoondrift Buoy Data

% Accesses SoFar Ocean API to get most recent data from specified Spotter
% SpotterID is string of Spotter name - i.e. 'SPOT-0093'

%v1 Nov 2018

%v2 April 2019 - updated from Get_Spoondrift_Data_realtime to include
%spectral data

%M Cuttler

%%
function [Spotter] = Get_Spoondrift_Data_realtime_fullwaves_hdr(buoy_info, limit);

import matlab.net.*
import matlab.net.http.*
header = matlab.net.http.HeaderField('token',buoy_info.sofar_token,'spotterId',buoy_info.serial);
r = RequestMessage('GET', header);

%get frequency data from HDR mode 
uri = URI(['https://api.sofarocean.com/api/wave-data?spotterId=' buoy_info.serial...
    '&includeSurfaceTempData=true&includeWindData=true&includeFrequencyData=true&includeDirectionalMoments=true&'...
    'processingSources=all&limit=' num2str(limit)]);

resp = send(r,uri);
status = resp.StatusCode;

disp(status);

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
if isfield(resp.Body.Data.data,'surfaceTemp')&~isempty(resp.Body.Data.data.surfaceTemp)
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
else
    Spotter.temp_time = Spotter.time; 
    Spotter.surf_temp = ones(size(Spotter.time,1),1).*-9999; 
    Spotter.bott_temp = ones(size(Spotter.time,1),1).*-9999; 
end

%check for wind data 
if isfield(resp.Body.Data.data,'wind')
    if isempty(resp.Body.Data.data.wind)
        for j = 1:size(resp.Body.Data.data.waves)
            Spotter.wind_speed(j,1) = nan;
            Spotter.wind_dir(j,1) = nan;
            Spotter.wind_time(j,1) = datenum(resp.Body.Data.data.waves(j).timestamp,'yyyy-mm-ddTHH:MM:SS');
            Spotter.wind_seasurfaceId(j,1) = nan;
        end
    else
        for j = 1:size(resp.Body.Data.data.wind)
            Spotter.wind_speed(j,1) = resp.Body.Data.data.wind(j).speed;    
            Spotter.wind_dir(j,1) = resp.Body.Data.data.wind(j).direction;
            Spotter.wind_time(j,1) = datenum(resp.Body.Data.data.wind(j).timestamp,'yyyy-mm-ddTHH:MM:SS');
            Spotter.wind_seasurfaceId(j,1) = resp.Body.Data.data.wind(j).seasurfaceId;
        end
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
           elseif length(dum)>1
               data.serialID{j,1} = buoy_info.serial; 
               for jj = 1:length(fields)
                   data.(fields{jj})(j,1) = nanmean(Spotter.(fields{jj})(dum,1)); 
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

%Spectral variables
if isfield(resp.Body.Data.data,'frequencyData')
    for j = 1:size(resp.Body.Data.data.frequencyData)
        Spotter.spec_time(j,1) = datenum(resp.Body.Data.data.frequencyData(j).timestamp,'yyyy-mm-ddTHH:MM:SS'); 
        Spotter.a1(j,:) = resp.Body.Data.data.frequencyData(j).a1';
        Spotter.a2(j,:) = resp.Body.Data.data.frequencyData(j).a2';
        Spotter.b1(j,:) = resp.Body.Data.data.frequencyData(j).b1';
        Spotter.b2(j,:) = resp.Body.Data.data.frequencyData(j).b2';
        Spotter.varianceDensity(j,:) = resp.Body.Data.data.frequencyData(j).varianceDensity';
        Spotter.frequency(j,:) = resp.Body.Data.data.frequencyData(j).frequency';
        Spotter.df(j,:) = resp.Body.Data.data.frequencyData(j).df';
        Spotter.directionalSpread(j,:) = resp.Body.Data.data.frequencyData(j).directionalSpread';
        Spotter.direction(j,:) = resp.Body.Data.data.frequencyData(j).direction';
    end
end

end









