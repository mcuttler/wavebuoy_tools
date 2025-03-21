%% code for running QA/QC on bulk parameters for website 
%only relies on Hs and Tp as these data have clear spikes when GPS errors
%occur for data 
%also includes temperature qa/qc

%Use qartod flags
% 1 = pass
% 2 = not assessed
% 3 = suspect
% 4 = fail; 

function [bulkparams] = qaqc_bulkparams_realtime_website(buoy_info, archive_data, new_data)

%append new data and archived data
if strcmp(buoy_info.type,'sofar')
    fields = fieldnames(new_data); 
    fields_archive = fieldnames(archive_data); 
    fields_int = intersect(fields, fields_archive);
    for j = 1:size(fields_int,1)
        %try to catch difference sized columns and pad with nans (usually
        %for spectral data)
        old = size(archive_data.(fields_int{j,:}),2); 
        new = size(new_data.(fields_int{j,:}),2); 
        if old < new 
            archive_data.(fields_int{j,:})(:,old+1:new)=nan; 
        elseif old > new
            new_data.(fields_int{j,:})(:,new+1:old)=nan;
        end

        bulkparams.(fields_int{j}) = [archive_data.(fields_int{j,:}); new_data.(fields_int{j,:})]; 
        
    end
    %now include any missing fields from archive data
    for j = 1:size(fields_archive)
        if ~isfield(bulkparams, fields_archive{j})
            bulkparams.(fields_archive{j,:}) = archive_data.(fields_archive{j,:}); 
        end
    end 
    %now include missing parameters from new data
    for j =1:size(fields); 
        if ~isfield(bulkparams, fields{j}); 
            bulkparams.(fields{j}) = new_data.(fields{j,:}); 
        end
    end
elseif strcmp(buoy_info.type,'datawell'); 
    bulkparams = new_data; 
end

bulkparams = remove_duplicates(bulkparams); 


%bulkparams data 
qaqc.time = bulkparams.time; 
qaqc.WVHGT = bulkparams.hsig; 
qaqc.WVPD = bulkparams.tp; 
if isfield(bulkparams, 'temp_time')
    qaqc.time_temp = bulkparams.temp_time; 
    qaqc.SST = bulkparams.surf_temp; 
    qaqc.BOTT_TEMP = bulkparams.bott_temp; 
end

%settings for range test (QARTOD19) 
qaqc.MINWH = 0.01;
qaqc.MAXWH = 12;
qaqc.MINWP = 1; 
qaqc.MAXWP = 25;
qaqc.MAXT = 45; 
qaqc.MINT = 5; 

%settings UWA 'master flag' test (combination of QARTOD19 and QARTOD20) -
%requires 3 data points 
qaqc.rocHs = 0.5; 
qaqc.HsLim = 12; 
qaqc.rocTp = 12; 
qaqc.TpLim = 25; 
qaqc.rocSST = 2; 

if isfield(qaqc, 'time_temp')
    [bulkparams.qf_waves, bulkparams.qf_sst, bulkparams.qf_bott_temp] = qaqc_uwa_waves_website(qaqc); 
else
    [bulkparams.qf_waves, ~, ~] = qaqc_uwa_waves_website(qaqc);
end

end



