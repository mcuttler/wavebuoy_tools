% testing netcdf
clear; close all; clc; 

load('E:\CUTTLER_GitHub\wavebuoy_tools\wavebuoys\imos_nc\testing_nc.mat'); 
buoy_info.type = 'sofar'; 
buoy_info.name = 'SPOT0171'; %spotter serial number, or just Datawell 
buoy_info.station_id = 'TorbayEast'; 
buoy_info.version = 'V1'; %or DWR4 for Datawell, for example
buoy_info.DeployLoc = 'Testing';
buoy_info.DeployDepth = 30; 
buoy_info.DeployLat = -35; 
buoy_info.DeployLon = 117; 
buoy_info.timezone = 8; %signed integer for UTC offset 
%use this website to calculate magnetic declination: https://www.ngdc.noaa.gov/geomag/calculators/magcalc.shtml#declination
buoy_info.MagDec = 1.98; 

%inputs only for Datawell
years = 2020; 
months = 1:8; 

%%

outpathNC = 'D:\Active_Projects\LOWE_IMOS_WaveBuoys\Data\SofarSpotter\CodeTesting\Output_testing';

%bulkparams
%text files for IMOS-compliant netCDF generation
globfile = 'E:\CUTTLER_GitHub\wavebuoy_tools\wavebuoys\imos_nc\metadata\glob_att_Spotter_bulkparams_timeSeries.txt';     
varsfile = 'E:\CUTTLER_GitHub\wavebuoy_tools\wavebuoys\imos_nc\metadata\bulk_wave_parameters_mapping.csv';        
bulkparams = bulkparams_nc; 

bulkparams_to_IMOS_nc(bulkparams, outpathNC, buoy_info, globfile, varsfile); 