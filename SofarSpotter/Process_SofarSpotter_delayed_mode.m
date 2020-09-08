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

%path to Spotter data to process - contains raw dump of SD card (_SYS,_FLT,
%_LOC files)
datapath = 'E:\Active_Projects\LOWE_IMOS_WaveBuoys\Data\SofarSpotter\Data_for_testing'; 
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
SpotterID = 'SPOT0172'; 
DeployLoc = 'Testing';
StartDate = '20200319';
EndDate = '20200529';


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
    disp(['Adding data for chunk ' num2str(j) ' to bulkparameters and displacement output CSV'])
    
    %append each chunk to bulkparameters.csv and displacements --- I wonder
    %if more memory efficient to just build large variables/structures and
    %then save CSV at end? 
    if exist([datapath '\tmp\bulkparameters.csv'])~=0 && j == 1
        copyfile([datapath '\tmp\bulkparameters.csv'], datapath)
        copyfile([datapath '\tmp\displacement.csv'], datapath)
        copyfile([datapath '\tmp\location.csv'], datapath)
    elseif exist([datapath '\tmp\bulkparameters.csv'])~=0 && j > 1
        dumdata = importdata([datapath '\tmp\bulkparameters.csv']);
        dlmwrite([datapath '\bulkparameters.csv'], dumdata.data, 'delimiter',',', '-append');        
        dumdata2 = importdata([datapath '\tmp\displacement.csv']);
        dlmwrite([datapath '\displacement.csv'], dumdata2.data, 'delimiter',',', '-append');        
        dumdata3 = importdata([datapath '\tmp\location.csv']);
        dlmwrite([datapath '\location.csv'], dumdata3.data, 'delimiter',',', '-append');     
    %for some instances parser generates subdirectories
    elseif exist([datapath '\tmp\bulkparameters.csv'])==0
        %get list of subfolders
        subdir = dir([datapath '\tmp']); 
        subdir = subdir(3:end); 
        dirFlags = [subdir.isdir]; 
        for k = 1:size(dirFlags,2); 
            if dirFlags(k)>0
                dumdata = importdata([datapath '\tmp\' subdir(k).name '\bulkparameters.csv']);
                dlmwrite([datapath '\bulkparameters.csv'], dumdata.data, 'delimiter',',', '-append');
                dumdata2 = importdata([datapath '\tmp\' subdir(k).name '\bulkparameters.csv']);
                dlmwrite([datapath '\displacement.csv'], dumdata2.data, 'delimiter',',', '-append');
                dumdata3 = importdata([datapath '\tmp\' subdir(k).name '\bulkparameters.csv']);
                dlmwrite([datapath '\location.csv'], dumdata3.data, 'delimiter',',', '-append');   
                rmdir([datapath '\tmp\' subdir(k).name],'s'); 
            end
        end                            
    end
    disp(['Finished bulk parameters, adding chunk ' num2str(j) ' to displacements and spectra'])   
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %add code for displacements and spectral data
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %clean up tmp directory for next chunk
    delete([datapath '\tmp\*.csv']);     
    
    if j == size(fidx,2)            
        disp('Finished processing Spotter data'); 
        cd(datapath); 
        rmdir([datapath '\tmp'],'s'); 
    end
    clear dumdata
end

%% import combined data files and perform QA/QC
bulkparams = importdata([datapath '\bulkparameters.csv']);   
displacements = importdata([datapath '\displacement.csv']); 
locations = importdata([datapath '\location.csv']); 
    

qf = []; 
for i = 1:size(bulkparams.data,1)
    %basic quality control by checking that mean and peak wave period aren't greater than 25 s
    if bulkparams.data(i,9) > 25| bulkparams.data(i,10) > 25
        qf(i,1) = 1; 
    else
        qf(i,1) = 0; 
    end
    
    %check that wave height isn't more than 3 times larger than previous
    %measurement
    if i > 1
        if bulkparams.data(i,8) > 2*bulkparams.data(i-1,8)
            qf(i,2) = 1;
        else
            qf(i,2) = 0; 
        end
    else
        qf(i,2) = 0; 
    end
    
    %add flags together
    qf(i,3) = sum(qf(i,1:2)); 
end      
    
 %% now build final netCDF files 
disp(['Saving data for ' SpotterID 'as netCDF and MAT files']);         

%add IMOS toolbox
addpath('D:\CUTTLER_GitHub\imos-toolbox\NetCDF'); 


filenameNC = [outpathNC '\' SpotterID '_' DeployLoc '_' StartDate '_' EndDate '.nc'];
%save netcdf file for bulk parameters
[m,c] = size(bulkparams.data);
nccreate(filenameNC,'time','Dimensions',{'time',m});
nccreate(filenameNC,'Hs','Dimensions',{'Hs',m});
nccreate(filenameNC,'Tm','Dimensions',{'Tm',m});
nccreate(filenameNC,'Tp','Dimensions',{'Tp',m});
nccreate(filenameNC,'Dm','Dimensions',{'Dm',m});
nccreate(filenameNC,'Dp','Dimensions',{'Dp',m});
nccreate(filenameNC,'MeanSpr','Dimensions',{'MeanSpr',m});
nccreate(filenameNC,'PeakSpr','Dimensions',{'PeakSpr',m});
nccreate(filenameNC,'QualityFlag','Dimensions',{'QualityFlag',m}); 

ncwrite(filenameNC,'time',datenum(bulkparams.data(:,1:6))); 
ncwriteatt(filenameNC,'time','long_name','UTC');  
ncwriteatt(filenameNC,'time','units','days since Jan-1-0000');

ncwrite(filenameNC,'Hs',bulkparams.data(:,8));
ncwriteatt(filenameNC,'Hs','long_name','significant wave height');  
ncwriteatt(filenameNC,'Hs','units','m');

ncwrite(filenameNC,'Tm',bulkparams.data(:,9));
ncwriteatt(filenameNC,'Tm','long_name','mean wave period');  
ncwriteatt(filenameNC,'Tm','units','s');

ncwrite(filenameNC,'Tp',bulkparams.data(:,10));
ncwriteatt(filenameNC,'Tp','long_name','peak wave period');  
ncwriteatt(filenameNC,'Tp','units','s');

ncwrite(filenameNC,'Dm',bulkparams.data(:,11));
ncwriteatt(filenameNC,'Dm','long_name','mean wave FROM direction');  
ncwriteatt(filenameNC,'Dm','units','deg');

ncwrite(filenameNC,'Dp',bulkparams.data(:,12));
ncwriteatt(filenameNC,'Dp','long_name','peak wave FROM direction');  
ncwriteatt(filenameNC,'Dp','units','deg');

ncwrite(filenameNC,'MeanSpr',bulkparams.data(:,13));
ncwriteatt(filenameNC,'MeanSpr','long_name','mean spreading');  
ncwriteatt(filenameNC,'MeanSpr','units','deg');

ncwrite(filenameNC,'PeakSpr',bulkparams.data(:,14));
ncwriteatt(filenameNC,'PeakSpr','long_name','peak spreading');  
ncwriteatt(filenameNC,'PeakSpr','units','deg');

ncwrite(filenameNC,'QualityFlag',qf(:,3)); 
ncwriteatt(filenameNC,'QualityFlag','long_name','quality flag: 0 = good data, 1 = problem with wave height or period, 2 = problem with wave height and period');  
ncwriteatt(filenameNC,'QualityFlag','units','deg');

%add data for displacements
[m,c] = size(displacements.data);
nccreate(filenameNC,'disp_time','Dimensions',{'time',m});
nccreate(filenameNC,'displacements','Dimensions',{'QualityFlag',m}); 

ncwrite(filenameNC,'disp_time',datenum(displacements.data(:,1:6))+displacements.data(:,7)/(8.64*10^7)); 
ncwriteatt(filenameNC,'disp_time','long_name','UTC');  
ncwriteatt(filenameNC,'disp_time','units','days since Jan-1-0000, includes milliseconds');

ncwrite(filenameNC,'displacements',displacements.data(:,8:10)); 
ncwriteatt(filenameNC,'displacements','long_name','xyz displacements, [x, y, z]');  
ncwriteatt(filenameNC,'displacements','units','m');

%save .mat file
filenameMAT = [outpathMAT '\' SpotterID '_' DeployLoc '_' StartDate '_' EndDate '.mat'];
save(filenameMAT, 'bulkparams', 'displacements','-v7.3');    
    
%clear command window and displayed finished processing
clc; 
disp(['Finished processing ' SpotterID ' delayed mode']); 

%% plot quick figure
figure; 
plot(datenum(bulkparams.data(:,1:6)), bulkparams.data(:,8)); 
hold on;
idx1 = find(qf(:,3)==0); 
idx2 = find(qf(:,3)==1); 
idx3 = find(qf(:,3)==2); 

if ~isempty(idx1)
    h(1) = plot(datenum(bulkparams.data(idx1,1:6)), bulkparams.data(idx1,8),'g.'); 
else
    h(1) = plot(0,0,'g.');
end

if ~isempty(idx2)
    h(2) = plot(datenum(bulkparams.data(idx2,1:6)), bulkparams.data(idx2,8),'y.'); 
else
     h(2) = plot(0,0,'g.');
end

if ~isempty(idx3)
    h(3) = plot(datenum(bulkparams.data(idx3,1:6)), bulkparams.data(idx3,8),'r.'); 
else
    h(3) = plot(0,0,'r.'); 
end

set(gca,'xlim',[datenum(StartDate,'yyyymmdd') datenum(EndDate,'yyyymmdd')]); 
datetick('x','mmm-dd','keepticks'); 
xlabel('Date (mmm-dd');
ylabel('Hs (m)'); 
grid on; 
title(SpotterID); 
legend(h,{'Good','Questionable','Bad'},'location','best'); 
        

        
        
       




