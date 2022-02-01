%% Get Spoondrift Buoy Data

% Code for Sofar Spotters (V1 or V2) - can be wave (parameters or spectral) +
% temp sensors or pressure sensors

% AQL token: a1b3c0dbaa16bb21d5f0befcbcca51
% Please don't use the latest-data endpoint
% Instead use the sensor-data endpoint rather than the wave-data endpoint


%%
function [Spotter,flag] = Get_Spoondrift_time_period(buoy_info, startDate, endDate)

% break into days for data requests - could do months, but may run into
% reuqest limit depending on whether getting spectral data or not 

dumt = [startDate:endDate]'; 
check = []; 

for ii =1:size(dumt,1)
    disp(['Grabbing data for ' datestr(dumt(ii))]); 
    % get times in correct format for Sofar API 
    tstart = datestr(dumt(ii,:),'yyyy-mm-ddTHH:MM:SS');  
    tend = datestr(dumt(ii,:)+0.999999,'yyyy-mm-ddTHH:MM:SS'); 
    tstart = [tstart 'Z']; 
    tend = [tend 'Z']; 
    
    %set up api request 
    import matlab.net.*
    import matlab.net.http.*
    header = matlab.net.http.HeaderField('token',buoy_info.sofar_token,'spotterId',buoy_info.serial);
    r = RequestMessage('GET', header);
    
    %wave data - modify request in futre to be more general and include spectra
    %if exists 
    uri_waves= URI(['https://api.sofarocean.com/api/wave-data?spotterId=' buoy_info.serial...
        '&startDate=' tstart '&endDate=' tend '&includeSurfaceTempData=true&includeWindData=true&includeFrequencyData=true&includeDirectionalMoments=true']);
    resp_waves = send(r,uri_waves);
    status = resp_waves.StatusCode;
    disp([status]); 
    %% WAVES AND WIND
    %check for wave parameters
    if ~isempty(resp_waves.Body.Data.data.waves)
        for j = 1:size(resp_waves.Body.Data.data.waves)
            data.serialID{j,1} = buoy_info.serial; 
            data.time(j,1) = datenum(resp_waves.Body.Data.data.waves(j).timestamp,'yyyy-mm-ddTHH:MM:SS');
            data.hs(j,1) = resp_waves.Body.Data.data.waves(j).significantWaveHeight;        
            data.tp(j,1) = resp_waves.Body.Data.data.waves(j).peakPeriod;
            data.tm(j,1) = resp_waves.Body.Data.data.waves(j).meanPeriod;
            data.dp(j,1) = resp_waves.Body.Data.data.waves(j).peakDirection;
            data.dpspr(j,1) = resp_waves.Body.Data.data.waves(j).peakDirectionalSpread;
            data.dm(j,1) = resp_waves.Body.Data.data.waves(j).meanDirection;
            data.dmspr(j,1) = resp_waves.Body.Data.data.waves(j).meanDirectionalSpread;       
            data.lat(j,1) = resp_waves.Body.Data.data.waves(j).latitude;
            data.lon(j,1) = resp_waves.Body.Data.data.waves(j).longitude;
        end
    end
    %check for wind data
    if ~isempty(resp_waves.Body.Data.data.wind)
        for j = 1:size(resp_waves.Body.Data.data.wind)
            data.wind_speed(j,1) = resp_waves.Body.Data.data.wind(j).speed;
            data.wind_dir(j,1) = resp_waves.Body.Data.data.wind(j).direction;
            data.wind_time(j,1) = datenum(resp_waves.Body.Data.data.wind(j).timestamp,'yyyy-mm-ddTHH:MM:SS');
            data.wind_seasurfaceId(j,1) = resp_waves.Body.Data.data.wind(j).seasurfaceId;
        end
    else
        data.wind_speed = nan; 
        data.wind_dir = nan;
        data.wind_time = nan;
        data.wind_seasurfaceId = nan; 
    end
    
    %check that wind and waves have same time and number of data points 
    [m,~] = size(data.time); 
    [n,~] = size(data.wind_time); 
    
    if m~=n       
        if n>m %missing waves - so clip wind to waves
            for j = 1:size(data.time,1)
                ind(j,1) = find(data.wind_time==data.time(j)); 
            end            
            fields = {'wind_time';'wind_speed';'wind_dir';'wind_seasurfaceId'};
            for j = 1:length(fields)
                data.(fields{j}) = data.(fields{j})(ind,:); 
            end  
            clear j ind; 
        elseif m>n %missing wind - add nan values to wind
            dumdata = data; 
            fields = {'wind_speed';'wind_dir';'wind_seasurfaceId'};
            for j = 1:length(fields); 
                dumdata.(fields{j}) = ones(size(data.time,1),1).*nan; 
            end             
            dumdata.wind_time = data.time; 
            for j = 1:size(data.time,1)
                ind = find(data.wind_time==data.time(j)); 
                if isempty(ind)
                    for jj = 1:length(fields)
                        dumdata.(fields{jj})(j,1) = nan; 
                    end
                else
                    for jj =1:length(fields)
                        dumdata.(fields{jj})(j,1) = data.(fields{jj})(ind,1); 
                    end
                end
            end
            data = dumdata; 
            clear dumdata j jj ind        
        end
    end
    %% TEMPERATURE
    %check for temperature data    
    %assume surface and bottom sensor   
    if ~isempty(resp_waves.Body.Data.data.surfaceTemp)
        for j = 1:size(resp_waves.Body.Data.data.surfaceTemp,1)
             temp_time(j,1) = datenum(resp_waves.Body.Data.data.surfaceTemp(j).timestamp,'yyyy-mm-ddTHH:MM:SS');
             surf_temp(j,1) = resp_waves.Body.Data.data.surfaceTemp(j).degrees; 
        end
        % get temperature time to same time as waves/wind        
        for j = 1:size(data.time,1)
            ind = find(temp_time == data.time(j)); 
            if ~isempty(ind)
                data.surf_temp(j,1) = surf_temp(ind); 
            else
                data.surf_temp(j,1) = nan;
            end
        end                          
    else       
        data.surf_temp = data.time.*nan;         
    end
    clear temp_time surf_temp
    
   
    %% spectral data
    if ~isempty(resp_waves.Body.Data.data.frequencyData); 
        for j = 1:size(resp.Body.Data.data.frequencyData)
            data.spec_time = datenum(resp.Body.Data.data.frequencyData(j).timestamp,'yyyy-mm-ddTHH:MM:SS'); 
            data.a1 = resp.Body.Data.data.frequencyData.a1';
            data.a2 = resp.Body.Data.data.frequencyData.a2';
            data.b1 = resp.Body.Data.data.frequencyData.b1';
            data.b2 = resp.Body.Data.data.frequencyData.b2';
            data.varianceDensity = resp.Body.Data.data.frequencyData.varianceDensity';
            data.frequency = resp.Body.Data.data.frequencyData.frequency';
            data.df = resp.Body.Data.data.frequencyData.df';
            data.directionalSpread = resp.Body.Data.data.frequencyData.directionalSpread';
            data.direction = resp.Body.Data.data.frequencyData.direction';
        end
    else
        data.spec_time = nan; 
        data.a1 = ones(1,39).*nan;
        data.a2 =ones(1,39).*nan;
        data.b1 = ones(1,39).*nan;
        data.b2 = ones(1,39).*nan;
        data.varianceDensity = ones(1,39).*nan;
        data.frequency = ones(1,39).*nan;
        data.df = ones(1,39).*nan;
        data.directionalSpread = ones(1,39).*nan;
        data.direction = ones(1,39).*nan;
    end
    
    if ii == 1
        Spotter = data; 
    else
        fields = fieldnames(Spotter); 
        for j = 1:length(fields)
            Spotter.(fields{j}) = [Spotter.(fields{j}); data.(fields{j})]; 
        end        
    end
    clear data
end









