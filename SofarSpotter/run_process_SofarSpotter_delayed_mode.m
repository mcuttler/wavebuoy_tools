%%  Process Sofar Spotter Data (delayed mode)
% This script processes Sofar Spotter data stored on the SD card (i.e. processes data after retrieval of buoy). 
% This requires the Sofar parser script (Python), accessible here: https://www.sofarocean.com/posts/parsing-script
% 
% The parser script will process all available data files (_FLT, _LOC, _SYS) available in a folder, however, due to computer memory issues, 
% this code chunks the data files into temporary folders and then concatenates results at the end. 
% 
% Final output files include: 
%     -bulkparameters.csv : CSV file containing wave parameters (Hs, Tp, Dp, etc.)
%     -displacements.csv: CSV file containin the raw displacements
%
% Example usage
%     MC to fill when finished
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
%
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

%set number of unique time poins to use for efficient processing
chunk = 10; 

[bulkparams, displacements, locations] = process_SofarSpotter_delayed_mode(datapath, parserpath, chunk);

%%  perform QA/QC   

disp('Performing QA/QC checks...'); 

%add path to QARTOD QA/QC check codes
addpath([homepath '\qartod']); 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%quality checks on bulkparams - QARTOD TEST 19
check_bulkparams.time = bulkparams.time; 
check_bulkparams.WVHGT = bulkparams.hs; 

%should these be mean or peak parameters? 
check_bulkparams.WVPD = bulkparams.tp; 
check_bulkparams.WVDIR = bulkparams.dp; 
check_bulkparams.WVSP = bulkparams.pkspr; 

%    User defined test criteria
check_bulkparams.MINWH = 0.05;
check_bulkparams.MAXWH = 8;
check_bulkparams.MINWP = 2; 
check_bulkparams.MAXWP = 24;
check_bulkparams.MINSV = 0.07; 
check_bulkparams.MAXSV = 65.0; 

[bulkparams.qf] = qartod_bulkparams_range(check_bulkparams); 


 %% now build monthly netCDF files 
disp(['Saving data for ' spot_info.SpotterID ' as netCDF']);         
cd(homepath); 

%bulkparams
%text files for IMOS-compliant netCDF generation
globfile = 'D:\CUTTLER_GitHub\wavebuoy_tools\SofarSpotter\glob_att_Spotter_timeSeries.txt';     
varsfile = 'D:\CUTTLER_GitHub\wavebuoy_tools\SofarSpotter\spotter_wave_parameters_mapping.csv';

spotter_bulk_to_IMOSnc(bulkparams, outpathNC, spot_info, globfile, varsfile); 

%displacements

%gps data 




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
        

        
        
       




