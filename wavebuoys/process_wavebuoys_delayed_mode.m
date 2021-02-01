%%  Process wave buoys (delayed mode)

%     Example usage for Sofar Spotter: 
%                 buoy_info.type = 'sofar'; 
%                 buoy_info.name = 'SPOT0171'; %spotter serial number, or deployment location for Datawell 
%                 buoy_info.DeployLoc = 'Testing';
%                 buoy_info.DeployDepth = 30; 

%     Example usage for Datawell: 
%                 buoy_info.type = 'datawell'; 
%                 buoy_info.name = 'Datawell'; %spotter serial number, or deployment location for Datawell 
%                 buoy_info.DeployLoc = 'Testing';
%                 buoy_info.DeployDepth = 30; 
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%     
% Code history
% 
%     Author          | Date             | Script Version     | Update
%     -------------------------------------------------------------------------------------------------------------------------
%     M. Cuttler     | 27 Aug 2020 | 1.0                     | Initial creation
% -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
%     M. Cuttler     | 01 Sep 2020 | 1.1                     | Modified how files are appended to bulkparameters.csv 
%                                                                           output to account for when python parser generates files in sub-directories. 
% ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
%     M. Cuttler     | 03 Sep 2020 | 1.2                     | Included displacements.csv into the workflow and output 
% ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
%     M. Cuttler     | 08 Sep 2020 | 2.0                     | Modify code
%                                                                          such that all data is appended to Matlab structures and then sub-set
%                                                                          into monthly files for more efficient storage (may still run into
%                                                                          Matlab memory issues 
% ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
%     M. Cuttler     | 05 Oct 2020 | 2.1                     | Incorporate
%                                                                          first QARTOD QA/QC tests - Time series bulk wave parameters
%                                                                          max/min/acceptable range (test 19, required)
%---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
%     M. Cuttler     | 09 Oct 2020 | 3.0                     | re-organise code structure. 
%                                                                        | THIS CODE IS NOW THE 'RUN' CODE, USE THIS TO SET BASIC PARAMETERS FOR FILEPATHS, 
%                                                                        | QC LIMITS, ETC
%                                                                        | SEE FUNCTIONS WITHIN THIS CODE FOR ACTUAL DATA PROCESSING
% ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
%     M. Cuttler     | 13 Oct 2020 | 3.0                     | re-organise code structure - aim to generalise across Datawell and Sofar buoys
%                                                                        | 

%% set initial paths for Spotter data to process and parser script
clear; clc

%location of wavebuoy_tools repo
homepath = 'E:\CUTTLER_GitHub\wavebuoy_tools\wavebuoys'; 
addpath(genpath(homepath))

%general path to data files - either location where raw dump of memory card
%from Spotter is, or upper directory for Datawells
datapath = 'D:\Active_Projects\LOWE_IMOS_WaveBuoys\Data\SofarSpotter\CodeTesting\Data_for_testing_Spotter_V1'; 
%path of Sofar parser script
parserpath = 'D:\Active_Projects\LOWE_IMOS_WaveBuoys\Data\SofarSpotter\SofarParser\parser_v1.11.1'; 
parser = 'parser_v1.11.1.py'; 


%buoy type and deployment info number and deployment info 
buoy_info.type = 'sofar'; 
buoy_info.name = 'SPOT0171'; %spotter serial number, or just Datawell 
buoy_info.version = 'V1'; %or DWR4 for Datawell, for example
buoy_info.DeployLoc = 'Testing';
buoy_info.DeployDepth = 30; 
buoy_info.DeployLat = -35; 
buoy_info.DeployLon = 117; 
%use this website to calculate magnetic declination: https://www.ngdc.noaa.gov/geomag/calculators/magcalc.shtml#declination
buoy_info.MagDec = 1.98; 

%inputs only for Datawell
years = 2020; 
months = 1:8; 



%% process delayed mode data

%Sofar Spotter (v1 and v2) 
if strcmp(buoy_info.type,'sofar')==1
    %set number of unique time poins to use for efficient processing (depends
    %on computer specifications) 
    chunk = 10; 
    
    %process delayed mode (from buoy memory card)
    if strcmp(buoy_info.version, 'V2')
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
        end
    end    
        
    disp(['Saving data for ' buoy_info.name ' as netCDF']);             
    
    %path to save netCDF files for transfer to AODN
    outpathNC = 'D:\Active_Projects\LOWE_IMOS_WaveBuoys\Data\SofarSpotter\CodeTesting\Output_testing';
    
    %bulkparams
    %text files for IMOS-compliant netCDF generation
    globfile = 'E:\CUTTLER_GitHub\wavebuoy_tools\wavebuoys\imos_nc\metadata\glob_att_Spotter_bulkparams_timeSeries.txt';     
    varsfile = 'E:\CUTTLER_GitHub\wavebuoy_tools\wavebuoys\imos_nc\metadata\bulk_wave_parameters_mapping.csv';        
    bulkparams_to_IMOS_nc(bulkparams_nc, outpathNC, buoy_info, globfile, varsfile); 
    
    %displacements
    globfile = 'E:\CUTTLER_GitHub\wavebuoy_tools\wavebuoys\imos_nc\metadata\glob_att_Spotter_displacements_timeSeries.txt';     
    varsfile = 'E:\CUTTLER_GitHub\wavebuoy_tools\wavebuoys\imos_nc\metadata\displacements_parameters_mapping.csv';    
    displacements_to_IMOS_nc(displacements, outpathNC, buoy_info, globfile, varsfile); 
    
   %gps
    globfile = 'E:\CUTTLER_GitHub\wavebuoy_tools\wavebuoys\imos_nc\metadata\glob_att_Spotter_locations_timeSeries.txt';     
    varsfile = 'E:\CUTTLER_GitHub\wavebuoy_tools\wavebuoys\imos_nc\metadata\locations_parameters_mapping.csv';    
    locations_to_IMOS_nc(locations, outpathNC, buoy_info, globfile, varsfile); 

    %spectral data
    globfile = 'E:\CUTTLER_GitHub\wavebuoy_tools\wavebuoys\imos_nc\metadata\glob_att_Spotter_spec_timeSeries.txt';     
    varsfile = 'E:\CUTTLER_GitHub\wavebuoy_tools\wavebuoys\imos_nc\metadata\spec_parameters_mapping.csv';    
    spec_to_IMOS_nc(spec, outpathNC, buoy_info, globfile, varsfile); 
    
    
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

%% save as .mat file

outpathMAT = 'E:\Active_Projects\LOWE_IMOS_WaveBuoys\Data';
filenameMAT = [outpathMAT '\' buoy_info.name '_' buoy_info.DeployLoc '_' datestr(bulkparams.time(1),'yyyymm') '_' datestr(bulkparams.time(end),'yyyymm')  '.mat'];         
vars = who; 
idx=[];
for jj = 1:length(vars); 
    if  isstruct(eval(vars{jj}))
        idx = [idx;jj];
    end
end        
        
save(filenameMAT,vars{idx}); 

%%
    











        

        
        
       




