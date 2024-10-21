%% Process FLT and LOC files from Sofar memory card
%version 2.0 Modified by JEH on 16 April 2024, streamlined finding FLT
%files and only reading in files that have 100 bytes of data (header only
%is ~50 bytes), also change from importdata to readtable function as some
%FLT file have an I at the end of the row which causes a problem
%
%v2.1 modified to also read LOC files
%v3
%   v3 removes utc offset (apply this later in workflow or will get
%   confusing) and includes concatenting of other types of files. Also
%   converts outputs to timetables and uses datetime 

%Example usage: 
% sofarpath = '\\drive.irds.uwa.edu.au\SEE-PNP-001\HANSEN_Albany_WaveEnergy_Feasibility_ongoing\Data\WaveBuoys\Sofar\SPOT0168_KingGeorgeSound_20201211_to_20210326'; 
% utcoffset = 8;
% [out]s = process_sofar_SD_card(sofarpath, utcoffset); 

%%
function [displacements, displacements_hdr, surface_temp, baro, gps, smart_mooring] = process_sofar_SD_card(sofarpath)

%% displacements
disp('concatenating displacements'); 
files = dir([sofarpath '\*_FLT.csv']); 
if ~isempty(files)
    displacements=[];
    for i = 1:size(files)
       

        %skip first 0000 files as usually contain no data, also make sure
        %file is at least 200 bytes
        if strcmp(files(i).name(1:4),'0000')~=1 & files(i).bytes>200

            dum = readtable(fullfile(files(i).folder, files(i).name),'VariableNamingRule','preserve');     
            %should only have 5 variables
            dum = dum(:,1:5); 
            dum.Properties.VariableNames = {'millis','GPSEpoch','x','y','z'};  
            
            dt = datetime(dum.GPSEpoch,'convertfrom','posixtime'); 
            dumt = timetable(dum.x./1000, dum.y./1000, dum.z./1000,'RowTimes',dt,'VariableNames',{'x','y','z'});  

            displacements = [displacements; dumt]; 

            clear dum dt dumt; 
        end
        
    end

    %mask out NaT
    mask = ~isnat(displacements.Time); 
    displacements = displacements(mask,:); 
else
    displacements = nan; 
end



%% SST 
disp('concatenating surface temperature'); 
files = dir([sofarpath '\*_SST.csv']); 
if ~isempty(files)
    
    surface_temp=[];

    for i = 1:size(files)

        
        %skip first 0000 files as usually contain no data
        if strcmp(files(i).name(1:4),'0000')~=1 & files(i).bytes>200
    
            dum = readtable(fullfile(files(i).folder, files(i).name),'VariableNamingRule','preserve'); 
            
            %should only have 2 variables
            dum = dum(:,1:2); 
            dum.Properties.VariableNames = {'GPSEpoch','temperature'}; 
            
            dt = datetime(dum.GPSEpoch,'convertfrom','posixtime'); 
            dumt = timetable(dum.temperature,'RowTimes',dt,'VariableNames',{'temperature'}); 
    
             surface_temp = [surface_temp; dumt]; 
    
            clear dum dt dumt; 
        end
    end
        %mask out NaT
    mask = ~isnat(surface_temp.Time); 
    surface_temp = surface_temp(mask,:); 
else
    surface_temp = nan; 
end
%% baro
disp('concatenating barometric pressure'); 
files = dir([sofarpath '\*_BARO.csv']); 
if ~isempty(files) 
    
    baro=[];

    for i = 1:size(files)
       
        %skip first 0000 files as usually contain no data
        if strcmp(files(i).name(1:4),'0000')~=1 & files(i).bytes>200
            dum = readtable(fullfile(files(i).folder, files(i).name),'VariableNamingRule','preserve'); 
            
            %should only have 2 variables
            dum = dum(:,1:2); 
            dum.Properties.VariableNames = {'GPSEpoch','baro_pressure'}; 
            
            dt = datetime(dum.GPSEpoch,'convertfrom','posixtime'); 
            dumt = timetable(dum.baro_pressure,'RowTimes',dt,'VariableNames',{'baro_pressure'}); 
            
            baro = [baro; dumt]; 
            
            clear dum dt dumt; 
        end
    end
    %mask out NaT
    mask = ~isnat(baro.Time); 
    baro = baro(mask,:); 
else
    baro = nan; 
end
%% smart_mooring
disp('concatenating smart mooring'); 
files = dir([sofarpath '\*_SMD.csv']); 
if ~isempty(files)
% NEED TO WRITE THIS FOR EXAMPLE SMART MOORING 
% for i = 1:size(files)
%     dum = readtable(fullfile(files(i).folder, files(i).name),'VariableNamingRule','preserve'); 
% 
%     %should only have 2 variables
%     dum = dum(:,1:2); 
%     dum.Properties.VariableNames = {'GPSEpoch','baro_pressure'}; 
% 
%     dt = datetime(dum.GPSEpoch,'convertfrom','posixtime'); 
%     dumt = timetable(dum.baro_pressure,'RowTimes',dt,'VariableNames',{'baro_pressure'}); 
% 
%     if i == 1
%         baro = dumt; 
%     else
%         baro = [baro; dumt]; 
%     end
%     clear dum dt dumt; 
% 
% end
else
    smart_mooring = nan; 
end
%% GPS
disp('concatenating gps positions'); 
files = dir([sofarpath '\*_LOC.csv']); 
if ~isempty(files)
     gps=[];
     for i = 1:size(files)
       
        %skip first 0000 files as usually contain no data
        if strcmp(files(i).name(1:4),'0000')~=1 & files(i).bytes>200
    
            dum = readtable(fullfile(files(i).folder, files(i).name),'VariableNamingRule','preserve'); 
            
            %should only have 5 variables
            dum = dum(:,1:5); 
            dum.Properties.VariableNames = {'GPSEpoch','lat','lat_min','lon','lon_min'}; 
            
            dt = datetime(dum.GPSEpoch,'convertfrom','posixtime'); 
            %files already have negative to indicate N-S, so should be ok to just
            %add 
            dlat = dum.lat + ((dum.lat_min./10^5)/60); 
            dlon = dum.lon + ((dum.lon_min./10^5)/60); 
            
            dumt = timetable(dlon, dlat,'RowTimes',dt,'VariableNames',{'longtiude','latitude'}); 
            
            gps = [gps; dumt]; 
        
            clear dum dt dumt; 
        end
    end
            %mask out NaT
    mask = ~isnat(gps.Time); 
    gps = gps(mask,:); 
else
    gps = nan; 
end

%% HDR files 
disp('concatenating hdr files'); 
files = dir([sofarpath '\*_HDR.csv']); 

if ~isempty(files)
    displacements_hdr=[];
    for i = 1:size(files)
        

        %skip first 0000 files as usually contain no data
        if strcmp(files(i).name(1:4),'0000')~=1 & files(i).bytes>200
    
            dum = readtable(fullfile(files(i).folder, files(i).name),'VariableNamingRule','preserve'); 
            
            %should only have 5 variables
            dum = dum(:,1:5); 
            dum.Properties.VariableNames = {'GPSEpoch','x','y','z','n'}; 
            
            dt = datetime(dum.GPSEpoch,'convertfrom','posixtime');     
            dumt = timetable(dum.x./1000, dum.y./1000, dum.z./1000,dum.n./1000, 'RowTimes',dt,'VariableNames',{'x','y','z','n'});  
            displacements_hdr = [displacements_hdr; dumt]; 
    
            clear dum dt dumt; 
        end
        
    end

    %mask out NaT
    mask = ~isnat(displacements_hdr.Time); 
    displacements_hdr = displacements_hdr(mask,:); 
else
    displacements_hdr = nan; 
end


end





       
            
    
