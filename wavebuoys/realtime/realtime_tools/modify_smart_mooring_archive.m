

%% process realtime mode data         
%grab data
import matlab.net.*
import matlab.net.http.*
header = matlab.net.http.HeaderField('token',buoy_info.sofar_token,'spotterId',buoy_info.serial);
r = RequestMessage('GET', header);
%wave data
uri_waves= URI(['https://api.sofarocean.com/api/wave-data?spotterId=' buoy_info.serial...
    '&includeSurfaceTempData=true&includeWindData=true&limit=' num2str(limit)]);
options = matlab.net.http.HTTPOptions('ConnectTimeout',20);
resp_waves = send(r,uri_waves,options);
status = resp_waves.StatusCode;
disp([status]);     


tstart = datestr(datenum(resp_waves.Body.Data.data.waves(1).timestamp,'yyyy-mm-ddTHH:MM:SS'),30); 
tend = datestr(datenum(resp_waves.Body.Data.data.waves(end).timestamp,'yyyy-mm-ddTHH:MM:SS'),30); 
startDate = [tstart 'Z']; 
endDate = [tend 'Z']; 

uri_sensor= URI(['https://api.sofarocean.com/api/sensor-data?spotterId=' buoy_info.serial '&startDate=' startDate '&endDate=' endDate]); 
resp_sensor = send(r,uri_sensor,options);
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
                if length(dum)>1
                    dum = dum(1);
                end
                
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
                Spotter.bott_temp(j,1)=-9999; 
            end
        end
        Spotter = rmfield(Spotter, 'bott_temp_time');     
    elseif length(Spotter.temp_temp)<length(Spotter.bott_temp_time)
        for j = 1:length(Spotter.bott_temp_time)
             try
                Spotter.bott_time(j,1)==Spotter.temp_time(j,1);
            catch
                Spotter.surf_temp(j,1)=-9999; 
             end
        end
        Spotter.temp_time = Spotter.bott_temp_time;         
    end
else
    Spotter = rmfield(Spotter, 'bott_temp_time');     
end
        

%%
%load in any existing data for this site and combine with new
%measurements, then QAQC

%make sure smart mooring only has wave/temp data for time as would be
%normal 
fields = fieldnames(Spotter); 
for i =1:length(fields); 
    if strcmp(fields{i},'bott_temp')|strcmp(fields{i},'surf_temp')|strcmp(fields{i},'temp_time')
        SpotData.(fields{i}) = Spotter.(fields{i}); 
    else
        idx = find(Spotter.time<Spotter.temp_time(end)); 
        SpotData.(fields{i}) = Spotter.(fields{i})(idx); 
    end
end

start_time = datenum(2021,07,26); 
idxw = find(SpotData.time>start_time); 
idxt = find(SpotData.temp_time>start_time); 
for i = 1:length(fields);
    if strcmp(fields{i},'bott_temp')|strcmp(fields{i},'surf_temp')|strcmp(fields{i},'temp_time')
        SpotData.(fields{i}) = SpotData.(fields{i})(idxt,:); 
    else
        SpotData.(fields{i}) = SpotData.(fields{i})(idxw,:); 
    end
end

for i =1 :size(SpotData.time)
    SpotData.name{i,1} = buoy_info.name; 
end

for i =1 :size(data.time)
    data.name{i,1} = buoy_info.name; 
end

[archive_data] = load_archived_data(buoy_info.archive_path, buoy_info, SpotData);
idx = find(archive_data.time<SpotData.time(1)); 
idx2 = find(archive_data.temp_time<SpotData.temp_time(1)); 
if ~isempty(idx)&~isempty(idx2)
    fields = fieldnames(SpotData); 
    for i =1:length(fields); 
        if strcmp(fields{i},'bott_temp')|strcmp(fields{i},'surf_temp')|strcmp(fields{i},'temp_time')
            SpotData.(fields{i}) = [archive_data.(fields{i})(idx2);SpotData.(fields{i})]; 
        else
            SpotData.(fields{i}) = [archive_data.(fields{i})(idx);SpotData.(fields{i})];
        end
        
    end
end
    
    
    
bulkparams = SpotData; 
%bulkparams data 
qaqc.time = bulkparams.time; 
qaqc.WVHGT = bulkparams.hsig; 
qaqc.WVPD = bulkparams.tp; 
if isfield(bulkparams, 'temp_time')
    qaqc.time_temp = bulkparams.temp_time; 
    qaqc.SST = bulkparams.surf_temp; 
    qaqc.BOTT_TEMP = bulkparams.bott_temp; 
end

%settings for range test (QARTOD19) 
qaqc.MINWH = 0.01;
qaqc.MAXWH = 12;
qaqc.MINWP = 1; 
qaqc.MAXWP = 25;
qaqc.MAXT = 45; 
qaqc.MINT = 0; 

%settings UWA 'master flag' test (combination of QARTOD19 and QARTOD20) -
%requires 3 data points 
qaqc.rocHs =0.5; 
qaqc.HsLim = 10; 
qaqc.rocTp = 8; 
qaqc.TpLim = 25; 
qaqc.rocSST = 2; 

if isfield(qaqc, 'time_temp')
    [bulkparams.qf_waves, bulkparams.qf_sst, bulkparams.qf_bott_temp] = qaqc_uwa_waves_website(qaqc); 
else
    [bulkparams.qf_waves, ~, ~] = qaqc_uwa_waves_website(qaqc);
end
SpotData = bulkparams; 

%%
% data = bulkparams; 
% %save data to different formats        
% realtime_archive_mat(buoy_info, data);
% realtime_archive_text(buoy_info, data, 0);         
% update_website_buoy_info(buoy_info, data); 

