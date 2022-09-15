%% IMOS-compliant netCDF

function [] = bulkparams_to_IMOS_ARDC_nc(data, buoy_info, globfile, varsfile); 


if ~exist(buoy_info.archive_path)
    mkdir(buoy_info.archive_path)
end        

disp(['Saving bulkparams']);  

filenameNC = make_imos_ardc_filename(buoy_info,'WAVE-PARAMETERS');         

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
        netcdf.putAtt(ncid,varid, attname, buoy_info.buoy_specification_url); 
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

dimname = 'TEMP_TIME';
dimlength = size(data.temp_time,1);
dimid_TEMP_TIME = netcdf.defDim(ncid, dimname, dimlength);   

dimname = 'timeSeries';
dimlength = 1;
dimid_timeSeries = netcdf.defDim(ncid, dimname, dimlength); 

% write variables     
fid = fopen(varsfile); 
varinfo = textscan(fid, '%s%s%s%s%s%s%s%s%f%f%s%s%s%s%s%s%s%s%s%s','delimiter',',','headerlines',1,'EndOfLine','\n'); 
fclose(fid);      

%get rid of temperature variables and attributes if not V2 buoy
if strcmp(buoy_info.instrument, 'Sofar Spotter-V1')
    %build mask
    tmask = [];
    for ii = 1:size(varinfo{1},1)
        if ~strcmp(varinfo{1}{ii},'surf_temp') & ~strcmp(varinfo{1}{ii}, 'qc_flag_temp') & ~strcmp(varinfo{1}{ii},'qc_subflag_temp')
            tmask = [tmask; ii]; 
        end
    end
    %now remove temp    
    for ii = 1:size(varinfo,2)
        for jj = 1:size(tmask,1)
            try
                dvarinfo{ii}{jj,1} = varinfo{ii}{tmask(jj)}; 
            catch
                dvarinfo{ii}(jj,1) = varinfo{ii}(tmask(jj));
            end
        end
    end
    varinfo = dvarinfo; clear dvarinfo;
end

attnames = {'standard_name', 'long_name', 'units', 'axis', 'calendar', 'sampling_period_timestamp_location', 'valid_min', 'valid_max', 'reference_datum',...
    'positive','observation_type','coordinates','method','ancillary_variables','flag_values','flag_meanings','quality_control_convention','comment'}; 

attinfo = varinfo(3:end);     

[m,~] = size(varinfo{1,1}); 
for ii = 1:m        
    %add timeSeries variable in 
    if ii == 1
        netcdf.defVar(ncid, 'timeSeries', 'NC_INT',dimid_timeSeries);
        varid = netcdf.inqVarID(ncid, 'timeSeries');
        netcdf.defVarFill(ncid,varid,false,int32(-9999)); 
        netcdf.putAtt(ncid, varid, 'long_name','Unique identifier for each feature instance'); 
        netcdf.putAtt(ncid, varid, 'cf_role','timeseries_id');         
        netcdf.putVar(ncid, varid, int32(1)); 
        
    end

    %create and define variable and attributes    
    if strcmp(varinfo{1,2}{ii,1},'WAVE_quality_control') | strcmp(varinfo{1,2}{ii,1},'TEMP_quality_control') 
        netcdf.defVar(ncid, varinfo{1,2}{ii,1}, 'NC_BYTE', dimid_TIME);        
        varid = netcdf.inqVarID(ncid,varinfo{1,2}{ii});  
        netcdf.defVarFill(ncid,varid,false,int8(-127));
    else
        netcdf.defVar(ncid, varinfo{1,2}{ii,1}, 'NC_DOUBLE', dimid_TIME);
        varid = netcdf.inqVarID(ncid,varinfo{1,2}{ii});  
        netcdf.defVarFill(ncid,varid,false,-9999);
    end    
    
    %add attributes
    for j = 1:length(attinfo); 
        if strcmp(attnames{j},'valid_min') | strcmp(attnames{j},'valid_max')            
            if ~isnan(attinfo{1,j}(ii))                                 
                if strcmp(varinfo{1,2}{ii,1},'WAVE_quality_control') | strcmp(varinfo{1,2}{ii,1},'TEMP_quality_control') 
                    netcdf.putAtt(ncid, varid, attnames{j},int8(attinfo{1,j}(ii))); 
                else
                    netcdf.putAtt(ncid, varid, attnames{j},attinfo{1,j}(ii)); 
                end
            end
        elseif strcmp(attnames{j},'flag_values')
            if ~isempty(attinfo{1,j}{ii})
                netcdf.putAtt(ncid, varid, attnames{j},int8(str2num(attinfo{1,j}{ii}))); 
            end
        else
            if ~isempty(attinfo{1,j}{ii})
                if strcmp(attnames{j},'magnetic_dec')
                    netcdf.putAtt(ncid, varid, attnames{j}, buoy_info.MagDec)
                elseif strcmp(attnames{j},'quality_control_conventions')
                    if length(attinfo{1,j}{ii})>1
                        netcdf.putAtt(ncid, varid, attnames{j},attinfo{1,j}{ii});
                    end
                else
                    netcdf.putAtt(ncid, varid, attnames{j},attinfo{1,j}{ii});
                end
            end
        end
    end
    
    %put data to variable
%     if strcmp(varinfo{1,1}{ii,1},'temp')
%         %modify this for spotter v2, datawell 
%         netcdf.putVar(ncid, varid, ones(size(bulkparams.time,1),1).*nan); 
    if strcmp(varinfo{1,1}{ii,1},'time')
        imos_time = data.time - datenum(1950,1,1,0,0,0); 
        netcdf.putVar(ncid, varid, imos_time); 
    elseif strcmp(varinfo{1,1}{ii,1},'qc_flag_wave') | strcmp(varinfo{1,1}{ii,1},'qc_subflag_wave')| strcmp(varinfo{1,1}{ii,1},'qc_flag_temp') | strcmp(varinfo{1,1}{ii,1},'qc_subflag_temp')
        if isfield(data, varinfo{1,1}{ii,1})
            netcdf.putVar(ncid, varid, int8(data.(varinfo{1,1}{ii,1})));  
        end
    else
        if isfield(data, varinfo{1,1}{ii,1})
            netcdf.putVar(ncid, varid, data.(varinfo{1,1}{ii,1})); 
        end
    end
    
end
netcdf.close(ncid);
end





  
