%%  Process wave buoys (delayed mode)

%Process on-board (memory card) data from Sofar Spotter, Datawell, Triaxys
%Conducts quality control based on QARTOD manual
%Outputs monthly netCDF file following IMOS conventions 

%% set initial paths for Spotter data to process and parser script
clear; clc

%location of wavebuoy_tools repo
homepath = 'C:\Users\00084142\OneDrive - The University of Western Australia\CUTTLER_GitHub\wavebuoy_tools\wavebuoys'; 
addpath(genpath(homepath))


%path of Sofar parser script
parserpath = 'C:\Users\00084142\OneDrive - The University of Western Australia\CUTTLER_GitHub\wavebuoy_tools\wavebuoys\sofar\spotter_tools'; 
parser = 'parser_v1.12.0.py'; 

%% 
%buoy type and deployment info number and deployment info 
buoy_info.type = 'sofar'; 
buoy_info.serial = 'SPOT-0757'; %spotter serial number, or just Datawell 
buoy_info.version = 'Spotter-V1'; %or DWR4 for Datawell, for example
buoy_info.site_code = 'GRBNK01';
buoy_info.DeployLoc = 'TorbayEast';%this is IMOS site_name and station_id
buoy_info.DeployDepth = 90; 
buoy_info.DeployLat = nan; 
buoy_info.DeployLon = nan; 
buoy_info.tstart = datenum(2022,5,3,0,0,0); %Note: 'Get_Spoondrift_time_period' fails with certain choices of tstart and tend (HH,MM,SS). for now just choose to nearest (HH=00,MM=00, SS=00). 
buoy_info.tend = datenum(2022,9,16,0,0,0); 
buoy_info.DeployID = 'TorbayEast'; %deployment number at this site
buoy_info.timezone = 9; %signed integer for UTC offset 
%use this website to calculate magnetic declination: https://www.ngdc.noaa.gov/geomag/calculators/magcalc.shtml#declination
buoy_info.MagDec = 2; 
buoy_info.sofar_token = 'e0eb70b6d9e0b5e00450929139ea34'; 

%UWA Token:   e0eb70b6d9e0b5e00450929139ea34
%VIC Token:   ae7abf179e2b697c24fea513aae16e

%inputs for IMOS filename structure
buoy_info.archive_path = 'E:\wawaves';
buoy_info.backup_path = '\\drive.irds.uwa.edu.au\OGS-COD-001\CUTTLER_wawaves\Data\realtime_archive_backup';
buoy_info.facility_code = 'NTP-WAVE';
buoy_info.data_code = 'TW'; %T for temperature, W for wave
buoy_info.platform_type = 'WAVERIDER';
buoy_info.file_version = 1; 
buoy_info.product_type = 'timeseries'; 

%% process delayed mode data

%Sofar Spotter (v1 and v2) 

%process delayed mode (from buoy memory card)
bulkparams = Get_Spoondrift_time_period(buoy_info, buoy_info.tstart, buoy_info.tend); 

%remove spectral parameters all nan
if all(isnan(bulkparams.a1(:,1)))==1
    fields = {'a1','a2','b1','b2','spec_time','varianceDensity','frequency','df','directionalSpread','direction'};
    for j = 1:length(fields)
        bulkparams = rmfield(bulkparams,fields{j}); 
    end
end


disp('Performing QA/QC checks...');

% double check parameter settings here 

check.time = bulkparams.time; 
check.temp_time = bulkparams.time; %for V2 buoys the timestamps are the same 
bulkparams.temp_time = bulkparams.time; 
check.WVHGT = bulkparams.hs;
check.WVPD = bulkparams.tp; %parameter for range test (could also be mean) 
check.WVDIR = bulkparams.dp; %parameter for range test (could also be mean)
check.STD = 3; % mean + std test
check.time_window = 72; %hours for calculating mean + std    
check.WHTOL = 0.025; % flat line
check.WPTOL = 0.01; % flat line
check.WDTOL = 0.5;  %flat line
check.WSPTOL = 0.5; %flat line
check.TTOL = 0.01; %flat line 
check.rep_fail = 240;  %  flat line (hrs)
check.rep_suspect = 144; % flat line (hrs) 
check.MINWH = 0.10; %min height 
check.MAXWH = 10; %max height
check.MINWP = 3; %min period
check.MAXWP = 25; %max period
check.MINSV = 0.07; %min spread
check.MAXSV = 80.0; %max spread
check.MINT = 5; %min temp
check.MAXT = 55; %max temp
check.WHROC= 2; %height rate of change
check.WPROC= 10; %period rate of change
check.WDROC= 50; %direction rate of change
check.WSPROC= 25; %spreading rate of change
check.TROC = 2; %temp rate of change
check.wave_fields = {'hs','tp','dp'}; %fields for assigning primary/secondary subflags 
check.temp_fields = {'surf_temp'}; %fields for assigning primary/secondary subflags 
check.qaqc_tests = {'15','16','19','20','spike'}; % qaqc tests to use in assigning flags 

[bulkparams] = qaqc_bulkparams(bulkparams,check);             


%clean up for export
bulkparams_nc = bulkparams; 
fields = fieldnames(bulkparams_nc); 
for i = 1:length(fields); 
    if strcmp(fields{i}(end-1:end),'15') | strcmp(fields{i}(end-1:end),'16') | strcmp(fields{i}(end-1:end),'19') | strcmp(fields{i}(end-1:end),'20') | strcmp(fields{i}(end-1:end),'ke')
        bulkparams_nc = rmfield(bulkparams_nc, fields{i}); 
        %         elseif strcmp(fields{i}(1:2),'te')
        %             bulkparams_nc = rmfield(bulkparams_nc,fields{i}); 
        %         elseif strcmp(fields{i}(end-1:end),'mp')
        %             bulkparams_nc = rmfield(bulkparams_nc,fields{i}); 
    end
    if strcmp(fields{i},'serialID')
        bulkparams_nc = rmfield(bulkparams_nc, fields{i}); 
    end      
end

%rename surf_temp to temp for export **MC to fix this in future 
bulkparams_nc.temp = bulkparams_nc.surf_temp; 
bulkparams_nc = rmfield(bulkparams_nc,'surf_temp'); 

%quickly denan and replace with fill values
fields = fieldnames(bulkparams_nc); 
for i = 1:length(fields)
    if strcmp(fields{i},'qc_flag_wave') | strcmp(fields{i},'qc_subflag_wave') | strcmp(fields{i},'qc_flag_temp') | strcmp(fields{i},'qc_subflag_wave')
        bulkparams_nc.(fields{i})(isnan(bulkparams_nc.(fields{i}))) = -127; 
    else
        bulkparams_nc.(fields{i})(isnan(bulkparams_nc.(fields{i}))) = -9999;
    end
end

%rename mean and peak spreading --- not sure what convention, but this is
%based on the mapping file (varsfile below)
bulkparams_nc.pkspr = bulkparams_nc.dpspr; 
bulkparams_nc.meanspr = bulkparams_nc.dmspr; 


%bulkparams
%text files for IMOS-compliant netCDF generation
globfile = [homepath '\imos_nc\metadata\ntp\glob_att_Spotter_bulkparams_timeSeries.txt']; 
varsfile = [homepath '\imos_nc\metadata\ntp\bulk_wave_parameters_mapping.csv']; 

bulkparams_to_IMOS_nc(bulkparams_nc, buoy_info.archive_path, buoy_info, globfile, varsfile); 

cd(homepath); 
%% check the file you just created - checks most recent file in the archive directory  
archive_path = fullfile(buoy_info.archive_path,'nc',buoy_info.DeployLoc); 
files = dir(archive_path); files = files(3:end); 
for j = 1:size(files,1)
    dt(j,1) = datenum(files(j).date);
end
[~,I] = sort(dt,'descend');%sorts so most recently is first; 
files = files(I); 

ncfile = fullfile(files(1).folder, files(1).name); 
data.time = ncread(ncfile,'TIME')+datenum(1950,1,1); 
data.hs = ncread(ncfile,'WSSH'); 
data.tp = ncread(ncfile,'WPPE');
data.tm = ncread(ncfile,'WPFM'); 
data.dp = ncread(ncfile,'WPDI'); 
data.dm = ncread(ncfile,'SSWMD');
data.pkspr = ncread(ncfile,'WPDS'); 
data.meanspr = ncread(ncfile,'WMDS'); 
data.quality_flag = ncread(ncfile,'wave_quality_flag'); 
data.quality_subflag = ncread(ncfile,'wave_subflag'); 

data.lon = ncread(ncfile,'LONGITUDE');
data.lat = ncread(ncfile,'LATITUDE');









        

        
        
       




