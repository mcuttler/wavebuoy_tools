%%  Process wave buoys (delayed mode)

%Process on-board (memory card) data from Sofar Spotter, Datawell, Triaxys
%Conducts quality control based on QARTOD manual
%Outputs monthly netCDF file following IMOS conventions 

%% set initial paths for Spotter data to process and parser script
clear; clc

%location of wavebuoy_tools repo

homepath = 'C:\Users\00104893\LocalDocuments\Projects\Wave buoys\IMOS AODN\Matlab Codes\Github Repository\wavebuoy_tools\wavebuoys'; 
addpath(genpath(homepath))

%general path to data files - either location where raw dump of memory cardfrom Spotter is, or upper directory for Datawells
datapath = 'C:\Users\00104893\LocalDocuments\Projects\Wave buoys\Spotters\Data\SPOT1109_CapeBridgewaterDC_20210624_to_20211203'; 


%path of Sofar parser script
parserpath = 'C:\Users\00104893\LocalDocuments\Projects\Wave buoys\Spotters\SofarParser\parser_v1.11.2'; 
parser = 'parser_v1.11.2.py'; 


%% 
%buoy type and deployment info number and deployment info 
buoy_info.type = 'sofar'; 
buoy_info.name = 'SPOT-1109'; %spotter serial number, or just Datawell 
buoy_info.version = 'Spotter-V2'; %or DWR4 for Datawell, for example
buoy_info.site_code = 'CAPEBW01';
buoy_info.DeployLoc = 'CapeBridgewater01';%this is IMOS site_name and station_id
buoy_info.DeployDepth = 69; 
buoy_info.DeployLat = nan; 
buoy_info.DeployLon = nan; 
buoy_info.tstart = datenum(2021,06,24,07,59,15); 
buoy_info.tend = datenum(2021,12,03,02,28,44); 
buoy_info.DeployID = 'CAPEBW0103'; %deployment number at this site
buoy_info.timezone = 10; %signed integer for UTC offset 
%use this website to calculate magnetic declination: https://www.ngdc.noaa.gov/geomag/calculators/magcalc.shtml#declination
buoy_info.MagDec = 10.20; 


%inputs for IMOS filename structure
buoy_info.archive_path = 'C:\Users\00104893\LocalDocuments\Projects\Wave buoys\IMOS AODN\LOWE_IMOS_WaveBuoys\Data\SofarSpotter\ProcessedData_DelayedMode';

buoy_info.facility_code = 'NTP-WAVE';
buoy_info.data_code = 'TW'; %T for temperature, W for wave
buoy_info.platform_type = 'WAVERIDER';
buoy_info.file_version = 1;   %Not sure what this is? or if I should change?
buoy_info.product_type = 'timeseries'; 

%% process delayed mode data

%Sofar Spotter (v1 and v2) 
if strcmp(buoy_info.type,'sofar')==1
    %set number of unique time poins to use for efficient processing (depends
    %on computer specifications) 
    chunk = 20; 
    
    %process delayed mode (from buoy memory card)
    if strcmp(buoy_info.version, 'Spotter-V2')
        [bulkparams, displacements, locations, spec, sst] = process_SofarSpotter_delayed_mode(datapath, parserpath, parser, chunk);       
        %down sample temperature to be at same time stamp as wave data 
        [bulkparams] = sofar_join_bulkparams_and_sst(bulkparams, sst); 
    else
         [bulkparams, displacements, locations, spec, ~] = process_SofarSpotter_delayed_mode(datapath, parserpath, parser, chunk);
         bulkparams.temp = ones(size(bulkparams.time,1),1).*-9999; 
    end
    
    disp('Performing QA/QC checks...'); 
    
     %clip to time of interest
     clear idx
     idx = find(bulkparams.time>=buoy_info.tstart&bulkparams.time<=buoy_info.tend); 
     tsize = size(bulkparams.time,1); 
     fields = fieldnames(bulkparams); 
     for i = 1:length(fields); 
         if size(bulkparams.(fields{i}),1)==tsize
             bulkparams.(fields{i}) = bulkparams.(fields{i})(idx,:); 
         end
     end       
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
        
    end    
    
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
 %Datawell DWR4 
elseif strcmp(buoy_info.type,'datawell')==1
   %create blank array for output
    dw_vars = {'serialID','E','theta','s','m2','n2','time','a1','a2','b1','b2',...
        'frequency','ndirec','spec2D','hsig','tp','dp','dpspr', 'curr_mag','curr_dir',...
        'curr_mag_std','curr_dir_std','temp_time','surf_temp','bott_temp','w','w_std',...
        'gps_time','gps_pos','disp_tstart','disp_time','disp_h','disp_n','disp_w'}; 
    for i = 1:length(dw_vars)
        data.(dw_vars{i}) = []; 
    end
    
     cnt=1;
     %loop through directory of files output from CF card (need datawell
     %lib to convert to CSV)
     files=dir((fullfile(datapath,'*-20.csv'))); %get all the field to process 20 file is 1D spectra
     for kk=2:length(files) %file 1 is bad 1970 file
         disp(['File ' num2str(kk) ' out of ' num2str(length(files))]); 
         fname=files(kk).name(1:10);
         
         input.file20 = [datapath fname  '-20.csv'];
         input.file21 =[datapath fname  '-21.csv'];
         input.file25 =[datapath fname  '-25.csv'];
         input.file28 = [datapath fname  '-28.csv'];
         input.file80 =[datapath fname  '-80.csv'];
         input.file82 =[datapath fname  '-82.csv'];
         input.file23 = [datapath fname '-23.csv'];
         input.filed = [datapath fname '-displacement.csv'];
         
         %load and organize data for each file containing 4 days of data
         [temp] = Process_Datawell_delayed_mode(buoy_info, data, input.file20, input.file21, input.file25, input.file28, input.file80, input.file82, input.file23, input.filed);   
         clear input
         
         %now append
         if cnt==1
             data=temp;
             data.hs=data.hsig;
             data = rmfield(data,'hsig');
             data.temp=data.surf_temp;
             data = rmfield(data,'surf_temp');
             data.pkspr = data.dpspr;
             data = rmfield(data,'dpspr'); 
             
             cnt=cnt+1;
             clear temp
         else
             fields = fieldnames(data); 
             for jj = 1:length(fields)
                 if strcmp(fields{jj}, 'spec2D')
                     data.spec2D = cat(3,data.spec2D,temp.spec2D);
                 elseif strcmp(fields{jj},'hs')
                     data.hs = [data.hs; temp.hsig];
                 elseif strcmp(fields{jj},'temp')
                     data.temp = [data.temp; temp.surf_temp]; 
                 elseif strcmp(fields{jj},'pkspr')
                     data.pkspr = [data.pkspr; temp.dpspr]; 
                 else                     
                     data.(fields{jj}) = [data.(fields{jj}); temp.(fields{jj})];
                 end
             end                  
             clear temp
             cnt=cnt+1;
         end         
     end
     %run delayed mode QAQC
     disp('Performing QA/QC checks...'); 
     [data] = qaqc_bulkparams(data);
     
     fname = [buoy_info.name '_' buoy_info.serial '_' datestr(data.time(1),'yyyymmdd') '-' datestr(data.time(end),'yyyymmdd') '.mat'];
     save(fullfile(buoy_info.archive_path, fname),'data','-v7.3'); 
     
%---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
%Triaxys
elseif strcmp(buoy_info.type,'triaxys')
    disp('No Triaxys code yet'); 
end

%%
    











        

        
        
       




