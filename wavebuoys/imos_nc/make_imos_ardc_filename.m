%% Make netCDF file name following IMOS-ARDC conventions
% Filenaming convention for ARDC Wave data files 
% The NetCDF file name format is:% 
% <Institution>_<Start-Date>_<Site-Name>_<Data-Mode>_<Product-Type>_<End-Date>.nc
% 
% Details about each item exaplained below:% 
% 1. Institution 
% - Use acronyms
% - When composed words, use a dash between words
% - Examples for the ARDC-wave partners: NSW-DPE; UWA; VIC; PPA 
% 2. Start date 
% - Use the short version that does not include time (YYYYMMDD) and the date should be in UTC
% - The start is when the instrument was deployed (for integral parameters and spectral files) and when the data starts in that specific file (for raw displacements, since they are monthly files).
% - Example: 20220505 
% 3. Site name 
% - If composed word, separate words with a dash
% - Example: MAROUBRA; GOODRICH-BANK; MARIA-ISLAND 
% 4. Data mode 
% The options are:
% - delayed mode (DM) or
% - realtime (RT)
% Please use the acronym. 
% 5. Product type 
% Instead of using timeseries as we did previously for NTP data files, we will now adopt the following codes for the three different data types:
% * WAVE-PARAMETERS
% * WAVE-SPECTRA
% * WAVE-RAW-DISPLACEMENTS 
% 6. End date
% 
% - Same as start date but add END in front (END-YYMMDD). Use UTC.
% - Example: END-20220605
% 
% 
% Examples of the complete filename:
% 
% NSW-DPE_20220503_MAROUBRA_DM_WAVE-PARAMETERS_END-20220601.nc
% UWA_20220115_GOODRICH-BANK01_DM_WAVE-SPECTRA_END-20220215.nc
% VIC_20210801_DUTTON-WAY_DM_WAVE-RAW-DISPLACEMENT_END-20211231.nc
% Comments: 
% - no need to include the make/model of the buoy in the filename, for example Spotter/Datawell
% - no need to include data code like W (wave) or T (temp)
% - no need to include file version (FV00, FV01)
% Filenaming convention for ARDC Wave data files
% 
% 
% The NetCDF file name format is:
% 
% <Institution>_<Start-Date>_<Site-Name>_<Data-Mode>_<Product-Type>_<End-Date>.nc
% 
% Details about each item exaplained below:
% 
% 1. Institution
% 
% - Use acronyms
% - When composed words, use a dash between words
% - Examples for the ARDC-wave partners: NSW-DPE; UWA; VIC; PPA
% 
% 2. Start date
% 
% - Use the short version that does not include time (YYYYMMDD) and the date should be in UTC
% - The start is when the instrument was deployed (for integral parameters and spectral files) and when the data starts in that specific file (for raw displacements, since they are monthly files).
% - Example: 20220505
% 
% 3. Site name
% 
% - If composed word, separate words with a dash
% - Example: MAROUBRA; GOODRICH-BANK; MARIA-ISLAND
% 
% 4. Data mode
% 
% The options are:
% - delayed mode (DM) or
% - realtime (RT)
% Please use the acronym.
% 
% 5. Product type
% 
% Instead of using timeseries as we did previously for NTP data files, we will now adopt the following codes for the three different data types:
% * WAVE-PARAMETERS
% * WAVE-SPECTRA
% * WAVE-RAW-DISPLACEMENTS
% 
% 6. End date
% 
% - Same as start date but add END in front (END-YYMMDD). Use UTC.
% - Example: END-20220605
% 
% 
% Examples of the complete filename:
% 
% NSW-DPE_20220503_MAROUBRA_DM_WAVE-PARAMETERS_END-20220601.nc
% UWA_20220115_GOODRICH-BANK01_DM_WAVE-SPECTRA_END-20220215.nc
% VIC_20210801_DUTTON-WAY_DM_WAVE-RAW-DISPLACEMENT_END-20211231.nc
% Comments: 
% - no need to include the make/model of the buoy in the filename, for example Spotter/Datawell
% - no need to include data code like W (wave) or T (temp)
% - no need to include file version (FV00, FV01)

%MCuttler UWA 2022

%%

function [imos_filename] = make_imos_ardc_filename(buoy_info,product_type)

%build file name
filename = [buoy_info.institution '_' datestr(buoy_info.startdate,'yyyymmdd') '_' buoy_info.site_name '_' buoy_info.data_mode '_' product_type '_' datestr(buoy_info.enddate,'yyyymmdd') '.nc']; 
imos_filename = fullfile(buoy_info.archive_path, filename); 

end


