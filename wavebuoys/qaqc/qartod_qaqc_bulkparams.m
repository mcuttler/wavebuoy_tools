%% code for running QA/QC on bulk parameters 


function [bulkparams] = qartod_qaqc_bulkparams(bulkparams)
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