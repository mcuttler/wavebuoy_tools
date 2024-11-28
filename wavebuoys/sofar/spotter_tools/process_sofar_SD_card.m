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
%v3.1 modified to include smart mooring bristlemouth data 

%Example usage: 
% sofarpath = '\\drive.irds.uwa.edu.au\SEE-PNP-001\HANSEN_Albany_WaveEnergy_Feasibility_ongoing\Data\WaveBuoys\Sofar\SPOT0168_KingGeorgeSound_20201211_to_20210326'; 
% utcoffset = 8;
% [out]s = process_sofar_SD_card(sofarpath, utcoffset); 

%%
function [displacements, displacements_hdr, surface_temp, baro, gps, smart_mooring_bm, smart_mooring_bm_agg] = process_sofar_SD_card(sofarpath)

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
%% smart_mooring --- BristleMouth
disp('concatenating smart mooring Bristlemouth'); 
files = dir([sofarpath '\*_SENS_IND.csv']); 

if ~isempty(files)
    for i = 1:size(files)    
        dum = readtable(fullfile(files(i).folder, files(i).name),'VariableNamingRule','preserve');
        %set common variable names for all BristleMOuth sensor types: 
        % https://sofarocean.notion.site/Spotter-3-Bristlemouth-SD-Card-Data-Guide-50b2a73cd7d74f4987484152878ddad9
        varnames = {'bm_node_id','node_position','node_app_name','reading_up_time_millis','reading_time_utc_s','sensor_reading_time_s'}; 
        
        if ~isempty(dum)
            %check instrument type
            if contains(dum.Var3(1),'soft')
                varnames = [varnames,'temp_degC']; 
            elseif contains(dum.Var3(1),'RBR')
                if strcmp(dum.Var3(1),'RBR.T')
                    varnames = [varnames,'temp_degC']; 
                elseif strcmp(dum.Var3(1),'RBR.D')
                    varnames = [varnames,'pressure_dbar']; 
                elseif strcmp(dum.Var3(1),'RBR.DT')
                    varnames = [varnames,'temp_degC','pressure_dbar']; 
                end
            elseif contains(dum.Var3(1),'aanderaa')
                varnames = [varnames, 'abs_speed_cm-s','direction_deg','north_cm-s','east_cm-s','heading_deg',...
                    'tilt_x_deg','tilt_y_deg','single_ping_std','signal_strength_dB','ping_count','abs_tilt_deg',...
                    'max_tilt','std_tilt','temp_degC']; 
            end                
            
            dum = dum(:,1:length(varnames));
            dum.Properties.VariableNames = varnames; 
            
            
            dt = datetime(dum.reading_time_utc_s,'convertfrom','posixtime'); 
            dumt = table2timetable(dum,'RowTimes',dt); 
            if i == 1
                smart_mooring_bm = dumt; 
            else
                try
                    smart_mooring_bm = [smart_mooring_bm; dumt]; 
                catch
                    smart_mooring_bm = dumt; 
                end                
            end
        end
        clear dum dt dumt; 
    end
else
    smart_mooring_bm = nan; 
end

% add the extra 'aggregate' files 
disp('concatenating smart mooring Bristlemouth agg'); 
files = dir([sofarpath '\*_SENS_AGG.csv']); 

if ~isempty(files)
    for i = 1:size(files)    
        dum = readtable(fullfile(files(i).folder, files(i).name),'VariableNamingRule','preserve');
        %set common variable names for all BristleMOuth sensor types: 
        % https://sofarocean.notion.site/Spotter-3-Bristlemouth-SD-Card-Data-Guide-50b2a73cd7d74f4987484152878ddad9
        varnames = {'bm_node_id','node_position','node_app_name','timestamp_utc','reading_count'}; 
        if ~isempty(dum)
            %check instrument type
            if contains(dum.Var3(1),'soft')
                varnames = [varnames,'temp_mean_degC']; 
            elseif contains(dum.Var3(1),'RBR')
                if strcmp(dum.Var3(1),'RBR.T')
                    varnames = [varnames,'temp_mean_degC']; 
                elseif strcmp(dum.Var3(1),'RBR.D')
                    varnames = [varnames,'pressure_mean_dbar','pressure_std_dbar']; 
                elseif strcmp(dum.Var3(1),'RBR.DT')
                    varnames = [varnames,'temp_mean_degC','pressure_mean_dbar','pressure_std_dbar']; 
                end
            elseif contains(dum.Var3(1),'aanderaa')
                varnames = [varnames, 'abs_speed_mean_cm-s','abs_speed_std_cm-s',...
                    'direction_circ_mean','direction_circ_std','temp_mean_degC','abs_tilt_mean_deg','std_tilt_mean_deg'];     
            end                
            
            dum = dum(:,1:length(varnames));
            dum.Properties.VariableNames = varnames; 
            
            
            dt = datetime(dum.timestamp_utc,'convertfrom','posixtime'); 
            dumt = table2timetable(dum,'RowTimes',dt); 
            if i == 1
                smart_mooring_bm_agg = dumt; 
            else
                try
                    smart_mooring_bm_agg = [smart_mooring_bm_agg; dumt]; 
                catch
                    smart_mooring_bm_agg = dumt; 
                end

            end
        end
        clear dum dt dumt; 
    end
else
    smart_mooring_bm_agg = nan; 
end

%% smart mooring - legacy - TO DO 

%SMD files 

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





       
            
    
