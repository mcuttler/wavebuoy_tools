%%  Process Sofar Spotter Data (delayed mode)
% This script processes Sofar Spotter data stored on the SD card (i.e. processes data after retrieval of buoy). 
% This requires the Sofar parser script (Python), accessible here: https://www.sofarocean.com/posts/parsing-script
% 
% The parser script will process all available data files (_FLT, _LOC, _SYS) available in a folder, however, due to computer memory issues, 
% this code chunks the data files into temporary folders and then concatenates results at the end. 
% 
% Final output files include: 
%     -bulkparameters.csv : CSV file containing wave parameters (Hs, Tp, Dp, etc.)
%     -displacements.csv: CSV file containin the raw displacements
%
% Example usage
%     MC to fill when finished
%     
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%     
% Code history
% 
%     Author          | Date             | Script Version     | Update
%     --------------------------------------------------------
%     M. Cuttler     | 27 Aug 2020 | 1.0                      | Initial creation
%     M. Cuttler     | 01 Sep 2020 | 1.1                      | Modified how files are appended to bulkparameters.csv 
%                                                                           output to account for when python parser generates files in sub-directories. 
%     M. Cuttler     | 03 Sep 2020 | 1.2                      | Included displacements.csv into the workflow and output 
%     M. Cuttler     | 08 Sep 2020 | 2.0                      | Modify code
%                                                                         | such that all data is appended to Matlab structures and then sub-set
%                                                                         | into monthly files for more efficient storage (may still run into
%                                                                         | Matlab memory issues 
%

%% set initial paths for Spotter data to process and parser script
clear; clc
%path to Spotter data to process - contains raw dump of SD card (_SYS,_FLT,
%_LOC files)
datapath = 'E:\Active_Projects\LOWE_IMOS_WaveBuoys\Data\SofarSpotter\SPOT0093_PerthCanyon_20191015_to_20200903'; 
%path of Sofar parser script
parserpath = 'E:\Active_Projects\LOWE_IMOS_WaveBuoys\Data\SofarSpotter\SofarParser\parser_v1.10.0';

%path to save netCDF files for transfer to AODN
outpathNC = 'E:\Active_Projects\LOWE_IMOS_WaveBuoys\Data\SofarSpotter\ProcessedData_DelayedMode\nc';
outpathMAT = 'E:\Active_Projects\LOWE_IMOS_WaveBuoys\Data\SofarSpotter\ProcessedData_DelayedMode\mat';

if ~exist(outpathNC)
    mkdir(outpathNC)
end

if ~exist(outpathMAT)
    mkdir(outpathMAT);
end

%spotter serial number and deployment info 
SpotterID = 'SPOT0093'; 
DeployLoc = 'PerthCanyon';


%% get list of files within datapath to figure out how many chunks to make

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

%set number of unique time poins to use
chunk = 10; 
fidx = 1:chunk:size(flist,1); 
%% prcoess chunks of data

%initiate structures for saving data
bulkparams = struct('time',[], 'hs',[],'tm',[]','tp',[],'dm',[],'dp',[],'meanspr',[],'pkspr',[]); 
locations = struct('time',[],'lat',[],'lon',[]); 
displacements = struct('time',[], 'x',[],'y',[],'z',[]); 
spec = struct('time',[],'a1',[],'b1',[],'a2',[],'b2',[],'Sxx',[],'Syy',[],'Szz',[]); 

for j = 1:size(fidx,2)
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
        copyfile([parserpath '\parser_v1.10.0.py'], [datapath '\tmp\parser_v1.10.0.py'])        
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
    system('set path=%path:C:\Program Files\MATLAB\R2018b\bin\win64;=% & python parser_v1.10.0.py');   
    
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
                filenames = {'bulkparameters','location','displacement','a1','a2','b1','b2','Sxx','Syy','Szz'}; 
                for kk = 1:length(filenames)
                    if kk<4
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
                        data = dumdata.data; 
                        if kk==4                    
                            spec.freq = str2double(dumdata.textdata(9:end)); 
                            spec.time = [spec.time; datenum(data(:,1:6))+(data(:,7)/(8.64*10^7))]; 
                        end
                        
                        eval(['spec.' filenames{kk} '= [spec.' filenames{kk} '; data(:,9:end)];']);
                    end
                end
                
                rmdir([datapath '\tmp\' subdir(k).name],'s');
            end
        end
    else
        filenames = {'bulkparameters','location','displacement','a1','a2','b1','b2','Sxx','Syy','Szz'};
        for kk = 1:length(filenames)
            if kk<4
                dumdata = importdata([filenames{kk} '.csv']); 
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
                dumdata = importdata([filenames{kk} '.csv'],',',1);
                data = dumdata.data; 
                if kk==4                    
                    spec.freq = str2double(dumdata.textdata(9:end)); 
                    spec.time = [spec.time; datenum(data(:,1:6))+(data(:,7)/(8.64*10^7))]; 
                end
               
                eval(['spec.' filenames{kk} '= [spec.' filenames{kk} '; data(:,9:end)];']); 
            end
        end                                                                                                                                                  
        
    end
    disp(['Finished chunk ' num2str(j) ' out of ' num2str(size(fidx,2))]); 
    clc
    
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

%% import combined data files and perform QA/QC   

%quality checks on bulkparams - applies to spec outputs too
%also find times in GPS file to save lat/lon for buoy position
qfbulk = []; 
for i = 1:size(bulkparams.time,1)
    %basic quality control by checking that mean and peak wave period aren't greater than 25 s
    if bulkparams.tm > 25 | bulkparams.tp > 25
        qfbulk(i,1) = 1; 
    else
        qfbulk(i,1) = 0; 
    end
    
    %check that wave height isn't more than 3 times larger than previous
    %measurement
    if i > 1
        if bulkparams.hs > 2*bulkparams.hs(i-1)
            qfbulk(i,2) = 1;
        else
            qfbulk(i,2) = 0; 
        end
    else
        qfbulk(i,2) = 0; 
    end
    
    %add flags together
    qfbulk(i,3) = sum(qfbulk(i,1:2)); 
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
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

%quality check for displacements 
qfdisp = []; 
for i = 1:size(displacements.x,1)
    qfdisp(i,1) = 0;
end

%quality check for GPS
qflocs = []; 
for i = 1:size(locations.time,1)
    qflocs(i,1) = 0;
end

 %% now build monthly netCDF files 
disp(['Saving data for ' SpotterID ' as netCDF']);         

%add IMOS toolbox
% addpath('D:\CUTTLER_GitHub\imos-toolbox\NetCDF'); 

%determine min and max months
t = datevec(bulkparams.time); 
tdata = unique(t(:,1:2),'rows'); 

for i = 1:size(tdata,1)
 
    tstart = datenum(tdata(i,1), tdata(i,2),1); 
    tend = datenum(tdata(i,1), tdata(i,2)+1, 1); 
    
    disp(['Saving ' datestr(tstart,'mmm yyyy')]); 
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %output for BULK PARAMETERS 
    idx_bulk = []; 
    idx_bulk = find(bulkparams.time>=tstart&bulkparams.time<tend);                 
    filenameNC = [outpathNC '\' SpotterID '_' DeployLoc '_' datestr(tstart,'yyyymm') '_bulk.nc']; 
  
    [m,c] = size(bulkparams.time(idx_bulk)); 
    %create variable entries
    nccreate(filenameNC,'time','Dimensions',{'time',m});
    nccreate(filenameNC,'Hs','Dimensions',{'Hs',m});
    nccreate(filenameNC,'Tm','Dimensions',{'Tm',m});
    nccreate(filenameNC,'Tp','Dimensions',{'Tp',m});
    nccreate(filenameNC,'Dm','Dimensions',{'Dm',m});
    nccreate(filenameNC,'Dp','Dimensions',{'Dp',m});
    nccreate(filenameNC,'MeanSpr','Dimensions',{'MeanSpr',m});
    nccreate(filenameNC,'PeakSpr','Dimensions',{'PeakSpr',m});
    nccreate(filenameNC,'Latitude','Dimensions',{'Latitude',m});
    nccreate(filenameNC,'Longitude','Dimensions',{'Longitude',m});
    nccreate(filenameNC,'QualityFlag','Dimensions',{'QualityFlag',m}); 
    
    %write data to variables 
    ncwrite(filenameNC,'time',bulkparams.time(idx_bulk));  
    ncwriteatt(filenameNC,'time','long_name','UTC');  
    ncwriteatt(filenameNC,'time','units','days since Jan-1-0000');
    
    ncwrite(filenameNC,'Hs',bulkparams.hs(idx_bulk)); 
    ncwriteatt(filenameNC,'Hs','long_name','significant wave height');  
    ncwriteatt(filenameNC,'Hs','units','m');
    
    ncwrite(filenameNC,'Tm',bulkparams.tm(idx_bulk));  
    ncwriteatt(filenameNC,'Tm','long_name','mean wave period');  
    ncwriteatt(filenameNC,'Tm','units','s');
    
    ncwrite(filenameNC,'Tp',bulkparams.tp(idx_bulk)); 
    ncwriteatt(filenameNC,'Tp','long_name','peak wave period');  
    ncwriteatt(filenameNC,'Tp','units','s');
    
    ncwrite(filenameNC,'Dm',bulkparams.dm(idx_bulk)); 
    ncwriteatt(filenameNC,'Dm','long_name','mean wave FROM direction');  
    ncwriteatt(filenameNC,'Dm','units','deg');
    
    ncwrite(filenameNC,'Dp',bulkparams.dp(idx_bulk));  
    ncwriteatt(filenameNC,'Dp','long_name','peak wave FROM direction');  
    ncwriteatt(filenameNC,'Dp','units','deg');
    
    ncwrite(filenameNC,'MeanSpr',bulkparams.meanspr(idx_bulk)); 
    ncwriteatt(filenameNC,'MeanSpr','long_name','mean spreading');  
    ncwriteatt(filenameNC,'MeanSpr','units','deg');
    
    ncwrite(filenameNC,'PeakSpr',bulkparams.pkspr(idx_bulk)); 
    ncwriteatt(filenameNC,'PeakSpr','long_name','peak spreading');  
    ncwriteatt(filenameNC,'PeakSpr','units','deg');
        
    ncwrite(filenameNC,'Latitude',bulkparams.lat(idx_bulk)); 
    ncwriteatt(filenameNC,'Latitude','long_name','latitude');  
    ncwriteatt(filenameNC,'Latitude','units','deg');
        
    ncwrite(filenameNC,'Longitude',bulkparams.lon(idx_bulk)); 
    ncwriteatt(filenameNC,'Longitude','long_name','longitude');  
    ncwriteatt(filenameNC,'Longitude','units','deg');
    
    ncwrite(filenameNC,'QualityFlag',qfbulk(idx_bulk,3)); 
    ncwriteatt(filenameNC,'QualityFlag','long_name','quality flag: 0 = good data, 1 = problem with wave height or period, 2 = problem with wave height and period');  
    ncwriteatt(filenameNC,'QualityFlag','units','-');
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %output netCDF for DISPLACEMENTS
    idx_disp = []; 
    idx_disp = find(displacements.time>=tstart&displacements.time<tend);                 
    filenameNC = [outpathNC '\' SpotterID '_' DeployLoc '_' datestr(tstart,'yyyymm') '_disp.nc']; 
    
    [m,c] = size(displacements.time(idx_disp)); 
    nccreate(filenameNC,'disp_time','Dimensions',{'time',m});
    nccreate(filenameNC,'x','Dimensions',{'x',m}); 
    nccreate(filenameNC,'y','Dimensions',{'y',m}); 
    nccreate(filenameNC,'z','Dimensions',{'z',m});     
    nccreate(filenameNC,'QualityFlag','Dimensions',{'QualityFlag',m}); 
    
    ncwrite(filenameNC,'disp_time',displacements.time(idx_disp)); 
    ncwriteatt(filenameNC,'disp_time','long_name','UTC');  
    ncwriteatt(filenameNC,'disp_time','units','days since Jan-1-0000, includes milliseconds');    
    
    ncwrite(filenameNC,'x',displacements.x(idx_disp)); 
    ncwriteatt(filenameNC,'x','long_name','x displacement');  
    ncwriteatt(filenameNC,'x','units','m');
    
    ncwrite(filenameNC,'y',displacements.y(idx_disp));           
    ncwriteatt(filenameNC,'y','long_name','y displacement');  
    ncwriteatt(filenameNC,'y','units','m');   
    
    ncwrite(filenameNC,'z',displacements.z(idx_disp)); 
    ncwriteatt(filenameNC,'z','long_name','z displacement');  
    ncwriteatt(filenameNC,'z','units','m');
    
    ncwrite(filenameNC,'QualityFlag',qfdisp(idx_disp)); 
    ncwriteatt(filenameNC,'QualityFlag','long_name','quality flag: COMPLETE WHEN QUALITY FLAGS ARE FINISHED');  
    ncwriteatt(filenameNC,'QualityFlag','units','-');
    
        
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %output netCDF for LOCATIONS
    idx_locs = []; 
    idx_locs = find(locations.time>=tstart&locations.time<tend);                 
    filenameNC = [outpathNC '\' SpotterID '_' DeployLoc '_' datestr(tstart,'yyyymm') '_gps.nc']; 
    
    [m,c] = size(locations.time(idx_locs)); 
    nccreate(filenameNC,'time','Dimensions',{'time',m});
    nccreate(filenameNC,'lat','Dimensions',{'lat',m}); 
   nccreate(filenameNC,'lon','Dimensions',{'lon',m});   
    nccreate(filenameNC,'QualityFlag','Dimensions',{'QualityFlag',m}); 
    
    ncwrite(filenameNC,'time',locations.time(idx_locs)); 
    ncwriteatt(filenameNC,'time','long_name','UTC');  
    ncwriteatt(filenameNC,'time','units','days since Jan-1-0000, includes milliseconds');    
    
    ncwrite(filenameNC,'lat',locations.lat(idx_locs)); 
    ncwriteatt(filenameNC,'lat','long_name','latitude');  
    ncwriteatt(filenameNC,'lat','units','deg');
    
    ncwrite(filenameNC,'lon', locations.lon(idx_locs)); 
    ncwriteatt(filenameNC,'lon','long_name','longitude');  
    ncwriteatt(filenameNC,'lon','units','m');
    
    ncwrite(filenameNC,'QualityFlag',qflocs(idx_locs)); 
    ncwriteatt(filenameNC,'QualityFlag','long_name','quality flag: COMPLETE WHEN QUALITY FLAGS ARE FINISHED');  
    ncwriteatt(filenameNC,'QualityFlag','units','-');
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %output netCDF for SPECTRAL DATA
    idx_spec = []; 
    idx_spec = find(spec.time>=tstart&spec.time<tend);                 
    filenameNC = [outpathNC '\' SpotterID '_' DeployLoc '_' datestr(tstart,'yyyymm') '_spec.nc']; 
    
    [m,c] = size(spec.a1(idx_spec,:)); 

    nccreate(filenameNC,'time','Dimensions',{'time',m});
    nccreate(filenameNC,'a1','Dimensions',{'time',m,'freq',c}); 
    nccreate(filenameNC,'a2','Dimensions',{'time',m,'freq',c}); 
    nccreate(filenameNC,'b1','Dimensions',{'time',m,'freq',c}); 
    nccreate(filenameNC,'b2','Dimensions',{'time',m,'freq',c}); 
    nccreate(filenameNC,'Sxx','Dimensions',{'time',m,'freq',c}); 
    nccreate(filenameNC,'Syy','Dimensions',{'time',m,'freq',c}); 
    nccreate(filenameNC,'Szz','Dimensions',{'time',m,'freq',c}); 
    nccreate(filenameNC,'freq','Dimensions',{'time',m,'freq',c}); 
    nccreate(filenameNC,'QualityFlag','Dimensions',{'QualityFlag',m}); 
    
    ncwrite(filenameNC,'time', spec.time(idx_spec)); 
    ncwriteatt(filenameNC,'time','long_name','UTC');  
    ncwriteatt(filenameNC,'time','units','days since Jan-1-0000, includes milliseconds');    
    
    ncwrite(filenameNC,'a1', spec.a1(idx_spec,:)); 
    ncwriteatt(filenameNC,'a1','long_name','spectral coefficient a1');  
    ncwriteatt(filenameNC,'a1','units','-');    
        
    ncwrite(filenameNC,'b1', spec.b1(idx_spec,:)); 
    ncwriteatt(filenameNC,'b1','long_name','spectral coefficient a1');  
    ncwriteatt(filenameNC,'b1','units','-');
        
    ncwrite(filenameNC,'a2', spec.a2(idx_spec,:)); 
    ncwriteatt(filenameNC,'a2','long_name','spectral coefficient a1');  
    ncwriteatt(filenameNC,'a2','units','-');    
        
    ncwrite(filenameNC,'b2', spec.b2(idx_spec,:)); 
    ncwriteatt(filenameNC,'b2','long_name','spectral coefficient a1');  
    ncwriteatt(filenameNC,'b2','units','-');    
        
    ncwrite(filenameNC,'Sxx', spec.Sxx(idx_spec,:)); 
    ncwriteatt(filenameNC,'Sxx','long_name','spectral coefficient a1');  
    ncwriteatt(filenameNC,'Sxx','units','-');    
        
    ncwrite(filenameNC,'Syy', spec.Syy(idx_spec,:)); 
    ncwriteatt(filenameNC,'Syy','long_name','spectral coefficient a1');  
    ncwriteatt(filenameNC,'Syy','units','-');
        
    ncwrite(filenameNC,'Szz', spec.Szz(idx_spec,:)); 
    ncwriteatt(filenameNC,'Szz','long_name','spectral coefficient a1');  
    ncwriteatt(filenameNC,'Szz','units','-');        
    
    %frequency is longer than spectral coefficients because Sofar pads with
    %nans
    ncwrite(filenameNC,'freq', spec.freq(1:c)); 
    ncwriteatt(filenameNC,'freq','long_name','frequency');  
    ncwriteatt(filenameNC,'freq','units','Hz'); 

    ncwrite(filenameNC,'QualityFlag',qfbulk(idx_spec,3));  
    ncwriteatt(filenameNC,'QualityFlag','long_name','quality flag: 0 = good data, 1 = problem with wave height or period, 2 = problem with wave height and period');  
    ncwriteatt(filenameNC,'QualityFlag','units','-');
        
end
    
%clear command window and displayed finished processing
clc; 
disp(['Finished processing ' SpotterID ' delayed mode']); 

%% plot quick figure
% figure; 
% plot(datenum(bulkparams.data(:,1:6)), bulkparams.data(:,8)); 
% hold on;
% idx1 = find(qfbulk(:,3)==0); 
% idx2 = find(qfbulk(:,3)==1); 
% idx3 = find(qfbulk(:,3)==2); 
% 
% if ~isempty(idx1)
%     h(1) = plot(datenum(bulkparams.data(idx1,1:6)), bulkparams.data(idx1,8),'g.'); 
% else
%     h(1) = plot(0,0,'g.');
% end
% 
% if ~isempty(idx2)
%     h(2) = plot(datenum(bulkparams.data(idx2,1:6)), bulkparams.data(idx2,8),'y.'); 
% else
%      h(2) = plot(0,0,'g.');
% end
% 
% if ~isempty(idx3)
%     h(3) = plot(datenum(bulkparams.data(idx3,1:6)), bulkparams.data(idx3,8),'r.'); 
% else
%     h(3) = plot(0,0,'r.'); 
% end
% 
% set(gca,'xlim',[datenum(StartDate,'yyyymmdd') datenum(EndDate,'yyyymmdd')]); 
% datetick('x','mmm-dd','keepticks'); 
% xlabel('Date (mmm-dd');
% ylabel('Hs (m)'); 
% grid on; 
% title(SpotterID); 
% legend(h,{'Good','Questionable','Bad'},'location','best'); 
%         

        
        
       




