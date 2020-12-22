%%  Process wave buoys (real time) for display on wawaves.org

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
%     M. Cuttler     | 26 Nov 2020 | 1.0                     | Initial creation
% -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
%     M. Cuttler     | 22 Dec 2020 | 1.0                     | Initial creation

%% set initial paths for wave buoy data to process and parser script
clear; clc

%location of wavebuoy_tools repo
buoycodes = 'E:\CUTTLER_GitHub\wavebuoy_tools\wavebuoys'; 
addpath(genpath(buoycodes))

%buoy type and deployment info number and deployment info 
buoy_info.type = 'sofar'; 
buoy_info.serial = 'SPOT-0558'; %spotter serial number, or just Datawell 
buoy_info.name = 'ExmouthGulf'; 
buoy_info.version = 'V2'; %or DWR4 for Datawell, for example
buoy_info.DeployLoc = 'Testing';
buoy_info.DeployDepth = 30; 
buoy_info.DeployLat = -35; 
buoy_info.DeployLon = 117; 
buoy_info.UpdateTime =  1; %hours
buoy_info.DataType = 'parameters'; %can be parameters if only bulk parameters, or spectral for including spectral coefficients
buoy_info.archive_path = 'D:\Active_Projects\LOWE_IMOS_WaveBuoys\Data\waves_website\CodeTesting\data_archive\NewSystem';

%use this website to calculate magnetic declination: https://www.ngdc.noaa.gov/geomag/calculators/magcalc.shtml#declination
% buoy_info.MagDec = 1.98; 

%% process realtime mode data

%Sofar Spotter (v1 and v2) 
if strcmp(buoy_info.type,'sofar')==1        
    
    limit = buoy_info.UpdateTime*2; 
    if strcmp(buoy_info.DataType,'parameters')
        [SpotData] = Get_Spoondrift_Data_realtime(buoy_info.serial, limit);     
    elseif strcmp(buoy_info.DataType,'spectral'); 
        [SpotData] = Get_Spoondrift_Data_realtime_fullwaves(buoy_info.serial, limit);     
    end                    
    
    for i = 1:size(SpotData.time,1)
        SpotData.name{i,1} = buoy_info.name; 
    end
    
    %load in any existing data for this site and combine with new
    %measurements, then QAQC
    check_archive_path(buoy_info.archive_path, SpotData);    
    
    [data] = load_archive_data(SpotData, archive_path);    
    
    %perform some QA/QC --- QARTOD 19 and QARTOD 20
    
    [data] = qaqc_bulkparams_realtime_website(data);

    %save data to different formats (hourly text files, monthly mat file
    realtime_archive_text(data); 
    realtime_archive_mat(data);                   
    
%---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 %Datawell DWR4 
elseif strcmp(buoy_info.type,'datawell')==1
    for yy = 1:length(years); 
        for mm = 1:length(months);             
            
%             [bulkparams, displacements, locations, spec, sst] = process_Datawell_delayed_mode();
            
        end
    end    
%---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
%Triaxys
elseif strcmp(buoy_info.type,'triaxys')
    disp('No Triaxys code yet'); 
end

%% save as .mat file

% outpathMAT = 'E:\Active_Projects\LOWE_IMOS_WaveBuoys\Data';
% filenameMAT = [outpathMAT '\' buoy_info.name '_' buoy_info.DeployLoc '_' datestr(bulkparams.time(1),'yyyymm') '_' datestr(bulkparams.time(end),'yyyymm')  '.mat'];         
% vars = who; 
% idx=[];
% for jj = 1:length(vars); 
%     if  isstruct(eval(vars{jj}))
%         idx = [idx;jj];
%     end
% end        
%         
% save(filenameMAT,vars{idx}); 

%%
    











        

        
        
       




