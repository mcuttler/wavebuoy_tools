%% Check IMOS-compliant netCDF file

close all
clear all
clc

%% read netCDF file
%set file path (wherever file downloaded to)
filepath = 'E:\wawaves\Hilarys\delayedmode\ProcessedData_DelayedMode\dep01';
%IMOS file name
filename = 'UWA_20180322_HILARYS_DM_WAVE-RAW-DISPLACEMENTS_20180405.nc';

ncfile = fullfile(filepath, filename); 

% file info

finfo = ncinfo(ncfile);
%% read in variables

data.TIME = ncread(ncfile,'TIME')+datenum(1950,1,1); 
data.TIME_LOCATION = ncread(ncfile,'TIME_LOCATION')+datenum(1950,1,1); 
data.LONGITUDE = ncread(ncfile,'LONGITUDE');
data.LATITUDE = ncread(ncfile,'LATITUDE');
data.XDIS = ncread(ncfile,'XDIS'); 
data.YDIS = ncread(ncfile,'YDIS'); 
data.ZDIS = ncread(ncfile,'ZDIS'); 


%% plots
% Position plots for the deployment

figure()
subplot(2,1,1)
plot(data.TIME_LOCATION,data.LONGITUDE);
title('longitude');
datetick

subplot(2,1,2)
plot(data.TIME_LOCATION,data.LATITUDE);
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
