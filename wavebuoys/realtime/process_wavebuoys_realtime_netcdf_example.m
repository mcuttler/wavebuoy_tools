%% Process wave buoys real-time to netCDF 
%This follows AODN - ARDC netCDF convetions and is designed to be compiled
%to an executable for running in near real time 

%%
clear; clc
%location of wavebuoy_tools repo
mpath = 'C:\Data\wavebuoy_tools\wavebuoys'; 
addpath(genpath(mpath))
 
%% General attributes

%general path to data files - use the 'realtime_archive_backup' as
%sometimes AWS corrupts the .mat files 
buoy_info.datapath = '\\drive.irds.uwa.edu.au\OGS-COD-001\CUTTLER_wawaves\Data\realtime_archive_backup'; 

%buoy type and deployment info number and deployment info 
buoy_info.type = 'datawell'; %datawell or sofar
buoy_info.serial = '74103'; %datawell hull serial or SPOT ID 
buoy_info.instrument = 'Datawell DWR Mk4'; %Datawell DWR Mk4; Sofar Spotter-V2 (or V1)
buoy_info.name = 'Torbay'; %name in UWA archive 
buoy_info.site_name = 'TORBAY'; %needs to be capital; if multiple part name, separate with dash (i.e. GOODRICH-BANK)
buoy_info.DeployDepth = 30; 
buoy_info.timezone = 8; %signed integer for UTC offset 
%use this website to calculate magnetic declination: https://www.ngdc.noaa.gov/geomag/calculators/magcalc.shtml#declination
buoy_info.MagDec = 10.20; 
buoy_info.watch_circle = 200; %radius of watch circle in meters; 

%inputs for IMOS-ARDC filename structure
buoy_info.archive_path = '\\drive.irds.uwa.edu.au\OGS-COD-001\CUTTLER_wawaves\Data\realtime_archive_backup';

%additional attributes for IMOS netCDF
buoy_info.project = 'UWA Nearshore wave buoy program'; 
buoy_info.wave_motion_sensor_type = 'accelerometer';
buoy_info.wave_sensor_serial_number = buoy_info.serial; 
buoy_info.hull_serial_number = buoy_info.serial; 
buoy_info.instrument_burst_duration = 1800; 
buoy_info.instrument_burst_interval = 1800; 
buoy_info.instrument_sampling_interval = 0.4; %0.4 for Spotter (2.5 Hz), 0.3906 for Datawell (2.56 Hz)
buoy_info.institution = 'UWA'; 
buoy_info.transmission = 'Iridium'; %Iridium or Cellular-4G 
buoy_info.data_mode = 'RT'; %can be 'DM' (delayed mode) or 'RT' (real time)
buoy_info.buoy_specification_url = 'https://s3-ap-southeast-2.amazonaws.com/content.aodn.org.au/Documents/AODN/Waves/Instruments_manuals/datawell_brochure_dwr4_acm_b-38-09.pdf';
%url for Spotter: 'https://s3-ap-southeast-2.amazonaws.com/content.aodn.org.au/Documents/AODN/Waves/Instruments_manuals/Spotter_SpecSheet%20Expanded.pdf';
%url for Datawell:  'https://s3-ap-southeast-2.amazonaws.com/content.aodn.org.au/Documents/AODN/Waves/Instruments_manuals/datawell_brochure_dwr4_acm_b-38-09.pdf';

%% Load existing .mat archive 
%check whether to load last two months or just last month
tnow = datenum(now) - (8/24); 
tnow = datevec(tnow); 
if tnow(3)==1 & tnow(4)<3
    %first load older data
    if tnow(2)==1
        dpath = fullfile(buoy_info.archive_path, buoy_info.name,'mat_archive',num2str(tnow(1)-1));        
        dfile = [buoy_info.name '_' num2str(tnow(1)-1) '12.mat']; 
    else
        dpath = fullfile(buoy_info.archive_path, buoy_info.name,'mat_archive',num2str(tnow(1)));   
        dfile = [buoy_info.name '_' num2str(tnow(1)) num2str(tnow(2)-1,'%02d') '.mat'];
    end
    dum = load(fullfile(dpath, dfile)); 
    archive_data = dum.dw_data;  
    clear dum
    %now load most recent 
    [dum] = load_archived_data(buoy_info.archive_path, buoy_info);
    %append the two together
    fields = fieldnames(archive_data); 
    for i = 1:length(fields)
        if isfield(dum, fields{i})
            archive_data.(fields{i}) = [archive_data.(fields{i}); dum.(fields{i})]; 
        else
            archive_data.(fields{i}) = dum.(fields{i}); 
        end
    end       
else
    [archive_data] = load_archived_data(buoy_info.archive_path, buoy_info);
end

% add missing parameters for datawell
if strcmp(buoy_info.type,'datawell')
    archive_data.lat = ones(size(archive_data.time)).*-9999; 
    archive_data.lon = ones(size(archive_data.time)).*-9999; 
    archive_data.tm = ones(size(archive_data.time)).*-9999; 
    archive_data.dm = ones(size(archive_data.time)).*-9999; 
    archive_data.dmspr = ones(size(archive_data.time)).*-9999; 
end

%% set parameters for netCDF writing

globfile = [mpath '\imos_nc\metadata\glob_att_integralParams_ardc_RT.txt']; 
if strcmp(buoy_info.type,'datawell')
    varsfile = [mpath '\imos_nc\metadata\bulkwave_parameters_RT_mapping_DWR4.csv']; 
else
    varsfile = [mpath '\imos_nc\metadata\bulkwave_parameters_RT_mapping.csv']; 
end

tdum = datevec(archive_data.time); 
tdum_unique = unique(tdum(:,1:2),'rows'); 
if size(tdum_unique,1)>1
    for j = 1:size(tdum_unique,1) 
        if j == size(tdum_unique,1)
            ind_waves = find(archive_data.time>=datenum(tdum_unique(j,1), tdum_unique(j,2), 1)); 
            ind_temp = find(archive_data.temp_time>=datenum(tdum_unique(j,1), tdum_unique(j,2), 1)); 
        else
            ind_waves = find(archive_data.time>=datenum(tdum_unique(j,1), tdum_unique(j,2), 1)&...
                archive_data.time<datenum(tdum_unique(j+1,1),tdum_unique(j+1,2),1)); 
            ind_temp = find(archive_data.temp_time>=datenum(tdum_unique(j,1), tdum_unique(j,2), 1)&...
                archive_data.temp_time<datenum(tdum_unique(j+1,1),tdum_unique(j+1,2),1)); 
        end
        dataout = struct('time',[],'hsig',[],'tm',[],'tp',[],'dm',[],'dmspr',[],'dp',[],...
            'dpspr',[],'qf_waves',[]); 
        fields = fieldnames(dataout);
        for jj = 1:length(fields)
            dataout.(fields{jj}) = archive_data.(fields{jj})(ind_waves,:);         
        end
        
        %write monthly netCDF
        bulkparams_to_IMOS_ARDC_nc_RT(dataout, buoy_info, globfile, varsfile); 
    end
else
    dataout = struct('time',[],'lat',[],'lon',[],'hsig',[],'tm',[],'tp',[],'dm',[],'dmspr',[],'dp',[],...
        'dpspr',[],'qf_waves',[]); 
    fields = fieldnames(dataout);
    for jj = 1:length(fields)
        dataout.(fields{jj}) = archive_data.(fields{jj});   
    end    
    bulkparams_to_IMOS_ARDC_nc_RT(dataout, buoy_info, globfile, varsfile);
end


            
        
        
            
            
    
        
    
    





