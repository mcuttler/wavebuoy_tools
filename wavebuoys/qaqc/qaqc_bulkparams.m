%% code for running QA/QC on bulk parameters 


function [bulkparams] = qaqc_bulkparams(bulkparams, check)
%% QARTOD TESTS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  QARTOD TEST 15 - LT time series mean and standard deviation

%    User defined test criteria
% check.STD = 3; 
% check.time_window = 72; %hours for calculating mean + std
% check.time = bulkparams.time; 

if isfield(bulkparams,'meanspr')
    fields = {'hs','tm','tp','dm','dp','meanspr','pkspr','surf_temp'};
elseif isfield(bulkparams,'dmspr')
     fields = {'hs','tm','tp','dm','dp','dmspr','dpspr','surf_temp'};
end

outfields={'hs_15','tm_15','tp_15','dm_15','dp_15','meanspr_15','pkspr_15','surf_temp_15'}; 

for f = 1:length(fields)
    if isfield(bulkparams, fields{f}); 
        if strcmp(fields{f},'surf_temp')
            in.time = check.temp_time; 
        else
            in.time = check.time; 
        end
        in.time_window = check.time_window; 
        in.STD = check.STD;             
        [bulkparams.(outfields{f})] = qartod_15_mean_std(in, bulkparams.(fields{f})); 
    else
        bulkparams.(outfields{f}) = ones(size(bulkparams.time,1),1)*2; 
    end
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% QARTOD TEST 16 - LT time series flat line 

%    User defined test criteria - absolute difference from preceding points
%    to denote 'flatline' 
% check.WHTOL = 0.025; 
% check.WPTOL = 0.01;
% check.WDTOL = 0.5; 
% check.WSPTOL = 0.5; 
% check.TTOL = 0.01; 
% check.rep_fail = 240;  % might be in hrs.
% check.rep_suspect = 144; % might be in hrs.

if isfield(bulkparams,'meanspr')
    fields = {'hs','tm','tp','dm','dp','meanspr','pkspr','surf_temp'};
elseif isfield(bulkparams,'dmspr')
     fields = {'hs','tm','tp','dm','dp','dmspr','dpspr','surf_temp'};
end

tol = {'WHTOL','WPTOL','WPTOL', 'WDTOL','WDTOL','WSPTOL','WSPTOL','TTOL'};
outfields={'hs_16','tm_16','tp_16','dm_16','dp_16','meanspr_16','pkspr_16','surf_temp_16'}; 

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
% in.WVPD - timeserieswave period : WVPD
% in.WVDIR - timeseries wave direction : WVDIR
% in.WVSP - timeseries wave spreading : WVSP 

%    User defined test criteria
% check.WVHGT = bulkparams.hs; 
% check.WVPD = bulkparams.tp; 
% check.WVDIR = bulkparams.dp;

if isfield(bulkparams,'pkspr')
    check.WVSP = bulkparams.pkspr;
else
    check.WVSP = bulkparams.dpspr;
end


% check.MINWH = 0.10;
% check.MAXWH = 10;
% check.MINWP = 3; 
% check.MAXWP = 25;
% check.MINSV = 0.07; 
% check.MAXSV = 80.0; 

[bulkparams.qf_19] = qartod_19_bulkparams_range(check); 

%% simple temperature range test
% check.MINT = 5; 
% check.MAXT = 55; 

if isfield(bulkparams,'temp')
    field = 'temp';
else
    field = 'surf_temp';
end

for i = 1:size(bulkparams.temp_time,1)
    if bulkparams.(field)(i,1)<check.MINT|bulkparams.(field)(i,1)>check.MAXT
        bulkparams.surf_temp_19(i,1) = 4;
    else
        bulkparams.surf_temp_19(i,1) = 1; 
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% QARTOD TEST 20 - LT time series rate of change 

%    User defined test criteria
% check.WHROC= 2; 
% check.WPROC= 10; 
% check.WDROC= 50; 
% check.WSPROC= 25; 
% check.TROC = 2; 

if isfield(bulkparams,'meanspr')
    fields = {'hs','tm','tp','dm','dp','meanspr','pkspr','surf_temp'};
elseif isfield(bulkparams,'dmspr')
     fields = {'hs','tm','tp','dm','dp','dmspr','dpspr','surf_temp'};
end

roc = {'WHROC','WPROC','WPROC', 'WDROC','WDROC','WSPROC','WSPROC','TROC'}; 
outfields={'hs_20','tm_20','tp_20','dm_20','dp_20','meanspr_20','pkspr_20','surf_temp_20'}; 

for f = 1:length(fields)
    if isfield(bulkparams, fields{f}); 
        [bulkparams.(outfields{f})] = qartod_20_rate_of_change(check.(roc{f}), bulkparams.(fields{f})); 
    else
        bulkparams.(outfields{f}) = ones(size(bulkparams.time,1),1)*2; 
    end  
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% UWA QA/QC tests

%UWA spike test 

if isfield(bulkparams,'meanspr')
    fields = {'hs','tm','tp','dm','dp','meanspr','pkspr','surf_temp'};
elseif isfield(bulkparams,'dmspr')
     fields = {'hs','tm','tp','dm','dp','dmspr','dpspr','surf_temp'};
end

roc = {'WHROC','WPROC','WPROC', 'WDROC','WDROC','WSPROC','WSPROC','TROC'}; 
outfields={'hs_spike','tm_spike','tp_spike','dm_spike','dp_spike','meanspr_spike','pkspr_spike','surf_temp_spike'}; 

for f = 1:length(fields)
    if isfield(bulkparams, fields{f}); 
        if strcmp(fields{f},'surf_temp')
            [bulkparams.(outfields{f})] = qaqc_uwa_spike(check.temp_time, bulkparams.(fields{f}), check.(roc{f})); 
        else
            [bulkparams.(outfields{f})] = qaqc_uwa_spike(check.time, bulkparams.(fields{f}), check.(roc{f})); 
        end
    else
        bulkparams.(outfields{f}) = ones(size(bulkparams.time,1),1)*2; 
    end  
end

%% assigning primary and subflags

% fields = {'hs','tm','dm'};
% qaqc_tests = {'15','16','19','20','spike'}; 

[bulkparams.qc_flag_wave, bulkparams.qc_subflag_wave] = qaqc_wave_primary_and_subflag(bulkparams, check.wave_fields, check.qaqc_tests); 

% fields = {'temp'}; 
% qaqc_tests = {'15','16','19','20','spike'}; 
[bulkparams.qc_flag_temp, bulkparams.qc_subflag_temp] = qaqc_temp_primary_and_subflag(bulkparams, check.temp_fields, check.qaqc_tests); 

end


