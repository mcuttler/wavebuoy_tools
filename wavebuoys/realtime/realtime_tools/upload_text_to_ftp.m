%% test upload to BOM FTP

function [ftp_upload_check] = upload_text_to_ftp(buoy_info)

%read in FTP details from file
ftp_details = readtable(buoy_info.ftp_details,'VariableNamingRule','preserve'); 

% connect to FTP
ftpobj = ftp(ftp_details.service, ftp_details.username, ftp_details.password); 

%cd to ftp upload directory
cd(ftpobj,"incoming"); 

% check text archive and upload most recent file 
tfiles = dir(fullfile(buoy_info.web_path,buoy_info.name, 'text_archive',...
    num2str(year(datetime('today'))), num2str(month(datetime('today')),'%02d'),'*.csv')); 

%upload last file 
try
    ftp_upload = mput(ftpobj, fullfile(tfiles(end).folder, tfiles(end).name)); 
    ftp_upload_check = 1; 
catch
    ftp_upload_check = 0; 
end

end


 