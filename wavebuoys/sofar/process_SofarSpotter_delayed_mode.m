%% Process SofarSpotter delayed mode

% This script processes Sofar Spotter data stored on the SD card (i.e. processes data after retrieval of buoy). 
% This requires the Sofar parser script (Python), accessible here: https://www.sofarocean.com/posts/parsing-script
% 
% The parser script will process all available data files (_FLT, _LOC, _SYS) available in a folder, however, due to computer memory issues, 
% this code chunks the data files into temporary folders and then concatenates results at the end. 
% 
% Inputs: 
%           datapath: string
%               -location of data stored on spotter memory card (_FLT,
%               _LOC, _SYS files)
%           parserpath: string
%               -location of sofar parser script
%           chunk: double
%               -number of individual time points to process at once (this
%               is user-defined in the
%               'run_process_SofarSpotter_delayed_mode.m' code
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%     
% Code history
% 
%     Author          | Date             | Script Version     | Update
%---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
%     M. Cuttler     | 09 Oct 2020  | 1.0                    | initial code
%     creation 

% 

%%

function [bulkparams, displacements, locations, spec, sst] = process_SofarSpotter_delayed_mode(datapath, parserpath, parser, chunk); 

dum = dir(datapath); 
%remove initial entries as filler
dum = dum(3:end); 

%loop through names to figure out how many unique file numbers there are
for j = 1:size(dum,1)
    dname(j,1) = str2num(dum(j).name(1:4)); 
    if j == size(dum,1) 
        dname(j,1) = str2num(dum(j).name(1:4)); 
        %find unique numbers
        flist = unique(dname); 
        clear dname
    end
end

fidx = 1:chunk:size(flist,1); 
%initiate structures for saving data
bulkparams = struct('time',[], 'hs',[],'tm',[]','tp',[],'dm',[],'dp',[],'meanspr',[],'pkspr',[]); 
locations = struct('time',[],'lat',[],'lon',[]); 
displacements = struct('time',[], 'x',[],'y',[],'z',[]); 
spec = struct('time',[],'freq',[],'a1',[],'b1',[],'a2',[],'b2',[],'Sxx',[],'Syy',[],'Szz',[]); 
sst = struct('time',[],'sst',[]); 
%%
for j = 1:size(fidx,2)
    %%
    if j==size(fidx,2)
        dlist = flist(fidx(j):end)'; 
    else
        dlist = flist(fidx(j)):flist(fidx(j)+(chunk-1));
    end
    idx = [];
    for i = 1:size(dlist,2); 
        %loop through first 10 unique numbers to identify files to move
        fname = [num2str(dlist(i),'%04d')];     
        for jj = 1:size(dum,1)
            if dum(jj).name(1:4)==fname
                idx = [idx; jj];
            end
        end
    end
    
    %now move these files into temporary folder
    if j == 1
        mkdir([datapath '\tmp']); 
        copyfile([parserpath '\' parser], [datapath '\tmp\' parser])        
    end
    
    for jj = 1:size(idx,1)
        copyfile([datapath '\' dum(idx(jj)).name], [datapath '\tmp'])
    end    
    
    disp(['Copied files for chunk ' num2str(j) ', parsing data...'])
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %now run parser - generates displacements, bulkparameters, a1, a2, b1, b2, Cxy,
    % location, Qxz, Qyz, Sxx, Syy, Szz CSV files
    cd([datapath '\tmp']);     
    
    %run parser
    %apparently Matlab will add a folder the path that causes errors when
    %running external executables from Matlab. To fix this, remove the
    %folder that it adds     
    system(['set path=%path:C:\Program Files\MATLAB\R2018b\bin\win64;=% & python ' parser]);   
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %append data from parser to single output file 
    disp(['Adding data for chunk ' num2str(j) ' to data arrays'])    

    %for some instances parser generates subdirectories
    if exist([datapath '\tmp\bulkparameters.csv'])==0
        %get list of subfolders
        subdir = dir([datapath '\tmp']); 
        subdir = subdir(3:end); 
        dirFlags = [subdir.isdir]; 
        for k = 1:size(dirFlags,2); 
            if dirFlags(k)>0
                %check is sst exists
                if exist([datapath '\tmp\' subdir(k).name '\sst.csv']); 
                    filenames = {'bulkparameters','location','displacement','sst', 'a1','a2','b1','b2','Sxx','Syy','Szz'};                    
                else
                    filenames = {'bulkparameters','location','displacement', 'a1','a2','b1','b2','Sxx','Syy','Szz'};
                end                
                
                for kk = 1:length(filenames)
                    if exist([datapath '\tmp\' subdir(k).name '\' filenames{kk} '.csv'])
                        if strcmp(filenames{kk},'bulkparameters') | strcmp(filenames{kk},'location') | strcmp(filenames{kk},'displacement') | strcmp(filenames{kk},'sst')
                            dumdata = importdata([datapath '\tmp\' subdir(k).name '\' filenames{kk} '.csv']); 
                            data = dumdata.data;             
                            if kk == 1
                                bulkparams.time = [bulkparams.time; datenum(data(:,1:6))+(data(:,7)/(8.64*10^7))]; 
                                bulkparams.hs = [bulkparams.hs; data(:,8)];
                                bulkparams.tm = [bulkparams.tm; data(:,9)];
                                bulkparams.tp = [bulkparams.tp; data(:,10)]; 
                                bulkparams.dm = [bulkparams.dm; data(:,11)];
                                bulkparams.dp = [bulkparams.dp; data(:,12)]; 
                                bulkparams.meanspr = [bulkparams.meanspr; data(:,13)];
                                bulkparams.pkspr = [bulkparams.pkspr; data(:,14)]; 
                            elseif kk == 2
                                locations.time = [locations.time; datenum(data(:,1:6))+(data(:,7)/(8.64*10^7))]; 
                                locations.lat = [locations.lat; data(:,8)]; 
                                locations.lon = [locations.lon; data(:,9)];
                            elseif kk == 3
                                displacements.time = [displacements.time; datenum(data(:,1:6))+(data(:,7)/(8.64*10^7))]; 
                                displacements.x = [displacements.x; data(:,8)];
                                displacements.y = [displacements.y; data(:,9)];
                                displacements.z = [displacements.z; data(:,10)]; 
                            end
                        else
                            dumdata = importdata([datapath '\tmp\' subdir(k).name '\' filenames{kk} '.csv'],',',1);                               
                            if strcmp(filenames{kk},'a1')                   
                                spec.freq = [spec.freq; str2double(dumdata.textdata(9:end))]; 
                                spec.time = [spec.time; datenum(dumdata.data(:,1:6))+(dumdata.data(:,7)/(8.64*10^7))]; 
                            end
                            
                            if size(dumdata.data,2)~=size(spec.freq,2)
                                dumdata.data(:,end+1:size(spec.freq,2)+8)=nan; 
                            end
                            spec.(filenames{kk}) = [spec.(filenames{kk}); dumdata.data(:,9:end)];                           
                        end
                    end
                end                
                rmdir([datapath '\tmp\' subdir(k).name],'s');
            end
        end
    else        
        if exist([datapath '\tmp\sst.csv'])
            filenames = {'bulkparameters','location','displacement','sst', 'a1','a2','b1','b2','Sxx','Syy','Szz'}; 
        else
            filenames = {'bulkparameters','location','displacement', 'a1','a2','b1','b2','Sxx','Syy','Szz'};
        end
        
        for kk = 1:length(filenames)
            if exist([datapath '\tmp\' filenames{kk} '.csv'])
                if strcmp(filenames{kk},'bulkparameters') | strcmp(filenames{kk},'location') | strcmp(filenames{kk},'displacement') | strcmp(filenames{kk},'sst')
                    dumdata = importdata([filenames{kk} '.csv']); 
                    data = dumdata.data;             
                    if strcmp(filenames{kk},'bulkparameters'); 
                        bulkparams.time = [bulkparams.time; datenum(data(:,1:6))+(data(:,7)/(8.64*10^7))]; 
                        bulkparams.hs = [bulkparams.hs; data(:,8)];
                        bulkparams.tm = [bulkparams.tm; data(:,9)];
                        bulkparams.tp = [bulkparams.tp; data(:,10)]; 
                        bulkparams.dm = [bulkparams.dm; data(:,11)];
                        bulkparams.dp = [bulkparams.dp; data(:,12)]; 
                        bulkparams.meanspr = [bulkparams.meanspr; data(:,13)];
                        bulkparams.pkspr = [bulkparams.pkspr; data(:,14)]; 
                    elseif strcmp(filenames{kk},'location'); 
                        locations.time = [locations.time; datenum(data(:,1:6))+(data(:,7)/(8.64*10^7))]; 
                        locations.lat = [locations.lat; data(:,8)]; 
                        locations.lon = [locations.lon; data(:,9)];
                    elseif strcmp(filenames{kk},'displacement'); 
                        displacements.time = [displacements.time; datenum(data(:,1:6))+(data(:,7)/(8.64*10^7))]; 
                        displacements.x = [displacements.x; data(:,8)];
                        displacements.y = [displacements.y; data(:,9)];
                        displacements.z = [displacements.z; data(:,10)]; 
                    elseif strcmp(filenames{kk},'sst'); 
                        sst.time = [sst.time; datenum(data(:,1:6))+(data(:,7)/(8.64*10^7))]; 
                        sst.sst = [sst.sst; data(:,8)];
                    end
                else
                    dumdata = importdata([filenames{kk} '.csv'],',',1);

                    if strcmp(filenames{kk},'a1')                   
                        spec.freq = [spec.freq; str2double(dumdata.textdata(9:end))]; 
                        spec.time = [spec.time; datenum(dumdata.data(:,1:6))+(dumdata.data(:,7)/(8.64*10^7))]; 
                    end
                    
                    if size(dumdata.data,2)~=size(spec.freq,2)
                        dumdata.data(:,end+1:size(spec.freq,2)+8)=nan; 
                    end                          
                    spec.(filenames{kk}) = [spec.(filenames{kk}); dumdata.data(:,9:end)];                                        
                end
            end
            
        end
    end
    disp(['Finished chunk ' num2str(j) ' out of ' num2str(size(fidx,2))]);
    clc
%%    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %clean up tmp directory for next chunk
    delete([datapath '\tmp\*.csv']);     
    
    if j == size(fidx,2)            
        disp('Finished processing Spotter data'); 
        cd(datapath); 
        rmdir([datapath '\tmp'],'s'); 
    end
    clear dumdata data 
end

%sample locations output data to get GPS locations for each bulkparameter
%output 
[bulkparams] = add_gps_to_bulkparams(bulkparams);

%spec frequency will be longer than a1, etc, so just fill with nan 
if length(spec.a1)~=length(spec.freq)
    fields = fieldnames(spec); 
    for j = 1:length(fields); 
        if ~strcmp(fields{j},'time')
            spec.(fields{j})(:,end:length(spec.freq)) = nan;
        end
    end
end


%% sub function for adding GPS locations to each bulk parameter observation 
function [bulkparams] = add_gps_to_bulkparams(bulkparams)
% get GPS location that corresponds to each bulkparameters measurement 

for i = 1:size(bulkparams.time,1)
    %add gps
    idx = find(abs(bulkparams.time(i)-locations.time)==min(abs(bulkparams.time(i)-locations.time))); 
    %check if empty
    if ~isempty(idx)
        %if not empty but more than 1 corresponding location point averge
        if length(idx)>1
            bulkparams.lat(i,1) = mean(locations.data(idx,8)); 
            bulkparams.lon(i,1) = mean(locations.data(idx,9));            
        %if not empty and only 1 point, make sure not more than 5 minutes
        %apart 
        else
            if abs(bulkparams.time(i)-locations.time(idx))>5/1440 %5 minutes
                bulkparams.lat(i,1) = nan;
                bulkparams.lon(i,1) = nan;              
            else
                bulkparams.lat(i,1) = locations.lat(idx);
                bulkparams.lon(i,1) = locations.lon(idx);  
            end
        end
    %if empty fill with nan
    else
        bulkparams.lat(i,1) = nan;
        bulkparams.lon(i,1) = nan; 
    end
       
end
end


end

