%% Check IMOS-compliant netCDF file

close all
clear all
clc

%% read netCDF file
%set file path (wherever file downloaded to)
filepath = 'F:\wawaves\CapeBridgewater\delayedmode\ProcessedData_DelayedMode\dep05';
%IMOS file name
filename = 'VIC-DEAKIN-UNI_20230510_CAPE-BRIDGEWATER_DM_WAVE-SPECTRA_20231205.nc';

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

%Plots 
% plot first and last ENERGY Spectra to see time start and time end

figure()
subplot(2,1,1)
plot(data.FREQUENCY,data.ENERGY(1,:))
hold on
plot(data.FREQUENCY,data.ENERGY(2,:))
plot(data.FREQUENCY,data.ENERGY(3,:))
plot(data.FREQUENCY,data.ENERGY(4,:))
title (datestr(data.TIME(1)));

subplot(2,1,2)
plot(data.FREQUENCY,data.ENERGY(end-3,:))
hold on
plot(data.FREQUENCY,data.ENERGY(end-2,:))
plot(data.FREQUENCY,data.ENERGY(end-1,:))
plot(data.FREQUENCY,data.ENERGY(end,:))
title (datestr(data.TIME(end)));


% plot two other interior specs, at 1/3 and 2/3 of record
figure()
subplot(2,1,1)
plot(data.FREQUENCY,data.ENERGY(floor(length(data.TIME)/3),:))
hold on
plot(data.FREQUENCY,data.ENERGY(floor(length(data.TIME)/3)+1,:))
plot(data.FREQUENCY,data.ENERGY(floor(length(data.TIME)/3)+2,:))
plot(data.FREQUENCY,data.ENERGY(floor(length(data.TIME)/3)+3,:))
title (datestr(data.TIME(floor(length(data.TIME)/3))));

subplot(2,1,2)
plot(data.FREQUENCY,data.ENERGY(floor(length(data.TIME)*2/3),:))
hold on
plot(data.FREQUENCY,data.ENERGY(floor(length(data.TIME)*2/3)+1,:))
plot(data.FREQUENCY,data.ENERGY(floor(length(data.TIME)*2/3)+2,:))
plot(data.FREQUENCY,data.ENERGY(floor(length(data.TIME)*2/3)+3,:))
title (datestr(data.TIME(floor(length(data.TIME)*2/3))));

%Plot Spectograms for Szz (Energy) 
figure()
imagesc(data.TIME,data.FREQUENCY,data.ENERGY');
set(gca,'YDIR','normal');
caxis([nanmean(nanmean(data.ENERGY))-0.07 nanmean(nanmean(data.ENERGY))+10])
ylim([0 0.4]);
datetick
ylabel('frequency');



%polar plot spectrum
return

[NS, NE, ndirec] = lygre_krogstad(data.A1,data.A2,data.B1,data.B2,data.ENERGY);

