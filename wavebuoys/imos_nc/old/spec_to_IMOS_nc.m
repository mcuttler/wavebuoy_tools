%% IMOS-compliant netCDF

% Create an IMOS-compliant netCDF file for displacements parameters 
%     
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%     
% Code history
% 
%     Author          | Date             | Script Version     | Update
% ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
%     M. Cuttler     | 06 Oct 2020  | 1.0                     | Initial creation
% -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
% 

%%

function [] = spectral_to_IMOS_ARDC_nc(data, buoy_info, globfile, varsfile); 


if ~exist(disp_buoy_info.archive_path)
    mkdir(disp_buoy_info.archive_path)
end        

disp(['Saving displacements']);  

filenameNC = make_imos_ardc_filename(disp_buoy_info,'WAVE-RAW-DISPLACEMENTS');         

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
        netcdf.putAtt(ncid,varid, attname, disp_buoy_info.project);        
    elseif strcmp(attname, 'date_created')
        tdum = datestr(now - datenum(0,0,0,8,0,0),31); 
        tdum(11) = 'T'; tdum(end+1)='Z';
        netcdf.putAtt(ncid,varid, attname,tdum);  
    elseif strcmp(attname, 'site_name')
        netcdf.putAtt(ncid,varid, attname, disp_buoy_info.site_name);
    elseif strcmp(attname, 'instrument')
        netcdf.putAtt(ncid,varid, attname, disp_buoy_info.instrument);    
    elseif strcmp(attname,'wave_motion_sensor_type'); 
        netcdf.putAtt(ncid,varid, attname,disp_buoy_info.wave_motion_sensor_type); 
    elseif strcmp(attname,'wave_sensor_serial_number'); 
        netcdf.putAtt(ncid,varid, attname,disp_buoy_info.wave_sensor_serial_number); 
    elseif strcmp(attname,'hull_serial_number'); 
        netcdf.putAtt(ncid,varid, attname,disp_buoy_info.hull_serial_number); 
    elseif strcmp(attname,'instrument_burst_duration'); 
        netcdf.putAtt(ncid,varid, attname,disp_buoy_info.instrument_burst_duration); 
    elseif strcmp(attname,'instrument_burst_interval'); 
        netcdf.putAtt(ncid,varid, attname,disp_buoy_info.instrument_burst_interval); 
    elseif strcmp(attname,'instrument_sampling_interval'); 
        netcdf.putAtt(ncid,varid, attname,disp_buoy_info.instrument_sampling_interval);         
    elseif strcmp(attname, 'water_depth')
        netcdf.putAtt(ncid,varid, attname, disp_buoy_info.DeployDepth);
    elseif strcmp(attname, 'time_coverage_start')
        tdum = datestr(displacements.time(1),31); 
        tdum(11) = 'T'; tdum(end+1)='Z';
        netcdf.putAtt(ncid,varid, attname, tdum); 
    elseif strcmp(attname, 'time_coverage_end') 
        tdum = datestr(displacements.time(end),31); 
        tdum(11) = 'T'; tdum(end+1)='Z';
        netcdf.putAtt(ncid,varid, attname,tdum);   
    elseif strcmp(attname, 'geospatial_lat_min')        
        dlat = displacements.lat; dlat(dlat<-99)=nan;
        netcdf.putAtt(ncid,varid, attname, (nanmin(dlat))); 
    elseif strcmp(attname, 'geospatial_lon_min')
        dlon = displacements.lon; dlon(dlon<-99)=nan;
        netcdf.putAtt(ncid,varid, attname, (nanmin(dlon))); 
    elseif strcmp(attname, 'geospatial_lat_max')        
        netcdf.putAtt(ncid,varid, attname, (nanmax(dlat))); 
    elseif strcmp(attname, 'geospatial_lon_max')       
        netcdf.putAtt(ncid,varid, attname, (nanmax(dlon))); 
    elseif strcmp(attname, 'watch_circle')       
        netcdf.putAtt(ncid,varid, attname, disp_buoy_info.watch_circle); 
    else
        netcdf.putAtt(ncid,varid, attname, attvalue);
    end
    
end
netcdf.close(ncid);      
%% make dum lat/lon that are same length as displacements
displacements.lat = ones(size(displacements.time,1),1).*-9999; 
displacements.lon = ones(size(displacements.time,1),1).*-9999; 

%%
% define dimensions         

ncid = netcdf.open(filenameNC,'WRITE'); 
dimname = 'TIME';
dimlength = size(displacements.time,1);
dimid_TIME = netcdf.defDim(ncid, dimname, dimlength);     

% write variables     
fid = fopen(varsfile); 
varinfo = textscan(fid, '%s%s%s%s%s%s%s%f%f%s%s%s','delimiter',',','headerlines',1,'EndOfLine','\n'); 
fclose(fid);      

attnames = {'standard_name', 'long_name', 'units', 'axis','calendar', 'valid_min', 'valid_max', 'reference_datum',...
    'coordinates','comment'}; 

attinfo = varinfo(3:end);     

[m,~] = size(varinfo{1,1}); 
for ii = 1:m        
    %create and define variable and attributes    
    if strcmp(varinfo{1,2}{ii,1},'TIME') | strcmp(varinfo{1,2}{ii,1},'LATITUDE') | strcmp(varinfo{1,2}{ii,1},'LONGITUDE') 
        netcdf.defVar(ncid, varinfo{1,2}{ii,1}, 'NC_DOUBLE', dimid_TIME);
        varid = netcdf.inqVarID(ncid,varinfo{1,2}{ii});  
        netcdf.defVarFill(ncid,varid,false,-9999);
    else
        netcdf.defVar(ncid, varinfo{1,2}{ii,1}, 'NC_FLOAT', dimid_TIME);
        varid = netcdf.inqVarID(ncid,varinfo{1,2}{ii});  
        netcdf.defVarFill(ncid,varid,false,single(-9999)); 
    end    
    
    %add attributes
    for j = 1:length(attinfo); 
        if strcmp(attnames{j},'valid_min') | strcmp(attnames{j},'valid_max')            
            if ~isnan(attinfo{1,j}(ii))                                 
                netcdf.putAtt(ncid, varid, attnames{j},single(attinfo{1,j}(ii))); 
            end
        end    
    end
    
    %put data to variable
    if strcmp(varinfo{1,1}{ii,1},'time')
        imos_time = displacements.time - datenum(1950,1,1,0,0,0); 
        netcdf.putVar(ncid, varid, imos_time); 
    elseif strcmp(varinfo{1,1}{ii,1},'lat') | strcmp(varinfo{1,1}{ii,1},'lon')
        if isfield(displacements, varinfo{1,1}{ii,1})
            netcdf.putVar(ncid, varid, displacements.(varinfo{1,1}{ii,1}));  
        end
    else
        if isfield(displacements, varinfo{1,1}{ii,1})
            netcdf.putVar(ncid, varid, single(displacements.(varinfo{1,1}{ii,1}))); 
        end
    end
    
end
netcdf.close(ncid);
end




  
