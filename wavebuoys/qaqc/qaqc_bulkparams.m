%% code for running QA/QC on bulk parameters 


function [bulkparams, buoy_info] = qaqc_bulkparams(bulkparams, qc_config, buoy_info,saveTable)


%loop over qc_config 
for qc = 1:size(qc_config,1)    
    
    %% QARTOD TESTS
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %  QARTOD TEST 15 - LT time series mean and standard deviation
    
    %    User defined test criteria
    % check.STD = 3; 
    % check.time_window = 72; %hours for calculating mean + std
    % check.time = bulkparams.time;     
    
    outfields = [qc_config.parameter_matlab{qc} '_mean_std_test']; 
    
    if contains(qc_config.parameter_matlab{qc},'temp')
        in.time = bulkparams.temp_time; 
    else
        in.time = bulkparams.time; 
    end    
    
    in.time_window = qc_config.mean_std_time_window(qc);  
    in.STD =  qc_config.mean_std_std(qc);    
    [bulkparams.(outfields)] = qartod_15_mean_std(in, bulkparams.(qc_config.parameter_matlab{qc})); 
    
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
    
    clear in
    tol = qc_config.flat_line_tol_dm(qc); 
    outfields = [qc_config.parameter_matlab{qc} '_flat_line_test']; 
    
    in.rep_suspect = qc_config.flat_line_suspect_time_dm(qc);
    in.rep_fail = qc_config.flat_line_fail_time_dm(qc); 

    [bulkparams.(outfields)] = qartod_16_flat_line(in, tol, bulkparams.(qc_config.parameter_matlab{qc}));        
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % QARTOD TEST 19 - LT time series bulk wave parameters max/min/acceptable
    % range

    %in.data = data;
    %in.data_max = max range
    %in.data_min = min range
    %in.fail_sus = 4 for fail, 3 for suspect
    %type = wave height = 1; period = 2; wave direction = 3; spreading = 4;
    %temperature = 5; 
        
    clear in 
    outfields = [qc_config.parameter_matlab{qc} '_gross_range_test'];  
    in.data = bulkparams.(qc_config.parameter_matlab{qc}); 
    in.data_max = qc_config.gross_range_fail_max(qc); 
    in.data_min = qc_config.gross_range_fail_min(qc); 
    
    if contains(qc_config.parameter_matlab{qc},'h')
        fail_sus = 4; type = 1; 
    elseif contains(qc_config.parameter_matlab{qc},'t')
        fail_sus = 4; type = 2; 
    elseif contains(qc_config.parameter_matlab{qc},'temp')
        fail_sus = 4; type = 5; 
    elseif contains(qc_config.parameter_matlab{qc},'d') && ~contains(qc_config.parameter_matlab{qc},'spr')
        fail_sus = 3; type = 3; 
    elseif contains(qc_config.parameter_matlab{qc},'spr')     
        fail_sus = 3; type = 4; 
    end
        

    
    [bulkparams.(outfields)] = qartod_19_bulkparams_range(in,fail_sus,type); 
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % QARTOD TEST 20 - LT time series rate of change 
    
    %    User defined test criteria
    % check.WHROC= 2; 
    % check.WPROC= 10; 
    % check.WDROC= 50; 
    % check.WSPROC= 25; 
    % check.TROC = 2; 
    
     
    outfields = [qc_config.parameter_matlab{qc} '_rate_of_change_test']; 
    if  contains(qc_config.parameter_matlab{qc},'d') && ~contains(qc_config.parameter_matlab{qc},'spr')
        type = 'directional'; 
    else
        type = 'nondirectional'; 
    end

    [bulkparams.(outfields)] = qartod_20_rate_of_change(qc_config.spike_test_roc(qc), bulkparams.(qc_config.parameter_matlab{qc}),type);  
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% UWA QA/QC tests
    
    %UWA spike test     
    outfields = [qc_config.parameter_matlab{qc} '_spike_test']; 
    if  contains(qc_config.parameter_matlab{qc},'d') && ~contains(qc_config.parameter_matlab{qc},'spr')
        type = 'directional'; 
    else
        type = 'nondirectional'; 
    end

    [bulkparams.(outfields)] = qaqc_uwa_spike(bulkparams.(qc_config.parameter_matlab{qc}), qc_config.spike_test_roc(qc), type); 
end

%% run final watch circle test 
%run final QC using watch circle, note this function overwrties the
%qc_flag_wave when watch circle test is suspect (3) and fail
%(4). It also overwrites qc_subflag_wave with (37) when outside watch circle.
% watch_circle_flag tells whether more (1) or less (2) than certain
% percentage of data outside watch circle (percentage defined in
% metadata)

[bulkparams.qc_flag_watch, bulkparams.watch_circle_flag, buoy_info] = qaqc_watch_circle(buoy_info, bulkparams.lat, bulkparams.lon); 

%% assigning primary and subflags based on QARTOD

vars = fieldnames(bulkparams);
qaqc_tests = vars(contains(vars,[qc_config.parameter_matlab{1} '_']) & ~strcmp(vars,'hs_0'));     
qaqc_tests = strrep(qaqc_tests,[qc_config.parameter_matlab{1} '_'],''); 

[bulkparams.qc_flag_wave, bulkparams.qc_subflag_wave] = qaqc_wave_primary_and_subflag(bulkparams, qc_config.parameter_matlab(contains(qc_config.parameter_name,'wave')), qaqc_tests); 

[bulkparams.qc_flag_temp, bulkparams.qc_subflag_temp] = qaqc_temp_primary_and_subflag(bulkparams, qc_config.parameter_matlab(contains(qc_config.parameter_name,'temp')), qaqc_tests); 


%% save table with outputs of qaqc tests

if saveTable==1
    %build waves table
    qaqc_check_waves.TIME=bulkparams.time;
    qaqc_check_waves.LONGITUDE=bulkparams.lon;
    qaqc_check_waves.LATITUDE=bulkparams.lat;
    for qc = 1:size(qc_config,1)
        if ~contains(qc_config.parameter_matlab{qc},'temp')
            qaqc_check_waves.(qc_config.parameter{qc}) = bulkparams.(qc_config.parameter_matlab{qc});     
            vars = fieldnames(bulkparams); 
            for j = 1:length(vars)
                if contains(vars{j},qc_config.parameter_matlab{qc}) & contains(vars{j},'test')
                    qaqc_check_waves.(['WAVE_QC_' qc_config.parameter{qc} '_' strrep(vars{j},qc_config.parameter_matlab{qc},'')]) = bulkparams.(vars{j}); 
                end
            end    
        end
    end
    qaqc_check_waves.WAVE_quality_control=bulkparams.qc_flag_wave;
    qaqc_check_waves.WATCH_quality_control = bulkparams.qc_flag_watch;
  
    qaqc_check_temp.TIME_TEMP=bulkparams.temp_time;
    for qc = 1:size(qc_config,1)
        if contains(qc_config.parameter_matlab{qc},'temp')
            qaqc_check_temp.(qc_config.parameter{qc}) = bulkparams.(qc_config.parameter_matlab{qc});         
            vars = fieldnames(bulkparams); 
            for j = 1:length(vars)
                if contains(vars{j},qc_config.parameter_matlab{qc}) & contains(vars{j},'test')
                    qaqc_check_temp.(['TEMP_QC_TEMP' qc_config.parameter{qc} '_' strrep(vars{j},qc_config.parameter_matlab{qc},'')]) = bulkparams.(vars{j}); 
                end
            end   
        end
    end
    qaqc_check_temp.TEMP_quality_control=bulkparams.qc_flag_temp;

    qaqc_check_waves = struct2table(qaqc_check_waves); 
    qaqc_check_temp = struct2table(qaqc_check_temp); 

    writetable(qaqc_check_waves,fullfile(buoy_info.archive_path,'bulk_qc_subflags.csv')); 
    writetable(qaqc_check_temp,fullfile(buoy_info.archive_path,'temp_qc_subflags.csv')); 
end


end


