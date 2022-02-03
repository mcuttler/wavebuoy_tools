%% Check IMOS-compliant netCDF file

close all
clear all
clc

%% read netCDF file
%set file path (wherever file downloaded to)
filepath = 'C:\Users\00104893\LocalDocuments\Projects\Wave buoys\IMOS AODN\LOWE_IMOS_WaveBuoys\Data\SofarSpotter\ProcessedData_DelayedMode\nc\CapeBridgewater01';
%IMOS file name
filename = 'IMOS_NTP-WAVE_TW_20200820T171107Z_CAPEBW01_WAVERIDER_FV01_timeseries_END-20210624T034220Z.nc';

ncfile = fullfile(filepath, filename); 

%% read in some variables

data.time = ncread(ncfile,'TIME')+datenum(1950,1,1); 
data.hs = ncread(ncfile,'WSSH'); 
data.tp = ncread(ncfile,'WPPE');
data.tm = ncread(ncfile,'WPFM'); 
data.dp = ncread(ncfile,'WPDI'); 
data.dm = ncread(ncfile,'SSWMD');
data.pkspr = ncread(ncfile,'WPDS'); 
data.meanspr = ncread(ncfile,'WMDS'); 
data.quality_flag = ncread(ncfile,'wave_quality_flag'); 
data.quality_subflag = ncread(ncfile,'wave_subflag'); 

data.lon = ncread(ncfile,'LONGITUDE');
data.lat = ncread(ncfile,'LATITUDE');


%% plot Hs, Tp, Dp and 'bad' data

%raw data figure
fid = figure; 
ax(1) = subplot(3,1,1); 
h(1) = plot(data.time, data.hs);
hold on; grid on;
datetick('x','dd-mmm'); 
text(0.05, 0.95,'(a)','units','normalized'); 
ylabel('Hs (m)'); 
xlabel('Date'); 

ax(2) = subplot(3,1,2); 
plot(data.time, data.tp); 
hold on; grid on; 
datetick('x','dd-mmm');
xlabel('Date'); 
ylabel('Tp (s)'); 


ax(3) = subplot(3,1,3); 
plot(data.time, data.dp); 
hold on; grid on; 
datetick('x','dd-mmm');
xlabel('Date'); 
ylabel('Dp (deg from)'); 

set(fid, 'PaperPositionMode', 'manual','PaperUnits','centimeters','units','centimeters',...
'position',[1 1 24 18], 'PaperPosition', [0 0 24 18])
%%

fid = figure;
ax(1) = subplot(3,1,1); 
h(1) = plot(data.time, data.hs);
hold on; grid on;
h(2) = plot(data.time(data.quality_flag==3), data.hs(data.quality_flag==3),'co'); 
h(3) = plot(data.time(data.quality_flag==4), data.hs(data.quality_flag==4),'ro'); 
datetick('x','dd-mmm'); 
text(0.05, 0.95,'(a)','units','normalized'); 
ylabel('Hs (m)'); 
xlabel('Date'); 
l = legend(h,{'Data','Suspect','Fail'}); 
%     'Flagged Data (' num2str(round(length(find(data.quality_flag>1))./length(data.quality_flag)*100,2)) '%)']}); 

ax(2) = subplot(3,1,2); 
plot(data.time, data.tp); 
hold on; grid on; 
plot(data.time(data.quality_flag==3), data.tp(data.quality_flag==3),'co'); 
plot(data.time(data.quality_flag==4), data.tp(data.quality_flag==4),'ro'); 
datetick('x','dd-mmm');
xlabel('Date'); 
ylabel('Tp (s)'); 


ax(3) = subplot(3,1,3); 
plot(data.time, data.dp); 
hold on; grid on; 
plot(data.time(data.quality_flag==3), data.dp(data.quality_flag==3),'co'); 
plot(data.time(data.quality_flag==4), data.dp(data.quality_flag==4),'ro'); 
datetick('x','dd-mmm');
xlabel('Date'); 
ylabel('Dp (deg from)'); 

set(fid, 'PaperPositionMode', 'manual','PaperUnits','centimeters','units','centimeters',...
'position',[1 1 24 18], 'PaperPosition', [0 0 24 18])

% %% check sources of flags
% [flag_source] =  qaqc_error_source(data.quality_subflag);

%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%

return
%additional plots 

finfo = ncinfo(ncfile);


%temp data
data.TEMP = ncread(ncfile,'TEMP'); 
data.TEMP_quality_flag = ncread(ncfile,'TEMP_quality_flag'); 
data.TEMP_subflag = ncread(ncfile,'TEMP_subflag'); 

figure()
subplot(3,1,1)
scatter((1:length(data.time)),data.TEMP)
title('TEMP')

xlim([0 length(data.time)])
subplot(3,1,2)

scatter((1:length(data.time)),data.TEMP_quality_flag)
title('TEMP quality flag')
xlim([0 length(data.time)])
subplot(3,1,3)

scatter((1:length(data.time)),data.TEMP_subflag)
title('TEMP subflag')
xlim([0 length(data.time)])

% percentage of 4 and 3 flags

flag_per.bad = length(find(data.quality_flag==4))/length(data.quality_flag);
flag_per.suspect = length(find(data.quality_flag==3))/length(data.quality_flag);

disp('fraction of data with flag 4')
disp(num2str(flag_per.bad))
disp('fraction of data with flag 3')
disp(num2str(flag_per.suspect))




%plot positions

figure()
subplot(2,1,1)
plot(data.time,data.lon);
title('longitude');
subplot(2,1,2)
plot(data.time,data.lat);
title('latitude')


figure()

scatter(data.lon,data.lat,'r');
xlim([mean(data.lon,'omitnan')-60 mean(data.lon,'omitnan')+60]);
ylim([mean(data.lat,'omitnan')-60 mean(data.lat,'omitnan')+60]);
hold on
C = load('coastlines');
plot(C.coastlon,C.coastlat,'k')


figure()

scatter(data.lon,data.lat,'r');
xlim([mean(data.lon,'omitnan')-0.1 mean(data.lon,'omitnan')+0.1]);
ylim([mean(data.lat,'omitnan')-0.1 mean(data.lat,'omitnan')+0.1]);
hold on
C = load('coastlines');
plot(C.coastlon,C.coastlat,'k')

% plot subflag values

fid = figure; 
ax(1) = subplot(2,1,1); 
h(1) = scatter(data.time, data.quality_flag);
hold on; grid on;
datetick('x','dd-mmm'); 
text(0.05, 0.95,'(a)','units','normalized'); 
ylabel('Quality Flag (m)'); 
xlabel('Date'); 

ax(2) = subplot(2,1,2); 
scatter(data.time, data.quality_subflag); 
hold on; grid on; 
datetick('x','dd-mmm');
xlabel('Date'); 
ylabel('Subflag'); 


%Plot data and flag values against index, not time

fid = figure;
ax(1) = subplot(3,1,1); 
h(1) = plot(data.hs);
hold on; grid on;
h(2) = scatter(find(data.quality_flag==3),data.hs(data.quality_flag==3),'co'); 
h(3) = scatter(find(data.quality_flag==4),data.hs(data.quality_flag==4),'ro'); 
text(0.05, 0.95,'(a)','units','normalized'); 
ylabel('Hs (m)'); 
l = legend(h,{'Data','Suspect','Fail'}); 
%     'Flagged Data (' num2str(round(length(find(data.quality_flag>1))./length(data.quality_flag)*100,2)) '%)']}); 

ax(2) = subplot(3,1,2); 
plot(data.tp); 
hold on; grid on; 
scatter(find(data.quality_flag==3),data.tp(data.quality_flag==3),'co'); 
scatter(find(data.quality_flag==4),data.tp(data.quality_flag==4),'ro'); 
ylabel('Tp (s)'); 


ax(3) = subplot(3,1,3); 
plot(data.dp); 
hold on; grid on; 
scatter(find(data.quality_flag==3),data.dp(data.quality_flag==3),'co'); 
scatter(find(data.quality_flag==4),data.dp(data.quality_flag==4),'ro'); 
ylabel('Dp (deg from)'); 

set(fid, 'PaperPositionMode', 'manual','PaperUnits','centimeters','units','centimeters',...
'position',[1 1 24 18], 'PaperPosition', [0 0 24 18])

% flag and subflag against index
fid = figure; 
ax(1) = subplot(2,1,1); 
h(1) = scatter((1:length(data.time)), data.quality_flag);
hold on; grid on;
text(0.05, 0.95,'(a)','units','normalized'); 
ylabel('Quality Flag'); 


ax(2) = subplot(2,1,2); 
scatter((1:length(data.time)), data.quality_subflag); 
hold on; grid on; 
ylabel('Subflag'); 


