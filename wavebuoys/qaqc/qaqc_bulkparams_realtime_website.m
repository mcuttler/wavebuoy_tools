%% code for running QA/QC on bulk parameters 


function [bulkparams] = qaqc_bulkparams_realtime_website(bulkparams)
%% QARTOD TESTS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


check.time = bulkparams.time; 
check.WVHGT = bulkparams.hs; 
check.WVPD = bulkparams.tp; 
check.WVDIR = bulkparams.dp; 
check.WVSP = bulkparams.pkspr; 

if isfield(bulkparams,'temp')
    check.SST = bulkparams.temp; 
end

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

check.MINWH = 0.25;
check.MAXWH = 12;
check.MINWP = 3; 
check.MAXWP = 25;
check.MINSV = 0.07; 
check.MAXSV = 100.0; 

[bulkparams.qf19] = qartod_19_bulkparams_range(check); 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% QARTOD TEST 20 - LT time series rate of change 

%    User defined test criteria
check_roc.time = bulkparams.time; 
check_roc.data = bulkparams.hs; 
check_roc.rate_of_change = 1; 

[bulkparams.qf20] = qartod_20_rate_of_change(check_roc); 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Other tests

% check.maxT = 25; 
% check.diffHS = [0.5 1]; 
% 
% [bulkparams.qf_lims] = qaqc_bulkparams_limits(check); 


