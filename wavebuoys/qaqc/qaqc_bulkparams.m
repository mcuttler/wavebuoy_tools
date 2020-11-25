%% code for running QA/QC on bulk parameters 


function [bulkparams] = qaqc_bulkparams(bulkparams)
%% QARTOD TESTS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  QARTOD TEST 15 - LT time series mean and standard deviation

check.time = bulkparams.time; 
check.WVHGT = bulkparams.hs; 
check.WVPD = bulkparams.tm; 
check.WVDIR = bulkparams.dm; 
check.WVSP = bulkparams.meanspr; 

%    User defined test criteria
check.STD = 3; 
check.time_window = 24; %hours for calculating mean + std
check.realtime = 0; %calculate mean + std over window where time point is central to window 

[bulkparams.qf15] = qartod_15_mean_std(check); 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% QARTOD TEST 16 - LT time series flat line 

%    User defined test criteria - absolute difference from preceding points
%    to denote 'flatline' 
check.WHTOL = 0.05; 
check.WPTOL = 0.1;
check.WDTOL = 0.5; 
check.WSPTOL = 0.5; 
check.rep_fail = 48; 
check.rep_suspect = 24; 

%outputs a matrix that has rows = time, colums = wave height, wave period, wave direction, wave spreading
[bulkparams.qf16] = qartod_16_flat_line(check); 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% QARTOD TEST 19 - LT time series bulk wave parameters max/min/acceptable
% range

%    User defined test criteria
check.MINWH = 0.25;
check.MAXWH = 8;
check.MINWP = 3; 
check.MAXWP = 25;
check.MINSV = 0.07; 
check.MAXSV = 65.0; 

[bulkparams.qf19] = qartod_19_bulkparams_range(check); 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Other tests

%use peak period
check.WVPD = bulkparams.tp; 
check.maxT = 25; 
check.diffHS = [0.5 1]; 

[bulkparams.qf_lims] = qaqc_bulkparams_limits(check); 


