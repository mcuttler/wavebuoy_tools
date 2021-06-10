%% IMOS-compliant netCDF

% Create an IMOS-compliant netCDF file for bulk parameters from Sofar Spotter
% Saves one netCDF per deployment (time period covered in bulkparams)

%%

function [] = bulkparams_to_IMOS_nc(bulkparams, outpathNC, buoy_info, globfile, varsfile); 


outpathNC = [outpathNC '\nc\' buoy_info.DeployLoc];

if ~exist(outpathNC)
    mkdir(outpathNC)
end        

disp(['Saving bulkparams']);  

filenameNC = make_imos_filename(buoy_info, outpathNC, bulkparams.time(1), bulkparams.time(end));         

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
        netcdf.putAtt(ncid,varid, attname, [buoy_info.site_code]);
    elseif strcmp(attname, 'site_name')
        netcdf.putAtt(ncid,varid, attname, buoy_info.DeployLoc);
    elseif strcmp(attname, 'water_depth')
        netcdf.putAtt(ncid,varid, attname, buoy_info.DeployDepth);
    elseif strcmp(attname, 'deployment_id')
        netcdf.putAtt(ncid,varid, attname, buoy_info.DeployID);
    elseif strcmp(attname, 'geospatial_lat_min')        
        dlat = bulkparams.lat; dlat(dlat<-99)=nan;
        netcdf.putAtt(ncid,varid, attname, (nanmin(dlat))); 
    elseif strcmp(attname, 'geospatial_lon_min')
        dlon = bulkparams.lon; dlon(dlon<-99)=nan;
        netcdf.putAtt(ncid,varid, attname, (nanmin(dlon))); 
    elseif strcmp(attname, 'geospatial_lat_max')        
        netcdf.putAtt(ncid,varid, attname, (nanmax(dlat))); 
    elseif strcmp(attname, 'geospatial_lon_max')       
        netcdf.putAtt(ncid,varid, attname, (nanmax(dlon))); 
    elseif strcmp(attname, 'time_coverage_start')
        tdum = datestr(bulkparams.time(1),31); 
        tdum(11) = 'T'; tdum(end+1)='Z';
        netcdf.putAtt(ncid,varid, attname, tdum); 
    elseif strcmp(attname, 'time_coverage_end') 
        tdum = datestr(bulkparams.time(end),31); 
        tdum(11) = 'T'; tdum(end+1)='Z';
        netcdf.putAtt(ncid,varid, attname,tdum);             
    elseif strcmp(attname, 'date_created')
        tdum = datestr(now - datenum(0,0,0,8,0,0),31); 
        tdum(11) = 'T'; tdum(end+1)='Z';
        netcdf.putAtt(ncid,varid, attname,tdum);   
    elseif strcmp(attname,'local_time_zone'); 
        netcdf.putAtt(ncid,varid, attname,int8(buoy_info.timezone)); 
    else
        netcdf.putAtt(ncid,varid, attname, attvalue);
    end
    
end
netcdf.close(ncid);    
%%
% define dimensions         

ncid = netcdf.open(filenameNC,'WRITE'); 
dimname = 'TIME';
dimlength = size(bulkparams.time,1);

dimid_TIME = netcdf.defDim(ncid, dimname, dimlength);     

dimname = 'station_id_strlen';
st_id_length = length(buoy_info.DeployLoc); 

dimid_str = netcdf.defDim(ncid, dimname, st_id_length); 

% write variables     

fid = fopen(varsfile); 
varinfo = textscan(fid, '%s%s%s%s%s%s%s%s%s%f%f%s%s%s%s%s%s%s%s','delimiter',',','headerlines',1,'EndOfLine','\n'); 
fclose(fid);      

%get rid of temperature variables and attributes if not V2 buoy
if strcmp(buoy_info.version, 'Spotter-V1')
    %build mask
    tmask = [];
    for ii = 1:size(varinfo{1},1)
        if ~strcmp(varinfo{1}{ii},'temp') & ~strcmp(varinfo{1}{ii}, 'qc_flag_temp') & ~strcmp(varinfo{1}{ii},'qc_subflag_temp')
            tmask = [tmask; ii]; 
        end
    end
    %now remove temp    for ii = 1:size(varinfo,2)
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

attnames = {'standard_name', 'long_name', 'units', 'calendar','axis','comments', 'ancillary_variables', 'valid_min', 'valid_max', 'reference_datum','magnetic_dec', 'positive',...
    'observation_type','coordinates','flag_values','flag_meanings','quality_control_convention'}; 

attinfo = varinfo(3:end);     



[m,~] = size(varinfo{1,1}); 
for ii = 1:m    
    %include STATION_ID 
    if ii ==1
        netcdf.defVar(ncid, 'STATION_ID','NC_CHAR',[dimid_str]); 
        varid = netcdf.inqVarID(ncid,'STATION_ID');   
        
        netcdf.putAtt(ncid, varid, 'ioos_category','Identifier');
        netcdf.putAtt(ncid, varid, 'cf_role','timeseries_id');
        netcdf.putAtt(ncid, varid, 'long_name','station name');
        
        %variable for STATION_ID     
        if length(buoy_info.DeployLoc)~=st_id_length
            buoy_info.DeployLoc(end+1:st_id_length) = ' '; 
        end
        netcdf.putVar(ncid, varid, buoy_info.DeployLoc);
    end
    
    %create and define variable and attributes
    
    if ii==1
        netcdf.defVar(ncid, varinfo{1,2}{ii,1}, 'NC_DOUBLE', dimid_TIME);
        varid = netcdf.inqVarID(ncid,varinfo{1,2}{ii});  
        %netcdf.defVarFill(ncid,varid,false,-9999);
    elseif strcmp(varinfo{1,2}{ii,1},'wave_quality_flag') | strcmp(varinfo{1,2}{ii,1},'wave_subflag') | strcmp(varinfo{1,2}{ii,1},'TEMP_quality_flag') | strcmp(varinfo{1,2}{ii,1},'TEMP_subflag')
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
                if strcmp(varinfo{1,2}{ii,1},'wave_quality_flag') | strcmp(varinfo{1,2}{ii,1},'wave_subflag') | strcmp(varinfo{1,2}{ii,1},'TEMP_quality_flag') | strcmp(varinfo{1,2}{ii,1},'TEMP_subflag')
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
    if strcmp(varinfo{1,1}{ii,1},'temp')
        %modify this for spotter v2, datawell 
        netcdf.putVar(ncid, varid, ones(size(bulkparams.time,1),1).*nan); 
    elseif strcmp(varinfo{1,1}{ii,1},'time')
        imos_time = bulkparams.time - datenum(1950,1,1,0,0,0); 
        netcdf.putVar(ncid, varid, imos_time); 
    elseif strcmp(varinfo{1,1}{ii,1},'qc_flag_wave') | strcmp(varinfo{1,1}{ii,1},'qc_subflag_wave')| strcmp(varinfo{1,1}{ii,1},'qc_flag_temp') | strcmp(varinfo{1,1}{ii,1},'qc_subflag_temp')
        if isfield(bulkparams, varinfo{1,1}{ii,1})
            netcdf.putVar(ncid, varid, int8(bulkparams.(varinfo{1,1}{ii,1})));  
        end
    else
        if isfield(bulkparams, varinfo{1,1}{ii,1})
            netcdf.putVar(ncid, varid, bulkparams.(varinfo{1,1}{ii,1})); 
        end
    end
    
end
netcdf.close(ncid);
end





  
