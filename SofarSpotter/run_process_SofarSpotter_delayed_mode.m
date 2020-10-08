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
%add IMOS toolbox
% addpath('D:\CUTTLER_GitHub\imos-toolbox\NetCDF'); 

%determine min and max months
t = datevec(bulkparams.time); 
tdata = unique(t(:,1:2),'rows'); 

for i = 1:size(tdata,1)
 
    tstart = datenum(tdata(i,1), tdata(i,2),1); 
    tend = datenum(tdata(i,1), tdata(i,2)+1, 1); 
    
    disp(['Saving ' datestr(tstart,'mmm yyyy')]); 
    
    %output for BULK PARAMETERS     
    idx_bulk = []; 
    idx_bulk = find(bulkparams.time>=tstart&bulkparams.time<tend);                 
    filenameNC = [outpathNC '\' spot_info.SpotterID '_' spot_info.DeployLoc '_' datestr(tstart,'yyyymm') '_bulk.nc']; 
    
    globfile = 'D:\CUTTLER_GitHub\wavebuoy_tools\SofarSpotter\glob_att_Spotter_timeSeries.txt';     
    varsfile = 'D:\CUTTLER_GitHub\wavebuoy_tools\SofarSpotter\spotter_wave_parameters_mapping.csv';
    
    spotter_bulk_to_IMOSnc(bulkparams, idx_bulk, filenameNC, globfile, varsfile); 
    
end

%% output netCDF for DISPLACEMENTS - write into code to make IMOS-compliant
%     idx_disp = []; 
%     idx_disp = find(displacements.time>=tstart&displacements.time<tend);                 
%     filenameNC = [outpathNC '\' SpotterID '_' DeployLoc '_' datestr(tstart,'yyyymm') '_disp.nc']; 
%     
%     [m,c] = size(displacements.time(idx_disp)); 
%     nccreate(filenameNC,'disp_time','Dimensions',{'time',m});
%     nccreate(filenameNC,'x','Dimensions',{'x',m}); 
%     nccreate(filenameNC,'y','Dimensions',{'y',m}); 
%     nccreate(filenameNC,'z','Dimensions',{'z',m});     
%     nccreate(filenameNC,'QualityFlag','Dimensions',{'QualityFlag',m}); 
%     
%     ncwrite(filenameNC,'disp_time',displacements.time(idx_disp)); 
%     ncwriteatt(filenameNC,'disp_time','long_name','UTC');  
%     ncwriteatt(filenameNC,'disp_time','units','days since Jan-1-0000, includes milliseconds');    
%     
%     ncwrite(filenameNC,'x',displacements.x(idx_disp)); 
%     ncwriteatt(filenameNC,'x','long_name','x displacement');  
%     ncwriteatt(filenameNC,'x','units','m');
%     
%     ncwrite(filenameNC,'y',displacements.y(idx_disp));           
%     ncwriteatt(filenameNC,'y','long_name','y displacement');  
%     ncwriteatt(filenameNC,'y','units','m');   
%     
%     ncwrite(filenameNC,'z',displacements.z(idx_disp)); 
%     ncwriteatt(filenameNC,'z','long_name','z displacement');  
%     ncwriteatt(filenameNC,'z','units','m');
%     
%     ncwrite(filenameNC,'QualityFlag',qfdisp(idx_disp)); 
%     ncwriteatt(filenameNC,'QualityFlag','long_name','quality flag: COMPLETE WHEN QUALITY FLAGS ARE FINISHED');  
%     ncwriteatt(filenameNC,'QualityFlag','units','-');
%     
%         

%% output netCDF for LOCATIONS
%     idx_locs = []; 
%     idx_locs = find(locations.time>=tstart&locations.time<tend);                 
%     filenameNC = [outpathNC '\' SpotterID '_' DeployLoc '_' datestr(tstart,'yyyymm') '_gps.nc']; 
%     
%     [m,c] = size(locations.time(idx_locs)); 
%     nccreate(filenameNC,'time','Dimensions',{'time',m});
%     nccreate(filenameNC,'lat','Dimensions',{'lat',m}); 
%    nccreate(filenameNC,'lon','Dimensions',{'lon',m});   
%     nccreate(filenameNC,'QualityFlag','Dimensions',{'QualityFlag',m}); 
%     
%     ncwrite(filenameNC,'time',locations.time(idx_locs)); 
%     ncwriteatt(filenameNC,'time','long_name','UTC');  
%     ncwriteatt(filenameNC,'time','units','days since Jan-1-0000, includes milliseconds');    
%     
%     ncwrite(filenameNC,'lat',locations.lat(idx_locs)); 
%     ncwriteatt(filenameNC,'lat','long_name','latitude');  
%     ncwriteatt(filenameNC,'lat','units','deg');
%     
%     ncwrite(filenameNC,'lon', locations.lon(idx_locs)); 
%     ncwriteatt(filenameNC,'lon','long_name','longitude');  
%     ncwriteatt(filenameNC,'lon','units','m');
%     
%     ncwrite(filenameNC,'QualityFlag',qflocs(idx_locs)); 
%     ncwriteatt(filenameNC,'QualityFlag','long_name','quality flag: COMPLETE WHEN QUALITY FLAGS ARE FINISHED');  
%     ncwriteatt(filenameNC,'QualityFlag','units','-');
%     
%     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     %output netCDF for SPECTRAL DATA
%     idx_spec = []; 
%     idx_spec = find(spec.time>=tstart&spec.time<tend);                 
%     filenameNC = [outpathNC '\' SpotterID '_' DeployLoc '_' datestr(tstart,'yyyymm') '_spec.nc']; 
%     
%     [m,c] = size(spec.a1(idx_spec,:)); 
% 
%     nccreate(filenameNC,'time','Dimensions',{'time',m});
%     nccreate(filenameNC,'a1','Dimensions',{'time',m,'freq',c}); 
%     nccreate(filenameNC,'a2','Dimensions',{'time',m,'freq',c}); 
%     nccreate(filenameNC,'b1','Dimensions',{'time',m,'freq',c}); 
%     nccreate(filenameNC,'b2','Dimensions',{'time',m,'freq',c}); 
%     nccreate(filenameNC,'Sxx','Dimensions',{'time',m,'freq',c}); 
%     nccreate(filenameNC,'Syy','Dimensions',{'time',m,'freq',c}); 
%     nccreate(filenameNC,'Szz','Dimensions',{'time',m,'freq',c}); 
%     nccreate(filenameNC,'freq','Dimensions',{'time',m,'freq',c}); 
%     nccreate(filenameNC,'QualityFlag','Dimensions',{'QualityFlag',m}); 
%     
%     ncwrite(filenameNC,'time', spec.time(idx_spec)); 
%     ncwriteatt(filenameNC,'time','long_name','UTC');  
%     ncwriteatt(filenameNC,'time','units','days since Jan-1-0000, includes milliseconds');    
%     
%     ncwrite(filenameNC,'a1', spec.a1(idx_spec,:)); 
%     ncwriteatt(filenameNC,'a1','long_name','spectral coefficient a1');  
%     ncwriteatt(filenameNC,'a1','units','-');    
%         
%     ncwrite(filenameNC,'b1', spec.b1(idx_spec,:)); 
%     ncwriteatt(filenameNC,'b1','long_name','spectral coefficient a1');  
%     ncwriteatt(filenameNC,'b1','units','-');
%         
%     ncwrite(filenameNC,'a2', spec.a2(idx_spec,:)); 
%     ncwriteatt(filenameNC,'a2','long_name','spectral coefficient a1');  
%     ncwriteatt(filenameNC,'a2','units','-');    
%         
%     ncwrite(filenameNC,'b2', spec.b2(idx_spec,:)); 
%     ncwriteatt(filenameNC,'b2','long_name','spectral coefficient a1');  
%     ncwriteatt(filenameNC,'b2','units','-');    
%         
%     ncwrite(filenameNC,'Sxx', spec.Sxx(idx_spec,:)); 
%     ncwriteatt(filenameNC,'Sxx','long_name','spectral coefficient a1');  
%     ncwriteatt(filenameNC,'Sxx','units','-');    
%         
%     ncwrite(filenameNC,'Syy', spec.Syy(idx_spec,:)); 
%     ncwriteatt(filenameNC,'Syy','long_name','spectral coefficient a1');  
%     ncwriteatt(filenameNC,'Syy','units','-');
%         
%     ncwrite(filenameNC,'Szz', spec.Szz(idx_spec,:)); 
%     ncwriteatt(filenameNC,'Szz','long_name','spectral coefficient a1');  
%     ncwriteatt(filenameNC,'Szz','units','-');        
%     
%     %frequency is longer than spectral coefficients because Sofar pads with
%     %nans
%     ncwrite(filenameNC,'freq', spec.freq(1:c)); 
%     ncwriteatt(filenameNC,'freq','long_name','frequency');  
%     ncwriteatt(filenameNC,'freq','units','Hz'); 
% 
%     ncwrite(filenameNC,'QualityFlag',qf(idx_spec,3));  
%     ncwriteatt(filenameNC,'QualityFlag','long_name','quality flag: 0 = good data, 1 = problem with wave height or period, 2 = problem with wave height and period');  
%     ncwriteatt(filenameNC,'QualityFlag','units','-');
%     
%     %only save .mat file at the end - contains all data, not split by
%     %monthly 
%     if i == size(tdata,1)
%         filenameMAT = [outpathMAT '\' SpotterID '_' DeployLoc '_' datestr(tstart,'yyyymm') '_' datestr(tend,'yyyymm') '.mat']; 
%         save(filenameMAT,'bulkparams','spec','locations','displacements','-v7.3'); 
%     end
%         
% % end
%     
% %clear command window and displayed finished processing
% clc; 
%%
disp(['Finished processing ' SpotterID ' delayed mode']); 

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
%         

        
        
       




