%% run batch process
tic
%add wavebuoy_tools to path 
% addpath(genpath('D:\CUTTLER_GitHub\wavebuoy_tools')); 

%suppress warnings
warning('off')

%read in metadata for buoys to run
dpath = '\\drive.irds.uwa.edu.au\OGS-COD-001\CUTTLER_wawaves\Data\website\auswaves'; 
dname = 'buoys_metadata_test.csv'; 

buoy_metadata = readtable(fullfile(dpath,dname),'VariableNamingRule','preserve'); 

%create log file for this run
log_path = '\\drive.irds.uwa.edu.au\OGS-COD-001\CUTTLER_wawaves\Data\website\auswaves\log_files_test'; %modify this in future

if ~isfolder(fullfile(log_path, num2str(year(datetime("today"))), num2str(month(datetime("today")),'%02d'), num2str(day(datetime("today")),'%02d'))) 
    mkdir(fullfile(log_path, num2str(year(datetime("today"))), num2str(month(datetime("today")),'%02d'), num2str(day(datetime("today")),'%02d')))
    log_path = fullfile(log_path, num2str(year(datetime("today"))), num2str(month(datetime("today")),'%02d'), num2str(day(datetime("today")),'%02d')); 
else
    log_path = fullfile(log_path, num2str(year(datetime("today"))), num2str(month(datetime("today")),'%02d'), num2str(day(datetime("today")),'%02d')); 
end

log_name = ['log_file_' datestr(now,'yyyymmdd_HHMMSS') '.log']; 
flog = fopen(fullfile(log_path,log_name),'a'); 

% loop over buoys and execute 
for jj = 1:size(buoy_metadata)
    %build buoy info from metadata
    buoy_info_fields = buoy_metadata.Properties.VariableNames; 
    for kk = 1:length(buoy_info_fields)
        if iscell(buoy_metadata.(buoy_info_fields{kk}))
            buoy_info.(buoy_info_fields{kk}) = buoy_metadata.(buoy_info_fields{kk}){jj};
        else
            buoy_info.(buoy_info_fields{kk}) = buoy_metadata.(buoy_info_fields{kk})(jj);  
        end
    end
    
    %run the realtime workflow 
%     disp(['running ' buoy_info.name]); %comment out when running for real 
    try
        [log_message] = batch_realtime(buoy_info);
        fprintf(flog, [buoy_info.name ': ' log_message ' \n']); 
    catch   
%         disp([buoy_info.name ' could not be completed \n']); %comment out when running for real 
        %add message to log if a buoy fails 
        log_message = 'code failed for reason unrelated to getting data'; 
        fprintf(flog, [buoy_info.name ': ' log_message ' \n']); 
    end
    clear buoy_info 
end

log_message = ['Elapsed run time is: ' num2str(toc) ' seconds']; 
fprintf(flog, [log_message ' \n']); 
fclose(flog);

