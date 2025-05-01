%% Get Spoondrift Buoy Data

%Use this code for all Sofar --- Spotters and Smart Moorings
% For Spotters, the smart mooring data grab will just be empty 


%%
function [Spotter,flag] = get_sofar_realtime(buoy_info,limit);

%re-code so that it just grabs the 'limit' for waves, and the last 1
import matlab.net.*
import matlab.net.http.*
header = matlab.net.http.HeaderField('token',buoy_info.sofar_token,'spotterId',buoy_info.serial);
r = RequestMessage('GET', header);
%wave data
tstart = datestr(datenum(now) - hours(24),30); 
tend = datestr(datenum(now)+ hours(2),30); 
startDate = [tstart 'Z']; 
endDate = [tend 'Z']; 

uri_waves=URI(['https://api.sofarocean.com/api/wave-data?spotterId=' buoy_info.serial...
    '&includeSurfaceTempData=true&includeWindData=true&includeFrequencyData=true&includeDirectionalMoments=true&'...
    'includePartitionData=true&includeBarometerData=true&processingSources=all'...
    '&startDate=' startDate '&endDate=' endDate]); 

resp = send(r,uri_waves);
status = resp.StatusCode;
disp([status]); 


uri_sensor= URI(['https://api.sofarocean.com/api/sensor-data?spotterId=' buoy_info.serial '&startDate=' startDate '&endDate=' endDate]); 
resp_sensor = send(r,uri_sensor);
status = resp_sensor.StatusCode;
disp([status]); 

uri_latest = URI(['https://api.sofarocean.com/api/latest-data?spotterId=' buoy_info.serial]);
resp_latest = send(r,uri_latest);
status = resp_latest.StatusCode;
disp([status]); 



%%   WAVE PARAMETERS AND WIND
if isfield(resp.Body.Data.data,'waves')
    %isolate HDR and embedded 
    indEmbedded =[]; 
    indHDR = []; 
    for j = 1:size(resp.Body.Data.data.waves)
        if strcmp(resp.Body.Data.data.waves(j).processing_source,'embedded')
            indEmbedded = [indEmbedded; j]; 
        elseif strcmp(resp.Body.Data.data.waves(j).processing_source,'hdr')
            indHDR = [indHDR; j]; 
        end
    end            
    
    %use HDR if available
    if ~isempty(indHDR)
        indEmbedded = indHDR; 
    end    

    for j = 1:size(indEmbedded,1)
        Spotter.serialID{j,1} = buoy_info.serial; 
        Spotter.time(j,1) = datenum(resp.Body.Data.data.waves(indEmbedded(j)).timestamp,'yyyy-mm-ddTHH:MM:SS');
        Spotter.hsig(j,1) = resp.Body.Data.data.waves(indEmbedded(j)).significantWaveHeight;        
        Spotter.tp(j,1) = resp.Body.Data.data.waves(indEmbedded(j)).peakPeriod;
        Spotter.tm(j,1) = resp.Body.Data.data.waves(indEmbedded(j)).meanPeriod;
        Spotter.dp(j,1) = resp.Body.Data.data.waves(indEmbedded(j)).peakDirection;
        Spotter.dpspr(j,1) = resp.Body.Data.data.waves(indEmbedded(j)).peakDirectionalSpread;
        Spotter.dm(j,1) = resp.Body.Data.data.waves(indEmbedded(j)).meanDirection;
        Spotter.dmspr(j,1) = resp.Body.Data.data.waves(indEmbedded(j)).meanDirectionalSpread;    
        %catch null lat/lon associated with spikes
        if isempty(resp.Body.Data.data.waves(indEmbedded(j)).latitude) | isempty( resp.Body.Data.data.waves(indEmbedded(j)).longitude)
            Spotter.lat(j,1) = -999.9999; 
            Spotter.lon(j,1) = -999.9999; 
        else
            Spotter.lat(j,1) = resp.Body.Data.data.waves(indEmbedded(j)).latitude;
            Spotter.lon(j,1) = resp.Body.Data.data.waves(indEmbedded(j)).longitude;
        end
    end
end

%check for wind data 
if isfield(resp.Body.Data.data,'wind')
    if ~isempty(resp.Body.Data.data.wind)
        %isolate HDR and embedded 
        indEmbedded =[]; 
        indHDR = []; 
        for j = 1:size(resp.Body.Data.data.wind)
            if strcmp(resp.Body.Data.data.wind(j).processing_source,'embedded')
                indEmbedded = [indEmbedded; j]; 
            elseif strcmp(resp.Body.Data.data.wind(j).processing_source,'hdr')
                indHDR = [indHDR; j]; 
            end
        end            
        
        %use HDR if available
        if ~isempty(indHDR)
            indEmbedded = indHDR; 
        end 
        
        for j = 1:size(indEmbedded,1)      
            Spotter.wind_speed(j,1) = resp.Body.Data.data.wind(indEmbedded(j)).speed;    
            Spotter.wind_dir(j,1) = resp.Body.Data.data.wind(indEmbedded(j)).direction;
            Spotter.wind_time(j,1) = datenum(resp.Body.Data.data.wind(indEmbedded(j)).timestamp,'yyyy-mm-ddTHH:MM:SS');
            Spotter.wind_seasurfaceId(j,1) = resp.Body.Data.data.wind(indEmbedded(j)).seasurfaceId;
        end        
    else
        for j = 1:size(resp.Body.Data.data.waves)
            Spotter.wind_speed(j,1) = nan;
            Spotter.wind_dir(j,1) = nan;
            Spotter.wind_time(j,1) = datenum(resp.Body.Data.data.waves(j).timestamp,'yyyy-mm-ddTHH:MM:SS');
            Spotter.wind_seasurfaceId(j,1) = nan;
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

%% SPECTRAL WAVE DATA
if isfield(resp.Body.Data.data,'frequencyData')
    if ~isempty(resp.Body.Data.data.frequencyData)
        %isolate HDR and embedded 
        indHDR = []; 
        indEmbedded = []; 
        for j = 1:size(resp.Body.Data.data.frequencyData)
            if strcmp(resp.Body.Data.data.frequencyData(j).processing_source,'hdr')
                indHDR = [indHDR; j]; 
            elseif strcmp(resp.Body.Data.data.frequencyData(j).processing_source,'embedded')
                indEmbedded = [indEmbedded;j]; 
            end
        end
        
        %use HDR if available
        if ~isempty(indHDR)
            indSpec = indHDR; 
        else
            indSpec = indEmbedded;
        end
        
        for j = 1:size(indSpec,1)
            Spotter.spec_time(j,1) = datenum(resp.Body.Data.data.frequencyData(indSpec(j)).timestamp,'yyyy-mm-ddTHH:MM:SS'); 
            Spotter.a1(j,:) = resp.Body.Data.data.frequencyData(indSpec(j)).a1';
            Spotter.a2(j,:) = resp.Body.Data.data.frequencyData(indSpec(j)).a2';
            Spotter.b1(j,:) = resp.Body.Data.data.frequencyData(indSpec(j)).b1';
            Spotter.b2(j,:) = resp.Body.Data.data.frequencyData(indSpec(j)).b2';
            Spotter.varianceDensity(j,:) = resp.Body.Data.data.frequencyData(indSpec(j)).varianceDensity';
            Spotter.frequency(j,:) = resp.Body.Data.data.frequencyData(indSpec(j)).frequency';
            Spotter.df(j,:) = resp.Body.Data.data.frequencyData(indSpec(j)).df';
            Spotter.directionalSpread(j,:) = resp.Body.Data.data.frequencyData(indSpec(j)).directionalSpread';
            Spotter.direction(j,:) = resp.Body.Data.data.frequencyData(indSpec(j)).direction';
        end
    else
        Spotter.spec_time = Spotter.time;
        Spotter.a1 = ones(size(Spotter.time,1),79).*-9999; 
        Spotter.a2 = ones(size(Spotter.time,1),79).*-9999; 
        Spotter.b1 = ones(size(Spotter.time,1),79).*-9999; 
        Spotter.b2 = ones(size(Spotter.time,1),79).*-9999; 
        Spotter.varianceDensity = ones(size(Spotter.time,1),79).*-9999; 
        Spotter.frequency = ones(size(Spotter.time,1),79).*-9999; 
        Spotter.df = ones(size(Spotter.time,1),79).*-9999; 
        Spotter.directionalSpread = ones(size(Spotter.time,1),79).*-9999; 
        Spotter.direction = ones(size(Spotter.time,1),79).*-9999; 
    end
else
    Spotter.spec_time = Spotter.time;
    Spotter.a1 = ones(size(Spotter.time,1),79).*-9999; 
    Spotter.a2 = ones(size(Spotter.time,1),79).*-9999; 
    Spotter.b1 = ones(size(Spotter.time,1),79).*-9999; 
    Spotter.b2 = ones(size(Spotter.time,1),79).*-9999; 
    Spotter.varianceDensity = ones(size(Spotter.time,1),79).*-9999; 
    Spotter.frequency = ones(size(Spotter.time,1),79).*-9999; 
    Spotter.df = ones(size(Spotter.time,1),79).*-9999; 
    Spotter.directionalSpread = ones(size(Spotter.time,1),79).*-9999; 
    Spotter.direction = ones(size(Spotter.time,1),79).*-9999; 
end
    
%% PARTITIONED WAVE DATA 

if isfield(resp.Body.Data.data,'partitionData')
    if ~isempty(resp.Body.Data.data.partitionData)
        %isolate HDR and embedded 
        indHDR = []; 
        indEmbedded = []; 
        for j = 1:size(resp.Body.Data.data.partitionData)
            if strcmp(resp.Body.Data.data.partitionData(j).processing_source,'hdr')
                indHDR = [indHDR; j]; 
            elseif strcmp(resp.Body.Data.data.partitionData(j).processing_source,'embedded')
                indEmbedded = [indEmbedded;j]; 
            end
        end
        
        %use HDR if available
        if ~isempty(indHDR)
            indPart = indHDR; 
        else
            indPart = indEmbedded;
        end
        
        for j = 1:size(indPart,1)
            Spotter.part_time(j,1) = datenum(resp.Body.Data.data.partitionData(indPart(j)).timestamp,'yyyy-mm-ddTHH:MM:SS'); 
            Spotter.startFreq_swell(j,1) = resp.Body.Data.data.partitionData(indPart(j)).partitions(1).startFrequency; 
            Spotter.endFreq_swell(j,1) = resp.Body.Data.data.partitionData(indPart(j)).partitions(1).endFrequency;
            Spotter.startFreq_sea(j,1) = resp.Body.Data.data.partitionData(indPart(j)).partitions(2).startFrequency;
            Spotter.endFreq_sea(j,1) = resp.Body.Data.data.partitionData(indPart(j)).partitions(2).endFrequency;
            Spotter.hsig_swell(j,1) = resp.Body.Data.data.partitionData(indPart(j)).partitions(1).significantWaveHeight;
            Spotter.hsig_sea(j,1) = resp.Body.Data.data.partitionData(indPart(j)).partitions(2).significantWaveHeight;
            Spotter.tm_swell(j,1) = resp.Body.Data.data.partitionData(indPart(j)).partitions(1).meanPeriod;
            Spotter.tm_sea(j,1) = resp.Body.Data.data.partitionData(indPart(j)).partitions(2).meanPeriod;
            Spotter.dm_swell(j,1) = resp.Body.Data.data.partitionData(indPart(j)).partitions(1).meanDirection;
            Spotter.dm_sea(j,1) = resp.Body.Data.data.partitionData(indPart(j)).partitions(2).meanDirection;
            Spotter.dmspr_swell(j,1) = resp.Body.Data.data.partitionData(indPart(j)).partitions(1).meanDirectionalSpread;
            Spotter.dmspr_sea(j,1) = resp.Body.Data.data.partitionData(indPart(j)).partitions(2).meanDirectionalSpread;
        end
    else
        Spotter.part_time = Spotter.time;
        Spotter.startFreq_swell = ones(size(Spotter.time,1),1).*-9999; 
        Spotter.endFreq_swell = ones(size(Spotter.time,1),1).*-9999; 
        Spotter.startFreq_sea = ones(size(Spotter.time,1),1).*-9999; 
        Spotter.endFreq_sea = ones(size(Spotter.time,1),1).*-9999; 
        Spotter.hsig_swell = ones(size(Spotter.time,1),1).*-9999; 
        Spotter.hsig_sea = ones(size(Spotter.time,1),1).*-9999; 
        Spotter.tm_swell = ones(size(Spotter.time,1),1).*-9999; 
        Spotter.tm_sea = ones(size(Spotter.time,1),1).*-9999; 
        Spotter.dm_swell = ones(size(Spotter.time,1),1).*-9999; 
        Spotter.dm_sea = ones(size(Spotter.time,1),1).*-9999; 
        Spotter.dmspr_swell = ones(size(Spotter.time,1),1).*-9999; 
        Spotter.dmspr_sea = ones(size(Spotter.time,1),1).*-9999; 
    end
else
        Spotter.part_time = Spotter.time;
        Spotter.startFreq_swell = ones(size(Spotter.time,1),1).*-9999; 
        Spotter.endFreq_swell = ones(size(Spotter.time,1),1).*-9999; 
        Spotter.startFreq_sea = ones(size(Spotter.time,1),1).*-9999; 
        Spotter.endFreq_sea = ones(size(Spotter.time,1),1).*-9999; 
        Spotter.hsig_swell = ones(size(Spotter.time,1),1).*-9999; 
        Spotter.hsig_sea = ones(size(Spotter.time,1),1).*-9999; 
        Spotter.tm_swell = ones(size(Spotter.time,1),1).*-9999; 
        Spotter.tm_sea = ones(size(Spotter.time,1),1).*-9999; 
        Spotter.dm_swell = ones(size(Spotter.time,1),1).*-9999; 
        Spotter.dm_sea = ones(size(Spotter.time,1),1).*-9999; 
        Spotter.dmspr_swell = ones(size(Spotter.time,1),1).*-9999; 
        Spotter.dmspr_sea = ones(size(Spotter.time,1),1).*-9999; 
end
    
%% SMART MOORING vs SPOTTER TEMPERAUTRE AND PRESSURE
Spotter.temp_time = []; 
Spotter.bott_temp_time = [];
Spotter.surf_temp = []; 
Spotter.bott_temp = []; 
Spotter.pressure =[]; 
Spotter.pressure_std = []; 
Spotter.press_time = []; 
Spotter.press_std_time=[]; 

%Spotter
if isfield(resp.Body.Data.data,'surfaceTemp')&~isempty(resp.Body.Data.data.surfaceTemp)
    %isolate HDR and embedded 
    indHDR = []; 
    indEmbedded = []; 
    for j = 1:size(resp.Body.Data.data.surfaceTemp)
        if strcmp(resp.Body.Data.data.surfaceTemp(j).processing_source,'hdr')
            indHDR = [indHDR; j]; 
        elseif strcmp(resp.Body.Data.data.surfaceTemp(j).processing_source,'embedded')
            indEmbedded = [indEmbedded;j]; 
        end
    end    
    
    %use HDR if available 
    if ~isempty(indHDR)
        indTemp = indHDR; 
    else
        indTemp = indEmbedded; 
    end
    
    for j = 1:size(indTemp,1)
            Spotter.surf_temp(j,1) = resp.Body.Data.data.surfaceTemp(indTemp(j)).degrees;
            Spotter.temp_time(j,1) = datenum(resp.Body.Data.data.surfaceTemp(indTemp(j)).timestamp,'yyyy-mm-ddTHH:MM:SS');
    end
    
    %check for bottom temperature data
    if isfield(resp.Body.Data.data,'bottomTemp')
        for j = 1:size(indTemp)
            Spotter.bott_temp(j,1) = resp.Body.Data.data.bottomTemp(indTemp(j)).degrees;
        end
    else
        for j = 1:size(indTemp)
            Spotter.bott_temp(j,1)= -9999; 
        end
    end
 %smart mooring
elseif ~isempty(resp_sensor.Body.Data.data)  
    %get unique sensor positions
    for j = 1:size(resp_sensor.Body.Data.data,1)
        sensorPosition(j,1) = resp_sensor.Body.Data.data(j).sensorPosition; 
    end
    sensorPosition = unique(sensorPosition); 
    for j = 1:size(resp_sensor.Body.Data.data,1)
        if strcmp(resp_sensor.Body.Data.data(j).unit_type,'temperature')
            if resp_sensor.Body.Data.data(j).sensorPosition==1
                Spotter.surf_temp = [Spotter.surf_temp; resp_sensor.Body.Data.data(j).value];                 
                Spotter.temp_time = [Spotter.temp_time; datenum(resp_sensor.Body.Data.data(j).timestamp,'yyyy-mm-ddTHH:MM:SS')]; 
            elseif resp_sensor.Body.Data.data(j).sensorPosition==max(sensorPosition)
                Spotter.bott_temp = [Spotter.bott_temp; resp_sensor.Body.Data.data(j).value]; 
                Spotter.bott_temp_time = [Spotter.bott_temp_time; datenum(resp_sensor.Body.Data.data(j).timestamp,'yyyy-mm-ddTHH:MM:SS')];    
            %for extra temperature nodes not at surface or bottom
            % else 
            %     Spotter.surf_temp = [Spotter.surf_temp; NaN];
            %     Spotter.bott_temp = [Spotter.bott_temp; NaN]; 
            %     Spotter.temp_time = [Spotter.temp_time; datenum(resp_sensor.Body.Data.data(j).timestamp,'yyyy-mm-ddTHH:MM:SS')];
            %     Spotter.bott_temp_time = [Spotter.bott_temp_time; datenum(resp_sensor.Body.Data.data(j).timestamp,'yyyy-mm-ddTHH:MM:SS')];
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
    %add check for surface and bottom temperature data 
    if size(Spotter.surf_temp,1)~= size(Spotter.bott_temp,1)
        if size(Spotter.surf_temp,1)>size(Spotter.bott_temp,1)
            bdum = ones(size(Spotter.surf_temp,1),1)*nan; 
            for kk = 1:size(Spotter.temp_time,1)
                I = find(Spotter.bott_temp_time==Spotter.temp_time(kk,1));
                if ~isempty(I)
                    bdum(kk,1) = Spotter.bott_temp(I); 
                elseif isempty(I)
                    bdum(kk,1) = nan; 
                end
            end
            Spotter.bott_temp = bdum; 
            clear bdum I 
        elseif size(Spotter.surf_temp,1)<size(Spotter.bott_temp,1)
            bdum = ones(size(Spotter.bott_temp,1),1)*nan; 
            for kk = 1:size(Spotter.bott_temp,1)
                I = find(Spotter.temp_time==Spotter.bott_temp_time(kk,1));
                if ~isempty(I)
                    bdum(kk,1) = Spotter.surf_temp(I); 
                elseif isempty(I)
                    bdum(kk,1) = nan; 
                end
            end
            Spotter.surf_temp = bdum; 
            clear bdum I 
        end
    end                    
%if no sensor data, act like normal wave buoy
else
    Spotter.temp_time = Spotter.time;
    Spotter.bott_temp_time = Spotter.time; 
    Spotter.press_time = Spotter.time;
    Spotter.press_std_time = Spotter.time;
    Spotter.surf_temp = ones(size(Spotter.time,1),1).*-9999; 
    Spotter.bott_temp = ones(size(Spotter.time,1),1).*-9999; 
    Spotter.pressure = ones(size(Spotter.time,1),1).*-9999; 
    Spotter.pressure_std =ones(size(Spotter.time,1),1).*-9999; 
end   

%remove bott temp time if exists
if isfield(Spotter,'bott_temp_time')
    Spotter = rmfield(Spotter,'bott_temp_time'); 
end

%% smart mooring with current meter 
Spotter.curr_time = []; 
Spotter.curr_mag = []; %cm/s
Spotter.curr_mag_std = [];
Spotter.curr_dir = []; 
Spotter.curr_dir_std = []; 
Spotter.curr_tilt = []; 
Spotter.curr_tilt_std = []; 
Spotter.curr_temperature = []; %temperature sensor on current meter 
Spotter.curr_count = []; 

if ~isempty(resp_sensor.Body.Data.data)
     for j = 1:size(resp_sensor.Body.Data.data,1)
        if contains(resp_sensor.Body.Data.data(j).data_type_name,'speed_mean')            
            Spotter.curr_mag = [Spotter.curr_mag; resp_sensor.Body.Data.data(j).value./100];                 
            Spotter.curr_time = [Spotter.curr_time; datenum(resp_sensor.Body.Data.data(j).timestamp,'yyyy-mm-ddTHH:MM:SS')]; 
        elseif contains(resp_sensor.Body.Data.data(j).data_type_name,'speed_std')            
            Spotter.curr_mag_std = [Spotter.curr_mag_std; resp_sensor.Body.Data.data(j).value./100]; 
        elseif contains(resp_sensor.Body.Data.data(j).data_type_name,'direction_circ_mean')            
            Spotter.curr_dir = [Spotter.curr_dir; rad2deg(resp_sensor.Body.Data.data(j).value)]; 
        elseif contains(resp_sensor.Body.Data.data(j).data_type_name,'direction_circ_std')            
            Spotter.curr_dir_std = [Spotter.curr_dir_std; rad2deg(resp_sensor.Body.Data.data(j).value)]; 
        elseif contains(resp_sensor.Body.Data.data(j).data_type_name,'abs_tilt_mean')            
            Spotter.curr_tilt = [Spotter.curr_tilt; rad2deg(resp_sensor.Body.Data.data(j).value)]; 
        elseif contains(resp_sensor.Body.Data.data(j).data_type_name,'std_tilt_mean')            
            Spotter.curr_tilt_std = [Spotter.curr_tilt_std; rad2deg(resp_sensor.Body.Data.data(j).value)]; 
        elseif contains(resp_sensor.Body.Data.data(j).data_type_name,'count')    
            % when count = 0, a value for count is logged, but not for others
            if resp_sensor.Body.Data.data(j).value >0
                Spotter.curr_count = [Spotter.curr_count; resp_sensor.Body.Data.data(j).value];  
            end
        elseif contains(resp_sensor.Body.Data.data(j).data_type_name,'aanderaa_temperature')
            Spotter.curr_temperature = [Spotter.curr_temperature; resp_sensor.Body.Data.data(j).value]; 
        end
     end
end



%% Check and fill variables when empty

%check temperature 
if isempty(Spotter.surf_temp)&&isempty(Spotter.bott_temp)
    Spotter.temp_time = Spotter.time;     
    Spotter.surf_temp = ones(size(Spotter.time,1),1).*-9999;    
    Spotter.bott_temp = ones(size(Spotter.time,1),1).*-9999; 
elseif ~isempty(Spotter.surf_temp)&&isempty(Spotter.bott_temp)
    Spotter.bott_temp = ones(size(Spotter.temp_time,1),1).*-9999;    
end

%check pressure
if isempty(Spotter.pressure)&&isempty(Spotter.pressure_std)
    Spotter.press_time = Spotter.time; 
    Spotter.press_std_time = Spotter.time;
    Spotter.pressure = ones(size(Spotter.time,1),1).*-9999; 
    Spotter.pressure_std = ones(size(Spotter.time,1),1).*-9999; 
end

%check current meter
if isempty(Spotter.curr_mag)&&isempty(Spotter.curr_mag_std)&&isempty(Spotter.curr_dir)&&isempty(Spotter.curr_dir_std) %assume everythign else is bad too 
    Spotter.curr_time = Spotter.time; 
    Spotter.curr_mag = ones(size(Spotter.time,1),1).*-9999;
    Spotter.curr_mag_std = ones(size(Spotter.time,1),1).*-9999;
    Spotter.curr_dir = ones(size(Spotter.time,1),1).*-9999;
    Spotter.curr_dir_std = ones(size(Spotter.time,1),1).*-9999;
    Spotter.curr_tilt = ones(size(Spotter.time,1),1).*-9999;
    Spotter.curr_tilt_std = ones(size(Spotter.time,1),1).*-9999;
    Spotter.curr_count = ones(size(Spotter.time,1),1).*-9999;
    Spotter.curr_temperature = ones(size(Spotter.time,1),1).*-9999;
end

    
%% add in humidity and voltage 

if ~isempty(resp_latest.Body.Data.data.waves)
    Spotter.systime = datenum(resp_latest.Body.Data.data.waves(end).timestamp,'yyyy-mm-ddTHH:MM:SS'); 
else
    Spotter.systime = Spotter.time(end);
end

if ~isempty(resp_latest.Body.Data.data.batteryVoltage)
    Spotter.batteryVoltage = resp_latest.Body.Data.data.batteryVoltage;
else
    Spotter.batteryVoltage=nan; 
end

if ~isempty(resp_latest.Body.Data.data.batteryPower)
    Spotter.batteryPower =  resp_latest.Body.Data.data.batteryPower;
else
    Spotter.batteryPower = nan;
end

if ~isempty(resp_latest.Body.Data.data.solarVoltage)
    Spotter.solarVoltage =  resp_latest.Body.Data.data.solarVoltage;
else
    Spotter.solarVoltage = nan;
end
 
if ~isempty(resp_latest.Body.Data.data.humidity)
    Spotter.humidity =  resp_latest.Body.Data.data.humidity;
else
    Spotter.humidity = nan; 
end


%% check that mooring data has correc time stamps to continue

if Spotter.temp_time(end)>Spotter.time(end)
    flag = 1; 
else
    flag = 0;
end
% flag = 1; 


end









