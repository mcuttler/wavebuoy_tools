%% IMOS-compliant netCDF

% Create an IMOS-compliant netCDF file for displacements parameters from Sofar Spotter
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
% 

%%

function [] = displacements_to_IMOS_nc(displacements, outpathNC, buoy_info, globfile, varsfile); 


if strcmp(buoy_info.type,'sofar')==1
    outpathNC = [outpathNC '\SofarSpotter\ProcessedData_DelayedMode\nc'];     
elseif strcmp(buoy_info.type,'datawell')==1
     outpathNC = [outpathNC '\Datawell\ProcessedData_DelayedMode\nc'];         
end

if ~exist(outpathNC)
    mkdir(outpathNC)
end
        
%determine min and max months
t = datevec(displacements.time); 
tdata = unique(t(:,1:2),'rows'); 

for i = 1:size(tdata,1)
 
    tstart = datenum(tdata(i,1), tdata(i,2),1); 
    tend = datenum(tdata(i,1), tdata(i,2)+1, 1); 
    
    disp(['Saving displacements ' datestr(tstart,'mmm yyyy')]); 
    
    %output for displacements PARAMETERS     
    idx_disp = []; 
    idx_disp = find(displacements.time>=tstart&displacements.time<tend); 
    
    filenameNC = [outpathNC '\' buoy_info.name '_' buoy_info.DeployLoc '_' datestr(tstart,'yyyymm') '_disp.nc'];             
    
            
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
        
        netcdf.putAtt(ncid,varid, attname, attvalue);  
        
        if ii == size(globatts{1,1},1);
            netcdf.putAtt(ncid,varid, 'deployment_depth', '-30 m'); 
            netcdf.putAtt(ncid,varid, 'deployment_latitude', buoy_info.DeployLat); 
            netcdf.putAtt(ncid,varid, 'deployment_longitude', buoy_info.DeployLon); 
            
            if strcmp(buoy_info.name, 'sofar')
                netcdf.putAtt(ncid,varid, 'instrument_maker', 'Sofar Spotter'); 
            elseif strcmp(buoy_info.name, 'datawell')
                netcdf.putAtt(ncid,varid, 'instrument_maker', 'Datawell');  
            end
            netcdf.putAtt(ncid,varid, 'deployment_longitude', buoy_info.version);
            
        end
                
    end
    
    
    %%
    % define dimensions 
    
    dimname = 'TIME';
    dimlength = size(displacements.time(idx_disp),1);
    
    dimid_TIME = netcdf.defDim(ncid, dimname, dimlength); 
    
    % write variables 
    
    %parameter mapping file organised as: 
    % [original name, varname, standard name, long name, units, comments, ancillary invo, valid min, valid max, reference, positive]
    
    fid = fopen(varsfile); 
    varinfo = textscan(fid, '%s%s%s%s%s%s%s%f%f%s%s','delimiter',',','headerlines',1); 
    fclose(fid);      
    
    attnames = {'standard_name', 'long_name', 'units', 'comments', 'ancillary_variables', 'valid_min', 'valid_max', 'reference', 'positive'}; 
    attinfo = varinfo(3:end); 
    
    [m,~] = size(varinfo{1,1}); 
    for ii = 1:m    
        %create and define variable and attributes      
        netcdf.defVar(ncid, varinfo{1,2}{ii,1}, 'double', dimid_TIME); 
        
        varid = netcdf.inqVarID(ncid,varinfo{1,2}{ii});   
        
        %add attributes
        for j = 1:length(attinfo); 
            if j==6|j==7
                if ~isnan(attinfo{1,j}(ii))
                    netcdf.putAtt(ncid, varid, attnames{j},attinfo{1,j}(ii));
                end
            else
                if ~isempty(attinfo{1,j}{ii})
                    netcdf.putAtt(ncid, varid, attnames{j},attinfo{1,j}{ii});
                end
            end
        end
        
        %put data to variable
        if strcmp(varinfo{1,1}{ii,1},'time')
            imos_time = displacements.time(idx_disp) - datenum(1950,1,1,0,0,0); 
            netcdf.putVar(ncid, varid, imos_time); 
        else
            netcdf.putVar(ncid, varid, displacements.(varinfo{1,1}{ii,1})(idx_disp));
        end
        
    end
    
    netcdf.close(ncid);    
end
end




  
