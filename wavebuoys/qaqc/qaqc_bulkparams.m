%% code for running QA/QC on bulk parameters 


function [bulkparams] = qaqc_bulkparams(bulkparams)
%% QARTOD TESTS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  QARTOD TEST 15 - LT time series mean and standard deviation

check_mean.time = bulkparams.time; 
check_mean.WVHGT = bulkparams.hs; 
check_mean.WVPD = bulkparams.tm; 
check_mean.WVDIR = bulkparams.dm; 
check_mean.WVSP = bulkparams.meanspr; 

%    User defined test criteria
check_mean.STD = 2; 
check_mean.time_window = 12; %hours for calculating mean + std
check_mean.realtime = 0; %calculate mean + std over window where time point is central to window 

check_peak.time = bulkparams.time; 
check_peak.WVHGT = bulkparams.hs; 
check_peak.WVPD = bulkparams.tp; 
check_peak.WVDIR = bulkparams.dp; 
check_peak.WVSP = bulkparams.pkspr; 

%    User defined test criteria
check_peak.STD = 2; 
check_peak.time_window = 12; %hours for calculating mean + std
check_peak.realtime = 0; %calculate mean + std over window where time point is central to window 

[bulkparams.qf15_mean] = qartod_15_mean_std(check_mean); 
[bulkparams.qf15_peak] = qartod_15_mean_std(check_peak); 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% QARTOD TEST 16 - LT time series flat line 

%    User defined test criteria - absolute difference from preceding points
%    to denote 'flatline' 
check_mean.WHTOL = 0.05; 
check_mean.WPTOL = 0.1;
check_mean.WDTOL = 0.5; 
check_mean.WSPTOL = 0.5; 
check_mean.rep_fail = 48; 
check_mean.rep_suspect = 24; 

check_peak.WHTOL = 0.05; 
check_peak.WPTOL = 0.1;
check_peak.WDTOL = 0.5; 
check_peak.WSPTOL = 0.5; 
check_peak.rep_fail = 48; 
check_peak.rep_suspect = 24; 

%outputs a matrix that has rows = time, colums = wave height, wave period, wave direction, wave spreading
[bulkparams.qf16_mean] = qartod_16_flat_line(check_mean); 
[bulkparams.qf16_peak] = qartod_16_flat_line(check_peak); 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% QARTOD TEST 19 - LT time series bulk wave parameters max/min/acceptable
% range

%    User defined test criteria
check_mean.MINWH = 0.25;
check_mean.MAXWH = 8;
check_mean.MINWP = 3; 
check_mean.MAXWP = 25;
check_mean.MINSV = 0.07; 
check_mean.MAXSV = 65.0; 

check_peak.MINWH = 0.25;
check_peak.MAXWH = 8;
check_peak.MINWP = 3; 
check_peak.MAXWP = 25;
check_peak.MINSV = 0.07; 
check_peak.MAXSV = 65.0; 

[bulkparams.qf19_mean] = qartod_19_bulkparams_range(check_mean); 

[bulkparams.qf19_peak] = qartod_19_bulkparams_range(check_peak); 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Other tests

check_peak.maxT = 25; 
check_peak.diffHS = [0.5 1]; 

[bulkparams.qf_lims] = qaqc_bulkparams_limits(check_peak); 


