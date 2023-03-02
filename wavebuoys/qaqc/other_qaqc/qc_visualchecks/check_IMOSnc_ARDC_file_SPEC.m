%% Check IMOS-compliant netCDF file

close all
clear all
clc

%% read netCDF file
%set file path (wherever file downloaded to)
filepath = 'E:\wawaves\KingGeorgeSound\delayedmode\ProcessedData_DelayedMode\dep04_b';
%IMOS file name
filename = 'UWA_20221109_King-George-Sound_DM_WAVE-SPECTRA_20230129.nc';

ncfile = fullfile(filepath, filename); 

% file info

finfo = ncinfo(ncfile);
%% read in variables

data.TIME = ncread(ncfile,'TIME')+datenum(1950,1,1); 
data.LONGITUDE = ncread(ncfile,'LONGITUDE');
data.LATITUDE = ncread(ncfile,'LATITUDE');
data.FREQUENCY = ncread(ncfile,'FREQUENCY');
data.A1 = ncread(ncfile,'A1'); 
data.A2 = ncread(ncfile,'A2'); 
data.B1 = ncread(ncfile,'B1'); 
data.B2 = ncread(ncfile,'B2'); 
data.ENERGY = ncread(ncfile,'ENERGY'); 


%% plots
% Position plots for the deployment


figure()
subplot(2,1,1)
plot(data.TIME,data.LONGITUDE);
title('longitude');
datetick

subplot(2,1,2)
plot(data.TIME,data.LATITUDE);
title('latitude')
datetick


figure()

scatter(data.LONGITUDE,data.LATITUDE,'r');
xlim([mean(data.LONGITUDE,'omitnan')-60 mean(data.LONGITUDE,'omitnan')+60]);
ylim([mean(data.LATITUDE,'omitnan')-60 mean(data.LATITUDE,'omitnan')+60]);
hold on
C = load('coastlines');
plot(C.coastlon,C.coastlat,'k')


figure()

scatter(data.LONGITUDE,data.LATITUDE,'r');
xlim([mean(data.LONGITUDE,'omitnan')-0.1 mean(data.LONGITUDE,'omitnan')+0.1]);
ylim([mean(data.LATITUDE,'omitnan')-0.1 mean(data.LATITUDE,'omitnan')+0.1]);
hold on
C = load('coastlines');
plot(C.coastlon,C.coastlat,'k')

return

%Plot all Displacements

figure()
subplot(3,1,1)
plot(data.TIME,data.ZDIS)
datetick
title('ZDIS')


subplot(3,1,2)
plot(data.TIME,data.XDIS)
datetick
title('XDIS')


subplot(3,1,3)
plot(data.TIME,data.YDIS)
datetick
title('YDIS')
