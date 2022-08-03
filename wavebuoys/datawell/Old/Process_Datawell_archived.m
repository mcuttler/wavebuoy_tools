%% Process Datawell buoy data

%This code uses the same functionality as
%'Process_Datawell_realtime_DevSite.m' but is used for going back to through
%available data and processing or re-processing. 

%Only saves wave data when all time stamps are the same!
%Saves temperature and current data whenever they're timestamp is valid

%M Cuttler
%UWA
%
%version 1 - June 2019
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%INFO REGARDING INPUT PARAMETERS
%file20 is path for location of datawell message 0xF20 - Heave spectrum
%message (pg. 25-26)
%file21 is path for location of datawell message 0xF21 - Primary direction
%spectrum (pg. 26)
%file28 is path for location of datawell message 0xF28 - secondary
%directional spectrum (pg. 27-28)
%file82 is path for location of datawell message 0xF82 - acoustic current
%meter and temperature (pg. 36-37)


%All page numbers referenced are in 
%P:\HANSEN_Albany_WaveEnergy_Feasibility_ongoing\Analysis\WaveBuoys\datawell_specification_csv_file_formats_s-02-v1-5-0.pdf

%%
function [] = Process_Datawell_archived(rootdir, yrs, mths)

%First collect all archived data for re-processing and only keep times when
%all wave data exists for archive20, archive21, archive28 
[~, archive_dates, archive20, archive21, archive25, archive28, archive82, timewave, timecurr] = collect_archive_data(rootdir, yrs, mths);
save('C:\Data\MEM_MC\archive_data.mat');

% if already calculated, just load archive data
% load('C:\Data\MEM_MC\archive_data.mat');

[r,~] = size(archive_dates);
buoyname = 'TorbayInshore';

% Export text files and .mat files       
path1D = 'E:\DatawellBuoys\TorbayInshore\Spec1D';
path2D = 'E:\DatawellBuoys\TorbayInshore\Spec2D';
pathMEMplot = 'E:\DatawellBuoys\TorbayInshore\MEMplot';
pathMAT = 'E:\DatawellBuoys\TorbayInshore\MAT';
pathMAT2 = 'P:\HANSEN_Albany_WaveEnergy_Feasibility_ongoing\Analysis\WaveBuoys\Data\UWA\Processed\TorbayInshore\MAT';


for i = 1:r
    yr = num2str(archive_dates(i,1));
    mm = num2str(archive_dates(i,2),'%02d');
    
    %% Process wave data     
    if exist([pathMEMplot '\' yr '\' mm],'dir')==0
        mkdir([pathMEMplot '\' yr '\' mm]);
        mkdir([path1D '\' yr '\' mm]);
        mkdir([path2D '\' yr '\' mm]);
    end
    
    %only save .mat files per month, so only need yr folder
    if exist([pathMAT '\' yr],'dir')==0
        mkdir([pathMAT '\' yr]);
        mkdir([pathMAT2 '\' yr]);
    end 
    
    %set up monthly date variable to find all dates - note, date is date of
    %data acquisition start
    disp(['Processing wave data for ' num2str(archive_dates(i,1)) num2str(archive_dates(i,2),'%02d')]);
    
    if archive_dates(i,2)==1
        twave_start = datenum(archive_dates(i,1)-1, 12, eomday(archive_dates(i,1), 12),23,29,0);
    else
        twave_start = datenum(archive_dates(i,1), archive_dates(i,2)-1, eomday(archive_dates(i,1), archive_dates(i,2)-1),23,29,0);
    end
    
    twave_end = datenum(archive_dates(i,1), archive_dates(i,2), eomday(archive_dates(i,1), archive_dates(i,2)), 23, 15,0);
    
    idx_wave = find(timewave>twave_start&timewave<twave_end);                      
    
    %process wave data and create/save MEM plot     
    [waves] = process_archived_wave_data(archive20(idx_wave,4:end), archive21(idx_wave,4:103),...
        archive21(idx_wave,104:203),archive28(idx_wave,4:103),archive28(idx_wave,104:203),...
        archive25(idx_wave,:),timewave(idx_wave), pathMEMplot, path1D, path2D, buoyname);                                                       


%% process temp data 

    if archive_dates(i,2)==1
        tcurr_start = datenum(archive_dates(i,1)-1, 12, eomday(archive_dates(i,1), 12),23,55,0);
    else
        tcurr_start = datenum(archive_dates(i,1), archive_dates(i,2)-1, eomday(archive_dates(i,1), archive_dates(i,2)-1),23,55,0);
    end
    
    tcurr_end = datenum(archive_dates(i,1), archive_dates(i,2), eomday(archive_dates(i,1), archive_dates(i,2)), 23, 45,0);
    
    idx_curr = find(timecurr>tcurr_start&timecurr<tcurr_end);                      

    [temp_curr] = process_archived_temp_curr_data(archive82(idx_curr,:), timecurr(idx_curr));
    
%% Save monthly mat files with temp, curr, and wave data 

    if exist([pathMAT '\' yr])
        save([pathMAT '\' yr '\TorbayInshore_' yr mm '.mat'],'-v7.3','waves','temp_curr');  
        save([pathMAT2 '\' yr '\TorbayInshore_' yr mm '.mat'],'-v7.3','waves','temp_curr');  
    else
        mkdir([pathMAT '\' yr]);
        mkdir([pathMAT2 '\' yr]);
        save([pathMAT '\' yr '\TorbayInshore_' yr mm '.mat'],'-v7.3','waves','temp_curr');  
        save([pathMAT2 '\' yr '\TorbayInshore_' yr mm '.mat'],'-v7.3','waves','temp_curr');  
    end
    
    clear temp_curr waves twave_start twave_end idx_wave tcurr_start tcurr_end idx_curr
    
end
end


    

        

