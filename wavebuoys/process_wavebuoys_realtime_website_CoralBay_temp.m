%%  Process wave buoys (real time) for display on wawaves.org

%MC to update prior to merging into master branch

%AQL public token: a1b3c0dbaa16bb21d5f0befcbcca51
%UWA token: e0eb70b6d9e0b5e00450929139ea34

%% set initial paths for wave buoy data to process and parser script
clear; clc

%location of wavebuoy_tools repo
% buoycodes = 'C:\Data\wavebuoy_tools\wavebuoys'; 
% addpath(genpath(buoycodes))

%buoy type and deployment info number and deployment info 
buoy_info.type = 'sofar'; 
buoy_info.serial = 'SPOT-0929'; %spotter serial number, or just Datawell 
buoy_info.name = 'CoralBay'; 
buoy_info.datawell_name = 'nan'; 
buoy_info.version = 'smart_mooring'; %V1, V2, smart_mooring, Datawell, Triaxys
buoy_info.sofar_token = 'a1b3c0dbaa16bb21d5f0befcbcca51'; 
buoy_info.utc_offset = 8; 
buoy_info.DeployLoc = 'CoralBay';
buoy_info.DeployDepth = 20; 
buoy_info.DeployLat = -23.144233; 
buoy_info.DeployLon = 113.740267; 
buoy_info.UpdateTime =  1; %hours
buoy_info.DataType = 'parameters'; %can be parameters if only bulk parameters, or spectral for including spectral coefficients
buoy_info.archive_path = 'E:\wawaves';
buoy_info.backup_path = 'X:\LOWE_IMOS_Deakin_Collab_JUN2020\Data\waves_website\realtime_archive_backup';
buoy_info.datawell_datapath = 'E:\waved'; %top level directory for Datawell CSVs

%use this website to calculate magnetic declination: https://www.ngdc.noaa.gov/geomag/calculators/magcalc.shtml#declination
% buoy_info.MagDec = 1.98; 

%% process realtime mode data

limit = 100; 
         
%grab data
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


tstart = datestr(datenum(resp_waves.Body.Data.data.waves(1).timestamp,'yyyy-mm-ddTHH:MM:SS'),30); 
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
if ~isempty(resp_sensor.Body.Data.data)    
    for j = 1:size(resp_sensor.Body.Data.data,1)
        if resp_sensor.Body.Data.data(j).sensorPosition==1
            Spotter.surf_temp = [Spotter.surf_temp; resp_sensor.Body.Data.data(j).value]; 
            Spotter.temp_time = [Spotter.temp_time; datenum(resp_sensor.Body.Data.data(j).timestamp,'yyyy-mm-ddTHH:MM:SS')]; 
        elseif resp_sensor.Body.Data.data(j).sensorPosition==2           
            Spotter.bott_temp = [Spotter.bott_temp; resp_sensor.Body.Data.data(j).value]; 
        end
    end
end

%%
%load in any existing data for this site and combine with new
%measurements, then QAQC
[check] = check_archive_path(buoy_info.archive_path, buoy_info, SpotData);    

%check>0 means that directory already exists (and monthly file should
%exist); otherwise, this is the first data for this location 
if all(check)~=0        
    [archive_data] = load_archived_data(buoy_info.archive_path, buoy_info, SpotData);                  
    
    %check that it's new data
    if SpotData.time(1)>archive_data.time(end)
        
        %perform some QA/QC --- QARTOD 19 and QARTOD 20        
        [data] = qaqc_bulkparams_realtime_website(buoy_info, archive_data, SpotData);                        
        
        %save data to different formats        
        realtime_archive_mat(buoy_info, data);
        realtime_archive_text(buoy_info, data, limit);         
        %code to update the buoy info master file for website to read
        update_website_buoy_info(buoy_info, data); 
    end
else
    SpotData.qf_waves = ones(size(SpotData.time,1),1).*4;
    if isfield(SpotData,'temp_time')
        SpotData.qf_sst = ones(size(SpotData.temp_time,1),1).*4; 
        SpotData.qf_bott_temp = ones(size(SpotData.temp_time,1),1).*4; 
        
    end
    realtime_archive_mat(buoy_info, SpotData);
    realtime_archive_text(buoy_info, SpotData, limit); 
    
    %code to update the buoy info master file for website to read
    update_website_buoy_info(buoy_info, SpotData); 
end

