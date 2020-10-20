%% Code that holds snippets of code not being used

%%  random codes for future QARTOD QA/QC test
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% QARTOD TEST 17 - LT time series operational frequency range

% NOT USED BECAUSE TESTING BULK PARAMETERS - 
% DO NOT HAVE OPERATIONAL FREQUENCY RANGE INFORMATION

% [bulkparams.qf17] = qartod_17_operational_frequency(check);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  QARTOD TEST 18 - LT Time series Low-Frequency Energy 

% NOT USED BECAUSE TESTING BULK PARAMETERS - 
% DO NOT HAVE OPERATIONAL FREQUENCY RANGE INFORMATION

% [bulkparams.qf18] = qartod_18_low_frequency(check); 
%% this is a test to show CArlin

%% test building netcdf
% bulkparams_to_IMOS_nc(bulkparams, outpathNC, buoy_info, globfile, varsfile); 
% inputs
%buoy type and deployment info number and deployment info 
 load('E:\Active_Projects\LOWE_IMOS_WaveBuoys\Data\SPOT0171_Testing_202002_202002.mat')
buoy_info.type = 'sofar'; 
buoy_info.name = 'SPOT0171'; %spotter serial number, or just Datawell 
buoy_info.version = 'V1'; %or DWR4 for Datawell, for example
buoy_info.DeployLoc = 'Testing';
buoy_info.DeployDepth = 30; 
buoy_info.DeployLat = -35; 
buoy_info.DeployLon = 117; 
%use this website to calculate magnetic declination: https://www.ngdc.noaa.gov/geomag/calculators/magcalc.shtml#declination
buoy_info.MagDec = 1.98; 
globfile = 'D:\CUTTLER_GitHub\wavebuoy_tools\wavebuoys\imos_nc\metadata\glob_att_Spotter_bulkparams_timeSeries.txt';     
varsfile = 'D:\CUTTLER_GitHub\wavebuoy_tools\wavebuoys\imos_nc\metadata\bulk_wave_parameters_mapping.csv';        
outpathNC = 'E:\Active_Projects\LOWE_IMOS_WaveBuoys\Data\';

% 
if strcmp(buoy_info.type,'sofar')==1
    outpathNC = [outpathNC '\SofarSpotter\ProcessedData_DelayedMode\nc'];     
elseif strcmp(buoy_info.type,'datawell')==1
     outpathNC = [outpathNC '\Datawell\ProcessedData_DelayedMode\nc'];         
end

if ~exist(outpathNC)
    mkdir(outpathNC)
end
        
%determine min and max months
t = datevec(bulkparams.time); 
tdata = unique(t(:,1:2),'rows'); 

% for i = 1:size(tdata,1)
i = 1; 
 
    tstart = datenum(tdata(i,1), tdata(i,2),1); 
    tend = datenum(tdata(i,1), tdata(i,2)+1, 1); 
    
    disp(['Saving bulkparams ' datestr(tstart,'mmm yyyy')]); 
    
    %output for BULK PARAMETERS     
    idx_bulk = []; 
    idx_bulk = find(bulkparams.time>=tstart&bulkparams.time<tend); 
    
    filenameNC = [outpathNC '\' buoy_info.name '_' buoy_info.DeployLoc '_' datestr(tstart,'yyyymm') '_bulk1.nc'];             
    
            
    %create output netCDF4 file     
    ncid = netcdf.create(filenameNC,'NETCDF4'); 
    netcdf.close(ncid); 
    
    %% global attributes
    
    fid = fopen(globfile); 
    globatts = textscan(fid, '%s%s','delimiter','='); 
    fclose(fid);
    
    ncid = netcdf.open(filenameNC,'WRITE'); 
    varid = netcdf.getConstant('GLOBAL');
    
    for ii = 1:size(globatts{1,1},1);
        
        attname = globatts{1,1}{ii};
        %get rid of trailing spaces
        idx = find(attname~= ' '); 
        attname = attname(idx); 
        attvalue = globatts{1,2}{ii}; 
        
        if strcmp(attname, 'instrument_maker')
            netcdf.putAtt(ncid,varid, attname, buoy_info.type);          
        elseif strcmp(attname, 'instrument_model')
            netcdf.putAtt(ncid,varid, attname, buoy_info.version);    
        elseif strcmp(attname, 'site_code')
            netcdf.putAtt(ncid,varid, attname, [buoy_info.name '_' buoy_info.DeployLoc]);
        elseif strcmp(attname, 'site_name')
            netcdf.putAtt(ncid,varid, attname, buoy_info.DeployLoc);
        elseif strcmp(attname, 'water_depth')
            netcdf.putAtt(ncid,varid, attname, buoy_info.DeployDepth);
        elseif strcmp(attname, 'geospatial_lat_min')
            netcdf.putAtt(ncid,varid, attname, num2str(nanmin(bulkparams.lat))); 
        elseif strcmp(attname, 'geospatial_lon_min')
            netcdf.putAtt(ncid,varid, attname, num2str(nanmin(bulkparams.lon))); 
        elseif strcmp(attname, 'geospatial_lat_max')
            netcdf.putAtt(ncid,varid, attname, num2str(nanmax(bulkparams.lat)));
        elseif strcmp(attname, 'geospatial_lon_max')
            netcdf.putAtt(ncid,varid, attname, num2str(nanmin(bulkparams.lon))); 
        elseif strcmp(attname, 'time_coverage_start')
            netcdf.putAtt(ncid,varid, attname, [datestr(bulkparams.time(1),'yyyy-mm-dd HH:MM:SS') ' UTC']); 
        elseif strcmp(attname, 'time_coverage_end')
            netcdf.putAtt(ncid,varid, attname, [datestr(bulkparams.time(end),'yyyy-mm-dd HH:MM:SS') ' UTC']); 
        elseif strcmp(attname, 'date_created')
            netcdf.putAtt(ncid,varid, attname, [datestr(now-datenum(0,0,0,8,0,0),'yyyy-mm-dd HH:MM:SS') ' UTC']);   
        else
            netcdf.putAtt(ncid,varid, attname, attvalue);
        end
        
    end
    netcdf.close(ncid);
    
    %%
    % define dimensions \
    ncid = netcdf.open(filenameNC,'WRITE'); 
    dimname = 'TIME';
    dimlength = size(bulkparams.time(idx_bulk),1);
    
    dimid_TIME = netcdf.defDim(ncid, dimname, dimlength);     
    
    dimname = 'station_id_strlen';
    dimlength = 30; 
    
    dimid_str = netcdf.defDim(ncid, dimname, dimlength); 
    
    % write variables 
    
    %parameter mapping file organised as: 
    % [original name, varname, standard name, long name, units, comments, ancillary invo, valid min, valid max, reference, positive]
    
    fid = fopen(varsfile); 
    varinfo = textscan(fid, '%s%s%s%s%s%s%s%s%s%f%f%s%s%s%s%s','delimiter',',','headerlines',1); 
    fclose(fid);      
    
    attnames = {'standard_name', 'long_name', 'units', 'calendar','axis','comments', 'ancillary_variables', 'valid_min', 'valid_max', 'reference_datum','magnetic_dec', 'positive',...
        'observation_type','coordinates','_FillValue'}; 
    
    attinfo = varinfo(3:end); 
    
    [m,~] = size(varinfo{1,1}); 
    for ii = 1:m    
        %include STATION_ID 
        if ii ==1
            netcdf.defVar(ncid, 'STATION_ID','char',[dimid_TIME dimid_str]); 
            varid = netcdf.inqVarID(ncid,'STATION_ID');   
            
            netcdf.putAtt(ncid, varid, 'ioos_category','Identifier');
            netcdf.putAtt(ncid, varid, 'cf_role','timeseries_id');
            netcdf.putAtt(ncid, varid, 'long_name','station name');
            
            %variable for STATION_ID --- ask IMOS
%             st_id = []; 
%             netcdf.putVar(ncid, varid, st_id); 
        end
        
        %create and define variable and attributes      
        netcdf.defVar(ncid, varinfo{1,2}{ii,1}, 'double', dimid_TIME);        
        varid = netcdf.inqVarID(ncid,varinfo{1,2}{ii});   
        netcdf.defVarFill(ncid,varid,false,-9999.9);
        
        %add attributes
        for j = 1:length(attinfo); 
            if strcmp(attnames{j},'valid_min') | strcmp(attnames{j},'valid_max')
                if ~isnan(attinfo{1,j}(ii))
                    netcdf.putAtt(ncid, varid, attnames{j},attinfo{1,j}(ii));
                end            
            else
                if ~isempty(attinfo{1,j}{ii})
                    if strcmp(attnames{j},'magnetic_dec')
                        netcdf.putAtt(ncid, varid, attnames{j}, buoy_info.MagDec)
                    else
                        netcdf.putAtt(ncid, varid, attnames{j},attinfo{1,j}{ii});
                    end
                end
            end
        end
        
        %put data to variable
        if strcmp(varinfo{1,1}{ii,1},'temp')
            %modify this for spotter v2
            netcdf.putVar(ncid, varid, ones(size(bulkparams.time(idx_bulk))).*nan); 
        elseif strcmp(varinfo{1,1}{ii,1},'time')
            imos_time = bulkparams.time(idx_bulk) - datenum(1950,1,1,0,0,0); 
            netcdf.putVar(ncid, varid, imos_time); 
        else
            netcdf.putVar(ncid, varid, bulkparams.(varinfo{1,1}{ii,1})(idx_bulk));
        end
        
    end
    
    netcdf.close(ncid);    
