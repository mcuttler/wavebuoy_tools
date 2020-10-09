%%  Process Sofar Spotter Data (delayed mode)

%     
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
%                                                                        | SEE FUNCTIONS WITHIN THIS CODE FOR ACTUALLY DATA PROCESSING
% 

%% set initial paths for Spotter data to process and parser script

clear; clc
%path to Spotter data to process - contains raw dump of SD card
%_LOC files)
datapath = 'E:\Active_Projects\LOWE_IMOS_WaveBuoys\Data\SofarSpotter\CodeTesting\Data_for_testing'; 
%path of Sofar parser script
parserpath = 'E:\Active_Projects\LOWE_IMOS_WaveBuoys\Data\SofarSpotter\SofarParser\parser_v1.10.0';

%path to save netCDF files for transfer to AODN
outpathNC = 'E:\Active_Projects\LOWE_IMOS_WaveBuoys\Data\SofarSpotter\CodeTesting\Output_testing';
outpathMAT = 'E:\Active_Projects\LOWE_IMOS_WaveBuoys\Data\SofarSpotter\CodeTesting\Output_testing';

if ~exist(outpathNC)
    mkdir(outpathNC)
end

if ~exist(outpathMAT)
    mkdir(outpathMAT);
end

%spotter serial number and deployment info 
spot_info.SpotterID = 'SPOT0171'; 
spot_info.DeployLoc = 'Testing';
spot_info.DeployDepth = 30; 

%location of wavebuoy_tools repo
homepath = 'D:\CUTTLER_GitHub\wavebuoy_tools\SofarSpotter'; 

%% process raw Spotter data

%set number of unique time poins to use for efficient processing (depends
%on computer specifications) 
chunk = 10; 

%process delayed mode (from buoy memory card)
[bulkparams, displacements, locations] = process_SofarSpotter_delayed_mode(datapath, parserpath, chunk);

%%  perform QA/QC   

disp('Performing QA/QC checks...'); 

%add path to QARTOD QA/QC check codes
addpath([homepath '\qartod']); 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  QARTOD TEST 15 - LT time series mean and standard deviation

check.time = bulkparams.time; 
check.WVHGT = bulkparams.hs; 
check.WVPD = bulkparams.tm; 
check.WVDIR = bulkparams.dm; 
check.WVSP = bulkparams.meanspr; 

%    User defined test criteria
check.STD = 2; 

[bulkparams.qf15] = qartod_15_mean_std(check); 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% QARTOD TEST 16 - LT time series flat line 

%    User defined test criteria
check.WHTOL = 0.05; 
check.WPTOL = 0.5;
check.WDTOL = 0.5; 
check.WSPTOL = 0.5; 
check.rep_fail = 24; 
check.rep_suspect = 6; 

%outputs a matrix that has rows = time, colums = wave height, wave period, wave direction, wave spreading
[bulkparams.qf16] = qartod_16_flat_line(check); 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% QARTOD TEST 17 - LT time series operational frequency range

% NOT USED BECAUSE TESTING BULK PARAMETERS - 
% DO NOT HAVE OPERATIONAL FREQUENCY RANGE INFORMATION

% [bulkparams.qf17] = qartod_17_operational_frequency(check);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  QARTOD TEST 18 - LT Time series Low-Frequency Energy 

% NOT USED BECAUSE TESTING BULK PARAMETERS - 
% DO NOT HAVE OPERATIONAL FREQUENCY RANGE INFORMATION

% [bulkparams.qf18] = qartod_18_low_frequency(check); 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% QARTOD TEST 19 - LT time series bulk wave parameters max/min/acceptable
% range

%    User defined test criteria
check.MINWH = 0.05;
check.MAXWH = 8;
check.MINWP = 2; 
check.MAXWP = 24;
check.MINSV = 0.07; 
check.MAXSV = 65.0; 

[bulkparams.qf19] = qartod_19_bulkparams_range(check); 


 %% now build monthly netCDF files 
disp(['Saving data for ' spot_info.SpotterID ' as netCDF']);         
cd(homepath); 

%bulkparams
%text files for IMOS-compliant netCDF generation
globfile = 'D:\CUTTLER_GitHub\wavebuoy_tools\SofarSpotter\glob_att_Spotter_timeSeries.txt';     
varsfile = 'D:\CUTTLER_GitHub\wavebuoy_tools\SofarSpotter\spotter_bulk_wave_parameters_mapping.csv';

spotter_bulk_to_IMOSnc(bulkparams, outpathNC, spot_info, globfile, varsfile); 


%% plot quick figure
% figure; 
% plot(datenum(bulkparams.data(:,1:6)), bulkparams.data(:,8)); 
% hold on;
% idx1 = find(qfbulk(:,3)==0); 
% idx2 = find(qfbulk(:,3)==1); 
% idx3 = find(qfbulk(:,3)==2); 
% 
% if ~isempty(idx1)
%     h(1) = plot(datenum(bulkparams.data(idx1,1:6)), bulkparams.data(idx1,8),'g.'); 
% else
%     h(1) = plot(0,0,'g.');
% end
% 
% if ~isempty(idx2)
%     h(2) = plot(datenum(bulkparams.data(idx2,1:6)), bulkparams.data(idx2,8),'y.'); 
% else
%      h(2) = plot(0,0,'g.');
% end
% 
% if ~isempty(idx3)
%     h(3) = plot(datenum(bulkparams.data(idx3,1:6)), bulkparams.data(idx3,8),'r.'); 
% else
%     h(3) = plot(0,0,'r.'); 
% end
% 
% set(gca,'xlim',[datenum(StartDate,'yyyymmdd') datenum(EndDate,'yyyymmdd')]); 
% datetick('x','mmm-dd','keepticks'); 
% xlabel('Date (mmm-dd');
% ylabel('Hs (m)'); 
% grid on; 
% title(SpotterID); 
% legend(h,{'Good','Questionable','Bad'},'location','best'); 
        

        
        
       




