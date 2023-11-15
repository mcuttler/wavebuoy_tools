%% Get Spoondrift Buoy Data

% Accesses SoFar Ocean API to get most recent data from specified Spotter
% SpotterID is string of Spotter name - i.e. 'SPOT-0093'

%v1 Nov 2018

%v2 April 2019 - updated from Get_Spoondrift_Data_realtime to include
%spectral data

%v3 November 2023 - update to grab everything and then fill with nan if
%empty; grabs data from on-board and HDR where available 

%M Cuttler

%%
function [Spotter] = Get_Spoondrift_Data_realtime_v2(buoy_info, limit)

%% GET API DATA 
import matlab.net.*
import matlab.net.http.*
header = matlab.net.http.HeaderField('token',buoy_info.sofar_token,'spotterId',buoy_info.serial);
r = RequestMessage('GET', header);

tstart = datestr(datenum(now) - hours(12),30); 
tend = datestr(datenum(now)+ hours(2),30); 
startDate = [tstart 'Z']; 
endDate = [tend 'Z']; 

%get frequency data from HDR mode 
% uri = URI(['https://api.sofarocean.com/api/wave-data?spotterId=' buoy_info.serial...
%     '&includeSurfaceTempData=true&includeWindData=true&includeFrequencyData=true&includeDirectionalMoments=true&'...
%     'includePartitionData=true&includeBarometerData=true&processingSources=embedded']); % &limit=' num2str(limit)]);

uri = URI(['https://api.sofarocean.com/api/wave-data?spotterId=' buoy_info.serial...
    '&includeSurfaceTempData=true&includeWindData=true&includeFrequencyData=true&includeDirectionalMoments=true&'...
    'includePartitionData=true&includeBarometerData=true&processingSources=all'...
    '&startDate=' startDate '&endDate=' endDate]); 

resp = send(r,uri);
status = resp.StatusCode;

disp(status);


%%   WAVE PARAMETERS AND WIND
if isfield(resp.Body.Data.data,'waves')
    %use embedded data instead of HDR for parameters    
    indEmbedded =[]; 
    for j = 1:size(resp.Body.Data.data.waves)
        if strcmp(resp.Body.Data.data.waves(j).processing_source,'embedded')
            indEmbedded = [indEmbedded; j]; 
        end
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
        Spotter.lat(j,1) = resp.Body.Data.data.waves(indEmbedded(j)).latitude;
        Spotter.lon(j,1) = resp.Body.Data.data.waves(indEmbedded(j)).longitude;
    end
end

%check for wind data 
if isfield(resp.Body.Data.data,'wind')
    if ~isempty(resp.Body.Data.data.wind)
        %use embedded data instead of HDR for wind
        indEmbedded =[]; 
        for j = 1:size(resp.Body.Data.data.wind)
            if strcmp(resp.Body.Data.data.wind(j).processing_source,'embedded')
                indEmbedded = [indEmbedded; j]; 
            end
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


%% TEMPERATURE DATA 
if isfield(resp.Body.Data.data,'surfaceTemp')&~isempty(resp.Body.Data.data.surfaceTemp)
    %isolate HDR and embedded 
    indHDR = []; 
    indEmbedded = []; 
    for j = 1:size(resp.Body.Data.data.wind)
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
else
    Spotter.temp_time = Spotter.time; 
    Spotter.surf_temp = ones(size(Spotter.time,1),1).*-9999; 
    Spotter.bott_temp = ones(size(Spotter.time,1),1).*-9999; 
end


%% SPECTRAL WAVE DATA
if isfield(resp.Body.Data.data,'frequencyData')
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
end

%% PARTITIONED WAVE DATA 

if isfield(resp.Body.Data.data,'partitionData')
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
end


end









