%%  Process wave buoys (delayed mode)

%Process on-board (memory card) data from Sofar Spotter, Datawell, Triaxys
%Conducts quality control based on QARTOD manual
%Outputs monthly netCDF file following IMOS conventions 

%% set initial paths for Spotter data to process and parser script
clear; clc

%location of wavebuoy_tools repo
homepath = 'F:\CUTTLER_GitHub\wavebuoy_tools\wavebuoys'; 
addpath(genpath(homepath))

%general path to data files - either location where raw dump of memory cardfrom Spotter is, or upper directory for Datawells
datapath = 'E:\Active_Projects\LOWE_IMOS_WaveBuoys\Data\SofarSpotter\RAW_delayed_mode\SPOT0171_TorbayEast_20200114_to_20200319'; 

%path of Sofar parser script
parserpath = 'E:\Active_Projects\LOWE_IMOS_WaveBuoys\Data\SofarSpotter\SofarParser\parser_v1.11.1'; 
parser = 'parser_v1.11.1.py'; 

%% 
%buoy type and deployment info number and deployment info 
buoy_info.type = 'sofar'; 
buoy_info.name = 'SPOT0171'; %spotter serial number, or just Datawell 
buoy_info.version = 'Spotter-V1'; %or DWR4 for Datawell, for example
buoy_info.site_code = 'TORE01';
buoy_info.DeployLoc = 'TorbayEast01';%this is IMOS site_name and station_id
buoy_info.DeployDepth = 30; 
buoy_info.DeployLat = -35.07075; 
buoy_info.DeployLon = 117.77619; 
buoy_info.DeployID = 'TorE0101'; %deployment number at this site
buoy_info.timezone = 8; %signed integer for UTC offset 
%use this website to calculate magnetic declination: https://www.ngdc.noaa.gov/geomag/calculators/magcalc.shtml#declination
buoy_info.MagDec = 1.98; 

%inputs only for Datawell folder structure
years = 2020; 
months = 1:8; 

%inputs for IMOS filename structure
buoy_info.archive_path = 'E:\Active_Projects\LOWE_IMOS_WaveBuoys\Data\SofarSpotter\ProcessedData_DelayedMode';
buoy_info.facility_code = 'NTP-WAVE';
buoy_info.data_code = 'W'; %T for temperature, W for wave
buoy_info.platform_type = 'WAVERIDER';
buoy_info.file_version = 1; 
buoy_info.product_type = 'timeseries'; 



%% process delayed mode data

%Sofar Spotter (v1 and v2) 
if strcmp(buoy_info.type,'sofar')==1
    %set number of unique time poins to use for efficient processing (depends
    %on computer specifications) 
    chunk = 10; 
    
    %process delayed mode (from buoy memory card)
    if strcmp(buoy_info.version, 'Spotter-V2')
        [bulkparams, displacements, locations, spec, sst] = process_SofarSpotter_delayed_mode(datapath, parserpath, parser, chunk);
        %test V2 data --- add sst output to 'bulkparams' for qa/qc 
    else
         [bulkparams, displacements, locations, spec, ~] = process_SofarSpotter_delayed_mode(datapath, parserpath, parser, chunk);
         bulkparams.temp = ones(size(bulkparams.time,1),1).*-9999; 
    end
    
    disp('Performing QA/QC checks...'); 
    
    % double check parameter settings in '.\qaqc\qaqc_bulkparams.m' before
    % proceeding
    
    [bulkparams] = qaqc_bulkparams(bulkparams);
    
    %add exception value based on qf_master
%     fields = {'hs','tm','tp','dm','dp','meanspr','pkspr','temp'};
%     flag = find(bulkparams.qf_master==4);   
%     for f = 1:length(fields)
%         if isfield(bulkparams, fields{f}); 
%             [bulkparams_nc] = qaqc_add_exception_value(bulkparams, fields, flag);     
%         else
%             bulkparams_nc.(fields{f}) = ones(size(bulkparams_nc.time,1),1).*nan; 
%         end
%     end        

    
    %clean up for export
    bulkparams_nc = bulkparams; 
    fields = fieldnames(bulkparams_nc); 
    for i = 1:length(fields); 
        if strcmp(fields{i}(end-1:end),'15') | strcmp(fields{i}(end-1:end),'16') | strcmp(fields{i}(end-1:end),'19') | strcmp(fields{i}(end-1:end),'20') | strcmp(fields{i}(end-1:end),'ke')
            bulkparams_nc = rmfield(bulkparams_nc, fields{i}); 
        elseif strcmp(fields{i}(1:2),'te')
            bulkparams_nc = rmfield(bulkparams_nc,fields{i}); 
        elseif strcmp(fields{i}(end-1:end),'mp')
            bulkparams_nc = rmfield(bulkparams_nc,fields{i}); 
        end           
        
    end    
        
    disp(['Saving data for ' buoy_info.name ' as netCDF']);             
    
     
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
 %Datawell DWR4 
elseif strcmp(buoy_info.type,'datawell')==1
    for yy = 1:length(years); 
        for mm = 1:length(months);             
            
            [bulkparams, displacements, locations, spec, sst] = process_Datawell_delayed_mode();
            
        end
    end    
%---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
%Triaxys
elseif strcmp(buoy_info.type,'triaxys')
    disp('No Triaxys code yet'); 
end


%%
    











        

        
        
       




