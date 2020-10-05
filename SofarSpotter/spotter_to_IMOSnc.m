%% IMOS-compliant netCDF


%%

function [] = spotter_to_IMOSnc(bulkparams, idx_bulk, filenameNC, spot_info); 

  
%create output netCDF4 file 
ncid = netcdf.create(filenameNC, 'netcdf4');   

%global attributes
globfile = 'D:\CUTTLER_GitHub\wavebuoy_tools\SofarSpotter\glob_att_Spotter_timeSeries.txt'; 

fid = fopen(globfile); 
%skip first line
fgetl(fid); 
for i = 1:24
    txt = fgetl(fid); 
    idx = find(txt == '='); 
    ncwriteatt(filenameNC,'/',txt(1:idx-1),txt(idx+1:end)); 
    

fileattrib(filenameNC,'+w');
ncwriteatt(filenameNC,'/','creation_date',datestr(now));


%variable attributes
fileattrib(filenameNC,'+w');
ncwriteatt(filenameNC, 'peaks','description','Output of PEAKS');

  [m,c] = size(bulkparams.time(idx_bulk)); 

  
  'time','Dimensions',{'time',m});    
        
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
    