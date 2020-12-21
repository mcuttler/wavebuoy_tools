%% code for running QA/QC on bulk parameters 


function [bulkparams] = qaqc_bulkparams(bulkparams)
%% QARTOD TESTS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  QARTOD TEST 15 - LT time series mean and standard deviation

%    User defined test criteria
check.STD = 3; 
check.time_window = 12; %hours for calculating mean + std
check.time = bulkparams.time; 

fields = {'hs','tm','tp','dm','dp','meanspr','pkspr','temp'};
outfields={'hs_15','tm_15','tp_15','dm_15','dp_15','meanspr_15','pkspr_15','temp_15'}; 

for f = 1:length(fields)
    if isfield(bulkparams, fields{f}); 
        [bulkparams.(outfields{f})] = qartod_15_mean_std(check, bulkparams.(fields{f})); 
    else
        bulkparams.(outfields{f}) = ones(size(bulkparams.time,1),1)*2; 
    end
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% QARTOD TEST 16 - LT time series flat line 

%    User defined test criteria - absolute difference from preceding points
%    to denote 'flatline' 
check.WHTOL = 0.05; 
check.WPTOL = 0.1;
check.WDTOL = 0.5; 
check.WSPTOL = 0.5; 
check.TTOL = 0.01; 
check.rep_fail = 48; 
check.rep_suspect = 24; 

fields = {'hs','tm','tp','dm','dp','meanspr','pkspr','temp'};
tol = {'WHTOL','WPTOL','WPTOL', 'WDTOL','WDTOL','WSPTOL','WSPTOL','TTOL'}; 
outfields={'hs_16','tm_16','tp_16','dm_16','dp_16','meanspr_16','pkspr_16','temp_16'}; 

for f = 1:length(fields)
    if isfield(bulkparams, fields{f}); 
        [bulkparams.(outfields{f})] = qartod_16_flat_line(check, check.(tol{f}), bulkparams.(fields{f})); 
    else
        bulkparams.(outfields{f}) = ones(size(bulkparams.time,1),1)*2; 
    end        
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% QARTOD TEST 19 - LT time series bulk wave parameters max/min/acceptable
% range
% in.WVHGT - timeseries wave height : WVHGT
% in.WVPD - timeseries wave period : WVPD
% in.WVDIR - timeseries wave direction : WVDIR
% in.WVSP - timeseries wave spreading : WVSP
%    User defined test criteria
check.WVHGT = bulkparams.hs; 
check.WVPD = bulkparams.tm; 
check.WVDIR = bulkparams.dm; 
check.WVSP = bulkparams.meanspr; 

check.MINWH = 0.25;
check.MAXWH = 8;
check.MINWP = 3; 
check.MAXWP = 25;
check.MINSV = 0.07; 
check.MAXSV = 65.0; 

[bulkparams.qf_19] = qartod_19_bulkparams_range(check); 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% QARTOD TEST 20 - LT time series rate of change 

%    User defined test criteria
check.WHROC= 1; 
check.WPROC= 5; 
check.WDROC= 20; 
check.WSPROC= 25; 
check.TROC = 2; 

fields = {'hs','tm','tp','dm','dp','meanspr','pkspr','temp'};
roc = {'WHROC','WPROC','WPROC', 'WDROC','WDROC','WSPROC','WSPROC','TROC'}; 
outfields={'hs_20','tm_20','tp_20','dm_20','dp_20','meanspr_20','pkspr_20','temp_20'}; 

for f = 1:length(fields)
    if isfield(bulkparams, fields{f}); 
        [bulkparams.(outfields{f})] = qartod_20_rate_of_change(check.(roc{f}), bulkparams.(fields{f})); 
    else
        bulkparams.(outfields{f}) = ones(size(bulkparams.time,1),1)*2; 
    end  
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% UWA QA/QC tests

%UWA 'master flag' test
check.rocHs =0.5; 
check.HsLim = 10; 
check.rocTp = 5; 
check.TpLim = 25; 

[bulkparams.qf_master] = qaqc_uwa_masterflag(check, bulkparams.hs, bulkparams.tp); 
end


