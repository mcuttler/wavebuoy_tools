%% netCDF checker

%Run this code after processing a wave buoy memory card to check final
%results. 
%Use figures in this code to update the buoy_info metadata CSV that was
%used for netCDF generation and update as needed to re-run 

%2025-03: 
%   - file creation - MC

%% read nc files 

dpath = 'X:\CUTTLER_wawaves\Data\wawaves\OceanBeach\delayedmode\ProcessedData_DelayedMode'; 
nc_int =  'UWA_20240701_OCEAN-BEACH_DM_WAVE-PARAMETERS_20240702.nc'; 
nc_spec = 'UWA_20240701_OCEAN-BEACH_DM_WAVE-SPECTRA_20240702.nc'; 
nc_disp = 'UWA_20240701_OCEAN-BEACH_DM_WAVE-RAW-DISPLACEMENTS_20240702.nc'; 


info = ncinfo(fullfile(dpath,nc_int)); 
for i = 1:length(info.Variables)
    bulkparams.(info.Variables(i).Name) = ncread(fullfile(dpath,nc_int),info.Variables(i).Name); 
end


info = ncinfo(fullfile(dpath,nc_spec)); 
for i = 1:length(info.Variables)
    spec.(info.Variables(i).Name) = ncread(fullfile(dpath,nc_spec),info.Variables(i).Name); 
end

info = ncinfo(fullfile(dpath,nc_disp)); 
for i = 1:length(info.Variables)
    spec.(info.Variables(i).Name) = ncread(fullfile(dpath,nc_disp),info.Variables(i).Name); 
end

%% make bulk params figures

fid = figure; 
ax(1) = subplot(421);
plot(bulkparams.TIME, bulkaprams.WSSH); 
hold on
plot(bulkparams.TIME(bulkparams.WAVE_quality_control>1), bulkparams.WSSH(bulkparams.WAVE_quality_control>1),'ro'); 

ax(2) = subplot(422);
plot(bulkparams.TIME, bulkaprams.WSSH); 
hold on
plot(bulkparams.TIME(bulkparams.WAVE_quality_control>1), bulkparams.WSSH(bulkparams.WAVE_quality_control>1),'ro'); 

ax(3) = subplot(423);
plot(bulkparams.TIME, bulkaprams.WSSH); 
hold on
plot(bulkparams.TIME(bulkparams.WAVE_quality_control>1), bulkparams.WSSH(bulkparams.WAVE_quality_control>1),'ro'); 








%% MH old stuff 
% plot time vectors to make sure they are sequential
% 
% figure()
% subplot(2,1,1)
% plot(data.time,'-o')
% title ('data time')
% subplot(2,1,2)
% plot(data.disp_time,'-o')
% title('disp time')

%encountered one file where time took a step backward at end of file (Cape
%Bridgewater dep05) need to remove in that case.

%ind_end_time=10070;
%ind_end_disp_time=45320000;

%for i =27:30
%    data.(fields{i}) =   data.(fields{i})(1:ind_end_time);
%end 

%for i =14:17
%   data.(fields{i}) =   data.(fields{i})(1:ind_end_disp_time);
%end

%for i =19:25
%   data.(fields{i}) =   data.(fields{i})(1:ind_end_time,:);
%end 

% Graphical input on Lat and Lon data to find Start of Stop Time of Deployment Click on Start time and then Stop time
% Disable if confident in start and end time recorded metadata.

% figure();
% yyaxis left;
% plot(data.time,data.lat);
% 
% yyaxis right;
% plot(data.time,data.lon);
% 
% %--------------------------------------------------------------------------
% figure();
% yyaxis left;
% plot(data.time,data.lat);
% 
% yyaxis right;
% plot(data.time,data.lon);
% 
% xlim([(data.time(1)-5) data.time(floor(length(data.time)/8))]);
% 
% [xinp1,yinp1]=ginput(1);
% 
% buoy_info.startdate= xinp1;
% clf;
% 
% yyaxis left;
% plot(data.time,data.lat);
% 
% yyaxis right;
% plot(data.time,data.lon);
% 
% xlim([data.time(end-floor(length(data.time)/10)) (data.time(end)+5)]);
% 
% [xinp2,yinp2]=ginput(1);
% 
% buoy_info.enddate= xinp2;
% 
% clearvars xinp1 yinp1 xinp2 yinp2;
% clf;
% 


%% Graphical input to calculate watch circle. Disable if confident in recorded metadata watch circle. 
%% ONLY GO VERTICALLY (i.e. choose only latitude)
%% because longitude to meteres conversion changes with latitude. source of Latitude conversion:
%% https://www.usgs.gov/faqs/how-much-distance-does-degree-minute-and-second-cover-your-maps


% figure()
% scatter(data.lon,data.lat)
% 
% [xinp,yinp] = ginput(2);
% 
% buoy_info.watch_circle = round((1/2) *(abs(yinp(2) - yinp(1))) * (1849.5/(1/60)));
% 
% clearvars xinp yinp;
% clf;
% close all;