%%  Process Sofar wave buoys (delayed mode) following AODN-ARDC conventions

%Process on-board (memory card) data from Sofar Spotter
%Conducts quality control based on QARTOD manual
%Outputs netCDF file following IMOS (AODN, 2022) conventions 

%% set initial paths for Spotter data to process and parser script
clear; clc
%location of wavebuoy_tools repo
mpath = 'C:\Users\00084142\OneDrive - The University of Western Australia\CUTTLER_GitHub\wavebuoy_tools\wavebuoys'; 
addpath(genpath(mpath))


%% General attributes 

%general path to data files - either location where raw dump of memory cardfrom Spotter is, or upper directory for Datawells
buoy_info.datapath = 'C:\Users\00084142\OneDrive - The University of Western Australia\HANSEN_ARDC_WaveBuoys\Data\Sofar\DM_data\SPOT0168_KingGeorgeSound_20201211_to_20210326'; 
%path to matlab directory --- only needed for Spotter processing 
% buoy_info.matpath = 'C:\Users\00084142\AppData\Local\Turbo.net\Sandbox\MATLAB\9.11.0.1687835\local\meta\@PROGRAMFILES@\MATLAB\R2021b\bin'; 
% buoy_info.pypath = 'C:\Users\00084142\Anaconda3'; 
%buoy type and deployment info number and deployment info 
buoy_info.type = 'sofar'; 
buoy_info.serial = 'SPOT-0559'; %
buoy_info.instrument = 'Sofar Spotter-V1'; %Datawell DWR Mk4; Sofar Spotter-V2 (or V1)
buoy_info.site_name = 'KING-GEORGE-SOUND'; %needs to be capital; if multiple part name, separate with dash (i.e. GOODRICH-BANK)
buoy_info.DeployDepth = 15; 
buoy_info.startdate = datenum(2021,7,1); 
buoy_info.enddate = datenum(2021,8,1); 
buoy_info.timezone = 8; %signed integer for UTC offset 
%use this website to calculate magnetic declination: https://www.ngdc.noaa.gov/geomag/calculators/magcalc.shtml#declination
buoy_info.MagDec = 10.20; 
buoy_info.watch_circle = 100; %radius of watch circle in meters;
%spotter spec_sheet
buoy_info.buoy_specification_url = 'https://s3-ap-southeast-2.amazonaws.com/content.aodn.org.au/Documents/AODN/Waves/Instruments_manuals/Spotter_SpecSheet%20Expanded.pdf';
%DWR4 spec sheet
% buoy_info.buoy_specification_url = 'https://s3-ap-southeast-2.amazonaws.com/content.aodn.org.au/Documents/AODN/Waves/Instruments_manuals/datawell_brochure_dwr4_acm_b-38-09.pdf'
%inputs for IMOS-ARDC filename structure
buoy_info.archive_path = 'C:\Users\00084142\OneDrive - The University of Western Australia\HANSEN_ARDC_WaveBuoys\Data\ExampleUWA_netcdf';

%additional attributes for IMOS netCDF
buoy_info.project = 'UWA Nearshore wave buoy program'; 
buoy_info.wave_motion_sensor_type = 'GPS';
buoy_info.wave_sensor_serial_number = buoy_info.serial; 
buoy_info.hull_serial_number = buoy_info.serial; 
buoy_info.instrument_burst_duration = 1800; 
buoy_info.instrument_burst_interval = 1800; 
buoy_info.instrument_sampling_interval = 0.4; %sample frequency
buoy_info.institution = 'UWA'; 
buoy_info.data_mode = 'DM'; %can be 'DM' (delayed mode) or 'RT' (real time)


%% process delayed mode data

%Sofar Spotter (v1 and v2) 
if strcmp(buoy_info.type,'sofar')==1
    %path of Sofar parser script
%     parserpath = 'C:\Users\00084142\OneDrive - The University of Western Australia\CUTTLER_GitHub\wavebuoy_tools\wavebuoys\sofar\spotter_tools'; 
%     parser = 'parser_v1.12.0.py'; 
%     %set number of unique time poins to use for efficient processing (depends
%     %on computer specifications) 
%     chunk = 10; 
    
    %process delayed mode (from buoy memory card)
%     if strcmp(buoy_info.instrument, 'Sofar Spotter-V2')
%         [bulkparams, displacements, locations, spec, sst] = process_SofarSpotter_delayed_mode(buoy_info.datapath, parserpath, parser, chunk);       
%         %down sample temperature to be at same time stamp as wave data 
%         [bulkparams] = sofar_join_bulkparams_and_sst(bulkparams, sst); 
%     else
%          [bulkparams, displacements, locations, spec, ~] = process_SofarSpotter_delayed_mode(buoy_info.datapath, parserpath, parser, chunk);
%          bulkparams.temp = ones(size(bulkparams.time,1),1).*-9999; 
%     end         

    %re-organise so all parameters of interest are in one data structure
    load('C:\Users\00084142\OneDrive - The University of Western Australia\HANSEN_ARDC_WaveBuoys\Data\Sofar\Sofar_KGS_DM.mat'); 
    %bulkparams
    fields = fieldnames(bulkparams); 
    for i = 1:length(fields)
        if strcmp(fields{i},'temp')
            data.surf_temp = bulkparams.(fields{i});
            data.temp_time = data.time; 
            data.bott_temp = bulkparams.(fields{i}).*-9999; 
        else
            data.(fields{i}) = bulkparams.(fields{i}); 
        end
    end
    %displacements
    fields = fieldnames(displacements); 
    for i = 1:length(fields)
        if strcmp(fields{i},'time'); 
            data.disp_time = displacements.(fields{i}); 
        else
            data.(fields{i}) = displacements.(fields{i}); 
        end
    end
    %spec
    fields = fieldnames(spec);
    for i =1 :length(fields); 
        if strcmp(fields{i},'time')
            continue
        elseif strcmp(fields{i},'Szz')
            data.energy = spec.(fields{i}); 
        else
            data.(fields{i}) = spec.(fields{i}); 
        end
    end 
    %make frequency same size as other spec params
    for i = 1:size(data.a1,1); 
        data.frequency(i,:) = data.freq(1,:); 
    end
    data = rmfield(data,'freq'); 


%---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 %Datawell DWR4 
elseif strcmp(buoy_info.type,'datawell')==1
   %create blank array for output
    dw_vars = {'serial','E','theta','s','m2','n2','time','a1','a2','b1','b2',...
        'frequency','hs','tm','tp','dp','dpspr', 'curr_mag','curr_dir',...
        'curr_mag_std','curr_dir_std','temp_time','surf_temp','bott_temp','w','w_std',...
        'gps_time','gps_pos','disp_tstart','disp_time','z','y','x'}; 
    for i = 1:length(dw_vars)
        data.(dw_vars{i}) = []; 
    end
    
     cnt=1;
     %loop through directory of files output from CF card (need datawell
     %lib to convert to CSV)
     files=dir((fullfile(buoy_info.datapath,'*-20.csv'))); %get all the field to process 20 file is 1D spectra
     for kk=1:length(files)
         %skip 1970 file that always seems to appear
         if strcmp(files(kk).name(1:4),'1970')
             continue
         else
             disp(['File ' num2str(kk) ' out of ' num2str(length(files))]); 
                
             file20 = fullfile(buoy_info.datapath, [files(kk).name(1:10)  '-20.csv']);
             file21 =fullfile(buoy_info.datapath, [files(kk).name(1:10)  '-21.csv']); 
             file25 =fullfile(buoy_info.datapath, [files(kk).name(1:10)  '-25.csv']); 
             file28 = fullfile(buoy_info.datapath, [files(kk).name(1:10)  '-28.csv']);
             file80 =fullfile(buoy_info.datapath, [files(kk).name(1:10)  '-80.csv']); 
             file82 =fullfile(buoy_info.datapath, [files(kk).name(1:10)  '-82.csv']);
             file23 = fullfile(buoy_info.datapath, [files(kk).name(1:10) '-23.csv']);
             filed = fullfile(buoy_info.datapath, [files(kk).name(1:10) '-displacement.csv']);         
             
             %load and organize data for each file containing 4 days of data
             [temp] = Process_Datawell_delayed_mode(buoy_info, file20, file21, file25, file28, file80, file82, file23, filed);   
             %add dummy variables for meanspr and dm as don't exist in
             %datawell?
             temp.dm = ones(size(temp.hs,1),1).*-9999; 
             temp.meanspr = ones(size(temp.hs,1),1).*-9999;             
         end

         %now append
         if cnt==1
             data=temp;                          
             data.pkspr = data.dpspr;
             data = rmfield(data,'dpspr');
             
             cnt=cnt+1;
             clear temp
         else
             fields = fieldnames(data); 
             for jj = 1:length(fields)
                 if strcmp(fields{jj}, 'spec2D')
                     data.spec2D = cat(3,data.spec2D,temp.spec2D);
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
     %now down-sample temperature to same time as waves - this gets rid of
     %current data as well      
     data_nc = rmfield(data,{'surf_temp','bott_temp','curr_mag','curr_dir','curr_mag_std','curr_dir_std','w','w_std','curr_dir_std'}); 
     if size(data.temp_time,1)~=size(data.time,1)
         for i = 1:size(data.time,1)
             ind = find(abs(data.time(i) - data.temp_time)==min(abs(data.time(i) - data.temp_time))); 
             if length(ind)>1
                 data_nc.surf_temp(i,1) = nanmean(data.surf_temp(ind));             
                 data_nc.bott_temp(i,1) = nanmean(data.bott_temp(ind)); 
             else
                 data_nc.surf_temp(i,1) = (data.surf_temp(ind));             
                 data_nc.bott_temp(i,1) = (data.bott_temp(ind)); 
             end
         end
     end
     data_nc.temp_time= data.time; 
     data = data_nc; 
     clear data_nc
     %save file
     save('C:\Users\00084142\OneDrive - The University of Western Australia\HANSEN_ARDC_WaveBuoys\Data\Datawell\Datawell_DM.mat','-v7.3'); 
end

%%   QAQC data - following QARTOD
%settings for QAQC
check.time = data.time;
check.temp_time = data.temp_time; 
check.WVHGT = data.hs;
check.WVPD = data.tp; %parameter for range test (could also be mean) 
check.WVDIR = data.dp; %parameter for range test (could also be mean)
check.SST = data.surf_temp; 
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

[data] = qaqc_bulkparams(data,check);  

%remove all indivdiual parameter QAQC tests 
fields = fieldnames(data); 
for i = 1:length(fields); 
    if length(fields{i})>1
        if strcmp(fields{i}(end-1:end),'15') | strcmp(fields{i}(end-1:end),'16') | strcmp(fields{i}(end-1:end),'19') | strcmp(fields{i}(end-1:end),'20') | strcmp(fields{i}(end-1:end),'ke')
            data = rmfield(data, fields{i}); 
        end             
    end
end    

%quickly denan and replace with fill values
fields = fieldnames(data); 
for i = 1:length(fields)
    if strcmp(fields{i},'serial')
        continue        
    elseif strcmp(fields{i},'qc_flag_wave') | strcmp(fields{i},'qc_subflag_wave') | strcmp(fields{i},'qc_flag_temp') | strcmp(fields{i},'qc_subflag_wave')
        data.(fields{i})(isnan(data.(fields{i}))) = -127; 
    else
        data.(fields{i})(isnan(data.(fields{i}))) = -9999;
    end
end     

%% Organise for netCDF following IMOS-ARDC conventions      

%Clip data to start/stop time of interest 
ind_wave = find(data.time>=buoy_info.startdate&data.time<=buoy_info.enddate); 
ind_tempcurr = find(data.temp_time>=buoy_info.startdate&data.temp_time<=buoy_info.enddate); 
ind_disp = find(data.disp_time(:,1)>=buoy_info.startdate&data.disp_time(:,1)<=buoy_info.enddate); 

fields = fieldnames(data); 
for i = 1:length(fields); 
    if strcmp(fields{i},'disp_time') | strcmp(fields{i},'x') | strcmp(fields{i},'y') | strcmp(fields{i},'z')
        data.(fields{i}) = data.(fields{i})(ind_disp,:); 
    elseif strcmp(fields{i},'temp_time') | strcmp(fields{i},'surf_temp') | strcmp(fields{i},'bott_temp') | strcmp(fields{i},'qc_flag_temp') | strcmp(fields{i},'qc_subflag_temp') 
         data.(fields{i}) = data.(fields{i})(ind_tempcurr,:); 
    elseif strcmp(fields{i},'curr_mag') | strcmp(fields{i},'curr_dir') | strcmp(fields{i},'curr_mag_std') | strcmp(fields{i},'curr_dir_std') | strcmp(fields{i},'w') | strcmp(fields{i},'w_std')  
        data.(fields{i}) = data.(fields{i})(ind_tempcurr,:); 
    else
        data.(fields{i}) = data.(fields{i})(ind_wave,:); 
    end
end    

%%  Integral Wave Parameters 

globfile = [mpath '\imos_nc\metadata\glob_att_integralParams_ardc.txt']; 
if strcmp(buoy_info.type,'datawell')
    varsfile = [mpath '\imos_nc\metadata\bulkwave_parameters_DM_mapping_DWR4.csv']; 
else
    varsfile = [mpath '\imos_nc\metadata\bulkwave_parameters_DM_mapping.csv']; 
end

bulkparams_to_IMOS_ARDC_nc(data, buoy_info, globfile, varsfile); 

%% displacements
globfile = [mpath '\imos_nc\metadata\glob_att_rawDispl_ardc.txt']; 
if strcmp(buoy_info.type,'datawell')
    varsfile = [mpath '\imos_nc\metadata\rawDispl_parameters_DM_mapping.csv']; 
else
    varsfile = [mpath '\imos_nc\metadata\rawDispl_parameters_DM_mapping.csv']; 
end

%divide displacements into 2week blocks and may x, y, z and time single
%column variables 
disp_buoy_info = buoy_info; %create dum info variable as time needs to change in code below 
if strcmp(buoy_info.type,'datawell')
    %transpose so can stack in time 
    data.disp_time = data.disp_time'; data.x = data.x'; data.y = data.y'; data.z = data.z'; 
    data.disp_time = data.disp_time(:); 
    data.x = data.x(:); 
    data.y = data.y(:); 
    data.z = data.z(:); 
end

ttdum = data.disp_time(1):14:data.disp_time(end); 
for i = 1:length(ttdum)
    if i == length(ttdum)
        ind = find(data.disp_time>=ttdum(i)); 
    else
        ind = find(data.disp_time>=ttdum(i) & data.disp_time<ttdum(i+1));
    end
    displacements.time = data.disp_time(ind); 
    displacements.x = data.x(ind); 
    displacements.y = data.y(ind); 
    displacements.z = data.z(ind); 
    %find lat/lon from bulkparameters that's inside displacements time
    ind = find(data.time>=displacements.time(1) & data.time<=displacements.time(end)); 
    displacements.lat = data.lat(ind); 
    displacements.lon = data.lon(ind); 
    displacements.time_location = data.time(ind); 
    disp_buoy_info.startdate = displacements.time(1); 
    disp_buoy_info.enddate = displacements.time(end);

    displacements_to_IMOS_ARDC_nc(displacements, disp_buoy_info, globfile, varsfile); 
end
%     
%% spectral data
globfile = [mpath '\imos_nc\metadata\glob_att_spectral_ardc.txt']; 
if strcmp(buoy_info.type,'datawell')
    varsfile = [mpath '\imos_nc\metadata\spectral_parameters_DM_mapping_DWR4.csv']; 
else
    varsfile = [mpath '\imos_nc\metadata\spectral_parameters_DM_mapping.csv']; 
end
data.frequency = data.frequency(1,:);
spec_to_IMOS_ARDC_nc(data, buoy_info, globfile, varsfile);
     

    











        

        
        
       




