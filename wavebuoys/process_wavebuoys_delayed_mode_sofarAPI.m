%%  Process wave buoys (delayed mode)

%Process on-board (memory card) data from Sofar Spotter, Datawell, Triaxys
%Conducts quality control based on QARTOD manual
%Outputs monthly netCDF file following IMOS conventions 

%% set initial paths for Spotter data to process and parser script
clear; clc

%location of wavebuoy_tools repo
homepath = 'C:\Users\00104893\LocalDocuments\Projects\Wave buoys\IMOS AODN\Matlab Codes\Github Repository\wavebuoy_tools\wavebuoys'; 
addpath(genpath(homepath))


%path of Sofar parser script
parserpath = 'C:\Users\00104893\LocalDocuments\Projects\Wave buoys\Spotters\SofarParser\parser_v1.11.2'; 
parser = 'parser_v1.11.2.py'; 

%% 
%buoy type and deployment info number and deployment info 
buoy_info.type = 'sofar'; 
buoy_info.serial = 'SPOT-0551'; %spotter serial number, or just Datawell 
buoy_info.version = 'Spotter-V2'; %or DWR4 for Datawell, for example
buoy_info.site_code = 'GRBNK01';
buoy_info.DeployLoc = 'GoodrichBank01';%this is IMOS site_name and station_id
buoy_info.DeployDepth = 90; 
buoy_info.DeployLat = nan; 
buoy_info.DeployLon = nan; 
buoy_info.tstart = datenum(2020,11,20,00,00,00); %Note: 'Get_Spoondrift_time_period' fails with certain choices of tstart and tend (HH,MM,SS). for now just choose to nearest (HH=00,MM=00, SS=00). 
buoy_info.tend = datenum(2021,03,28,00,00,00); 
buoy_info.DeployID = 'GRBNK0101'; %deployment number at this site
buoy_info.timezone = 9; %signed integer for UTC offset 
%use this website to calculate magnetic declination: https://www.ngdc.noaa.gov/geomag/calculators/magcalc.shtml#declination
buoy_info.MagDec = 2; 
buoy_info.sofar_token = 'e0eb70b6d9e0b5e00450929139ea34'; 


%inputs for IMOS filename structure
buoy_info.archive_path = 'C:\Users\00104893\LocalDocuments\Projects\Wave buoys\IMOS AODN\LOWE_IMOS_WaveBuoys\Data\SofarSpotter\ProcessedData_DelayedMode';
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

% double check parameter settings in '.\qaqc\qaqc_bulkparams.m' before
% proceeding

[bulkparams] = qaqc_bulkparams(bulkparams);             


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

%bulkparams
%text files for IMOS-compliant netCDF generation
globfile = [homepath '\imos_nc\metadata\glob_att_Spotter_bulkparams_timeSeries.txt']; 
varsfile = [homepath '\imos_nc\metadata\bulk_wave_parameters_mapping.csv']; 

bulkparams_to_IMOS_nc(bulkparams_nc, buoy_info.archive_path, buoy_info, globfile, varsfile); 

%displacements
%     globfile = 'E:\CUTTLER_GitHub\wavebuoy_tools\wavebuoys\imos_nc\metadata\glob_att_Spotter_displacements_timeSeries.txt';     
%     varsfile = 'E:\CUTTLER_GitHub\wavebuoy_tools\wavebuoys\imos_nc\metadata\displacements_parameters_mapping.csv';    
%     displacements_to_IMOS_nc(displacements, buoy_info.archive_path, buoy_info, globfile, varsfile); 
%     
%    %gps
%     globfile = 'E:\CUTTLER_GitHub\wavebuoy_tools\wavebuoys\imos_nc\metadata\glob_att_Spotter_locations_timeSeries.txt';     
%     varsfile = 'E:\CUTTLER_GitHub\wavebuoy_tools\wavebuoys\imos_nc\metadata\locations_parameters_mapping.csv';    
%     locations_to_IMOS_nc(locations, buoy_info.archive_path, buoy_info, globfile, varsfile); 
% 
%     %spectral data
%     globfile = 'E:\CUTTLER_GitHub\wavebuoy_tools\wavebuoys\imos_nc\metadata\glob_att_Spotter_spec_timeSeries.txt';     
%     varsfile = 'E:\CUTTLER_GitHub\wavebuoy_tools\wavebuoys\imos_nc\metadata\spec_parameters_mapping.csv';    
%     spec_to_IMOS_nc(spec, outpathNC, buoy_info, globfile, varsfile); 


cd(homepath); 
%---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------







        

        
        
       




