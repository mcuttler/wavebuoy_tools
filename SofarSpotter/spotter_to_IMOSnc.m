%% IMOS-compliant netCDF
% 
% filenameNC = 'E:\Active_Projects\LOWE_IMOS_WaveBuoys\Data\SofarSpotter\CodeTesting\Output_testing\test2.nc'; 
% globfile = 'D:\CUTTLER_GitHub\wavebuoy_tools\SofarSpotter\glob_att_Spotter_timeSeries.txt'; 
% 
% varsfile = 'D:\CUTTLER_GitHub\wavebuoy_tools\SofarSpotter\spotter_wave_parameters_mapping.csv';
% spot_info.SpotterID = 'SPOT0171'; 
% spot_info.DeployLoc = 'Testing';
% idx_bulk = [1:50]; 
%%

function [] = spotter_to_IMOSnc(bulkparams, idx_bulk, filenameNC, globfile, varsfile); 


%create output netCDF4 file     
ncid = netcdf.create(filenameNC,'NETCDF4'); 
netcdf.close(ncid); 

% global attributes

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
end


% define dimensions 

dimname = 'TIME';
dimlength = size(bulkparams.time(idx_bulk),1);

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
    if strcmp(varinfo{1,1}{ii,1},'temp')
        %modify this for spotter v2
        netcdf.putVar(ncid, varid, ones(size(bulkparams.time(idx_bulk))).*nan); 
    else
        netcdf.putVar(ncid, varid, bulkparams.(varinfo{1,1}{ii,1})(idx_bulk));
    end

end
    
netcdf.close(ncid); 

% check that it all worked 

ncdisp(filenameNC)
end




  
