%% IMOS-compliant netCDF

% Create an IMOS-compliant netCDF file for spectral parameters 


%%

function [] = spec_to_IMOS_ARDC_nc(data, buoy_info, globfile, varsfile); 


if ~exist(buoy_info.archive_path)
    mkdir(buoy_info.archive_path)
end        

disp(['Saving spectral data']);  

filenameNC = make_imos_ardc_filename(buoy_info,'WAVE-SPECTRA');         

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
    
    if strcmp(attname, 'project')
        netcdf.putAtt(ncid,varid, attname, buoy_info.project);        
    elseif strcmp(attname, 'date_created')
        tdum = datestr(now - datenum(0,0,0,8,0,0),31); 
        tdum(11) = 'T'; tdum(end+1)='Z';
        netcdf.putAtt(ncid,varid, attname,tdum);  
    elseif strcmp(attname, 'site_name')
        netcdf.putAtt(ncid,varid, attname, buoy_info.site_name);
    elseif strcmp(attname, 'instrument')
        netcdf.putAtt(ncid,varid, attname, buoy_info.instrument);    
    elseif strcmp(attname,'wave_motion_sensor_type'); 
        netcdf.putAtt(ncid,varid, attname,buoy_info.wave_motion_sensor_type); 
    elseif strcmp(attname,'wave_sensor_serial_number'); 
        netcdf.putAtt(ncid,varid, attname,buoy_info.wave_sensor_serial_number); 
    elseif strcmp(attname,'hull_serial_number'); 
        netcdf.putAtt(ncid,varid, attname,buoy_info.hull_serial_number); 
    elseif strcmp(attname,'instrument_burst_duration'); 
        netcdf.putAtt(ncid,varid, attname,buoy_info.instrument_burst_duration); 
    elseif strcmp(attname,'instrument_burst_interval'); 
        netcdf.putAtt(ncid,varid, attname,buoy_info.instrument_burst_interval); 
    elseif strcmp(attname,'instrument_sampling_interval'); 
        netcdf.putAtt(ncid,varid, attname,buoy_info.instrument_sampling_interval);         
    elseif strcmp(attname, 'water_depth')
        netcdf.putAtt(ncid,varid, attname, buoy_info.DeployDepth);
    elseif strcmp(attname, 'time_coverage_start')
        tdum = datestr(data.time(1),31); 
        tdum(11) = 'T'; tdum(end+1)='Z';
        netcdf.putAtt(ncid,varid, attname, tdum); 
    elseif strcmp(attname, 'time_coverage_end') 
        tdum = datestr(data.time(end),31); 
        tdum(11) = 'T'; tdum(end+1)='Z';
        netcdf.putAtt(ncid,varid, attname,tdum);   
    elseif strcmp(attname, 'geospatial_lat_min')        
        dlat = data.lat; dlat(dlat<-99)=nan;
        netcdf.putAtt(ncid,varid, attname, (nanmin(dlat))); 
    elseif strcmp(attname, 'geospatial_lon_min')
        dlon = data.lon; dlon(dlon<-99)=nan;
        netcdf.putAtt(ncid,varid, attname, (nanmin(dlon))); 
    elseif strcmp(attname, 'geospatial_lat_max')        
        netcdf.putAtt(ncid,varid, attname, (nanmax(dlat))); 
    elseif strcmp(attname, 'geospatial_lon_max')       
        netcdf.putAtt(ncid,varid, attname, (nanmax(dlon))); 
    elseif strcmp(attname, 'watch_circle')       
        netcdf.putAtt(ncid,varid, attname, buoy_info.watch_circle); 
    elseif strcmp(attname,'buoy_specification_url')
        netcdf.putAtt(ncid,varid,attname,buoy_info.buoy_specification_url); 
    else
        netcdf.putAtt(ncid,varid, attname, attvalue);
    end
    
end
netcdf.close(ncid);      

%%
% define dimensions         

ncid = netcdf.open(filenameNC,'WRITE'); 
dimname = 'TIME';
dimlength = size(data.time,1);
dimid_TIME = netcdf.defDim(ncid, dimname, dimlength);     

dimname = 'FREQUENCY';
dimlength = size(data.frequency,2);
dimid_FREQUENCY = netcdf.defDim(ncid, dimname, dimlength);     

dimname = 'timeSeries';
dimlength = 1;
dimid_timeSeries = netcdf.defDim(ncid, dimname, dimlength); 

% write variables     
fid = fopen(varsfile); 
varinfo = textscan(fid, '%s%s%s%s%s%s%s%s%f%f%s%s%s','delimiter',',','headerlines',1,'EndOfLine','\n'); 
fclose(fid);      

attnames = {'standard_name', 'long_name', 'units', 'axis','calendar', 'sampling_period_timestamp_location', 'valid_min', 'valid_max', 'reference_datum',...
    'coordinates','comment'}; 

attinfo = varinfo(3:end);     

[m,~] = size(varinfo{1,1}); 
for ii = 1:m       
    %add timeSeries variable in 
    if ii == 1
        netcdf.defVar(ncid, 'timeSeries', 'NC_INT',dimid_timeSeries);
        varid = netcdf.inqVarID(ncid, 'timeSeries');
        netcdf.defVarFill(ncid,varid,true,int32(-9999)); 
        netcdf.putAtt(ncid, varid, 'long_name','Unique identifier for each feature instance'); 
        netcdf.putAtt(ncid, varid, 'cf_role','timeseries_id');         
        netcdf.putVar(ncid, varid, int32(1)); 
        
    end
    %create and define variable and attributes    
    if strcmp(varinfo{1,2}{ii,1},'LATITUDE') | strcmp(varinfo{1,2}{ii,1},'LONGITUDE') 
        netcdf.defVar(ncid, varinfo{1,2}{ii,1}, 'NC_DOUBLE', dimid_TIME);
        varid = netcdf.inqVarID(ncid,varinfo{1,2}{ii});  
        netcdf.defVarFill(ncid,varid,false,-9999);
    elseif strcmp(varinfo{1,2}{ii,1},'FREQUENCY')
        netcdf.defVar(ncid, varinfo{1,2}{ii,1}, 'NC_FLOAT', dimid_FREQUENCY);
        varid = netcdf.inqVarID(ncid,varinfo{1,2}{ii});  
        netcdf.defVarFill(ncid,varid,false,single(-9999)); 
    elseif strcmp(varinfo{1,2}{ii,1},'TIME')
        netcdf.defVar(ncid, varinfo{1,2}{ii,1}, 'NC_DOUBLE', dimid_TIME);
        varid = netcdf.inqVarID(ncid,varinfo{1,2}{ii});  
        netcdf.defVarFill(ncid,varid,true,-9999);
    else
        netcdf.defVar(ncid, varinfo{1,2}{ii,1}, 'NC_FLOAT', [dimid_TIME dimid_FREQUENCY]);
        varid = netcdf.inqVarID(ncid,varinfo{1,2}{ii});  
        netcdf.defVarFill(ncid,varid,false,single(-9999)); 
    end    
    
    %add attributes
    for j = 1:length(attinfo); 
        if strcmp(attnames{j},'valid_min')      
            if ~isnan(attinfo{1,j}(ii))
                if strcmp(varinfo{1,1}{ii,1}, 'frequency')
                    netcdf.putAtt(ncid, varid, 'min', single(min(data.frequency(data.frequency>-9999)))); 
                elseif strcmp(varinfo{1,1}{ii,1},'lat') | strcmp(varinfo{1,1}{ii,1},'lon')
                    netcdf.putAtt(ncid, varid, attnames{j},double(attinfo{1,j}(ii)));          
                else
                    netcdf.putAtt(ncid, varid, attnames{j},single(attinfo{1,j}(ii)));                           
                end
            end
        elseif strcmp(attnames{j},'valid_max')       
            if ~isnan(attinfo{1,j}(ii))
                if strcmp(varinfo{1,1}{ii,1}, 'frequency')
                    netcdf.putAtt(ncid, varid, 'max', single(max(data.frequency(data.frequency>-9999)))); 
                elseif strcmp(varinfo{1,1}{ii,1},'lat') | strcmp(varinfo{1,1}{ii,1},'lon')
                    netcdf.putAtt(ncid, varid, attnames{j},double(attinfo{1,j}(ii)));          
                else
                    netcdf.putAtt(ncid, varid, attnames{j},single(attinfo{1,j}(ii)));                               
                end
            end
        elseif strcmp(attnames{j},'comment')
            if ~strcmp(attinfo{1,j}{ii},char(13))
                netcdf.putAtt(ncid,varid, attnames{j}, attinfo{1,j}{ii}); 
            end   
        else
            if ~isempty(attinfo{1,j}{ii})                
                netcdf.putAtt(ncid, varid, attnames{j},attinfo{1,j}{ii});
            end
        end
    end
    
    %put data to variable
    if strcmp(varinfo{1,1}{ii,1},'time')
        
        imos_time = data.time - datenum(1950,1,1,0,0,0); 
        netcdf.putVar(ncid, varid, imos_time); 
    elseif strcmp(varinfo{1,1}{ii,1},'lat') | strcmp(varinfo{1,1}{ii,1},'lon')
        if isfield(data, varinfo{1,1}{ii,1})
            netcdf.putVar(ncid, varid, data.(varinfo{1,1}{ii,1}));  
        end
    else
        if isfield(data, varinfo{1,1}{ii,1})
            netcdf.putVar(ncid, varid, single(data.(varinfo{1,1}{ii,1}))); 
        end
    end
    
end
netcdf.close(ncid);
end




  
