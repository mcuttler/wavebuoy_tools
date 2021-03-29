%% parse spotter CSV

%use this to extract data from CSV downloaded from Sofar dashboard
%convert CSV to XLSX first
%written for spectral file - need to fix for parametric 
%%

function [SpotData] = parse_sofar_csv(file, buoy_info, start_time)

data = importdata(file); 

if strcmp(buoy_info.DataType,'spectral')
    SpotData = struct('time',[],'hsig',[],'tp',[],'tm',[],'dp',[],'dpspr',[],'dm',[],'dmspr',[],...
        'lat',[],'lon',[],'wind_time',[],'wind_speed',[],'wind_dir',[],'wind_seasurfaceId',[],'a1',[],'b1',[],...
        'a2',[],'b2',[],'varianceDensity',[],'frequency',[],'df',[],'directionalSpread',[],'direction',[],...
        'spec_time',[],'serialID',[],'name',[]);
else
    SpotData = struct('time',[],'hsig',[],'tp',[],'tm',[],'dp',[],'dpspr',[],'dm',[],'dmspr',[],...
        'lat',[],'lon',[],'wind_time',[],'wind_speed',[],'wind_seasurfaceId',[],'serialID',[],'name',[]);
end

SpotData.time = datenum(datetime(data.data(:,4),'convertFrom','posixtime'));
SpotData.spec_time = datenum(datetime(data.data(:,4),'convertFrom','posixtime'));
SpotData.wind_time = datenum(datetime(data.data(:,4),'convertFrom','posixtime'));

SpotData.hsig = data.data(:,5); 
SpotData.tp = data.data(:,6); 
SpotData.tm = data.data(:,7); 
SpotData.dp = data.data(:,8); 
SpotData.dpspr = data.data(:,9); 
SpotData.dm = data.data(:,10); 
SpotData.dmspr = data.data(:,11); 
SpotData.lat = data.data(:,12); 
SpotData.lon = data.data(:,13); 
SpotData.frequency = data.data(:,14:52); 
SpotData.df = data.data(:,53:91); 
SpotData.a1 = data.data(:,92:130); 
SpotData.b1 = data.data(:,131:169); 
SpotData.a2 = data.data(:,170:208); 
SpotData.b2 = data.data(:,209:247); 
SpotData.varianceDensity = data.data(:,248:286); 
SpotData.direction = data.data(:,287:325); 
SpotData.directionalSpread = data.data(:,326:364); 
SpotData.wind_speed = data.data(:,365); 
SpotData.wind_dir = data.data(:,366); 
SpotData.wind_seasurfaceId = ones(size(data.data,1),1).*nan; 

for i = 1:size(data.data,1)
    SpotData.serialID{i,1} = buoy_info.serial; 
    SpotData.name{i,1} = buoy_info.name;
end

idx = find(SpotData.time>=start_time); 

fields = fieldnames(SpotData); 
for i = 1:length(fields)
    SpotData.(fields{i}) = SpotData.(fields{i})(idx,:); 
end


    
    
end




    
    
    
