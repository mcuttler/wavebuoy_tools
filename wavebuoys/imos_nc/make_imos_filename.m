%% make IMOS file name

%format: 
% IMOS_<Facility-Code>_<Data-Code>_<Start_Date>_<Platform-code>_FV<File-version>_<Product-Type>_<End-Date>_<Creation-date>

%example:
% IMOS_NTP-WAVE_TW_<start_date:YYYYMMDD>_TOR01_WAVERIDER_FV01_<product type>_<end_date:END-YYYYMMDD>
% 
% •	<Data-Code> = T for temperature; W for wave parameters;
% •	<Start-date> = <YYYYMMDD> or <YYYYMMDDThhmmssZ>, it is optional to include the hour or not. If you chose to include the time it would be YYYY = 4-digit year, MM = month, DD = day, hh = hour, mm = minute, ss = second, ‘T’ is the delimiter between date and time, and ‘Z’ indicates that time is in UTC. If time is not in UTC, local time must be shown as hours plus or minus from the longitudinal meridian.
% •	<Platform-Code> = site_code, for example TOR01 (and we are adding the 'platform_type' = WAVERIDER here, to follow the pattern we have in the National Wave Archive. This is not in the IMOS Convention, but it is suitable in case there are different instruments for future data).
% •	<Product-Type>, <End-date> and <Creation-date> = are optional. Product_type would be 'timeseries' in your case. I personally think it is good to have end_date, but that is my opinion. Note that it has 'END-' in front of the YYYYMMDD...

% IMOS_NTP-WAVE_TW_20210205T141750Z_TOR01_WAVERIDER_FV01_timeseries_END-20210206T090015Z.nc

function [imos_filename] = make_imos_filename(buoy_info,outpathNC,tstart, tend)

t1 = datestr(tstart,30);  t1(end+1) = 'Z'; 
t2 = datestr(tend,30);  t2(end+1) = 'Z'; 

imos_filename = [outpathNC '\IMOS_' buoy_info.facility_code '_' buoy_info.data_code '_' t1 '_' buoy_info.site_code '_'...
    buoy_info.platform_type '_FV' num2str(buoy_info.file_version,'%02d') '_' buoy_info.product_type '_END-' t2 '.nc']; 


    
end



