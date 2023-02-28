%% Check IMOS-compliant netCDF file

close all
clear all
clc

%% read netCDF file
%set file path (wherever file downloaded to)
filepath = 'C:\Users\00104893\LocalDocuments\Projects\Wave buoys\IMOS AODN\LOWE_IMOS_WaveBuoys\Data\SofarSpotter\ProcessedData_DelayedMode\nc\CapeBridgewater01';
%IMOS file name
filename = 'IMOS_NTP-WAVE_TW_20210624T075916Z_CAPEBW01_WAVERIDER_FV01_timeseries_END-20211203T022843Z.nc';

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
if any(data.quality_flag==3)
h(2) = plot(data.time(data.quality_flag==3), data.hs(data.quality_flag==3),'co'); 
end
if any(data.quality_flag==4)
h(3) = plot(data.time(data.quality_flag==4), data.hs(data.quality_flag==4),'ro'); 
end
datetick('x','dd-mmm'); 
text(0.05, 0.95,'(a)','units','normalized'); 
ylabel('Hs (m)'); 
xlabel('Date'); 

if any(data.quality_flag==3) & any(data.quality_flag==4)
l = legend(h,{'Data','Suspect','Fail'}); 
%     'Flagged Data (' num2str(round(length(find(data.quality_flag>1))./length(data.quality_flag)*100,2)) '%)']}); 
end
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


%additional plots 

finfo = ncinfo(ncfile);

%return

%temp data, don;t include for non temp SPotters
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


%%%%%%%%%%%         End Temp Data


% percentage of 4 and 3 flags

flag_per.bad = length(find(data.quality_flag==4))/length(data.quality_flag);
flag_per.suspect = length(find(data.quality_flag==3))/length(data.quality_flag);

disp('fraction of data with flag 4')
disp(num2str(flag_per.bad))
disp('fraction of data with flag 3')
disp(num2str(flag_per.suspect))

%Calc percentage of subflags

quality_subflag_ind = zeros(37,1);
quality_subflag_per = zeros(37,1);

for ii= 0:36
    quality_subflag_ind(ii+1)=ii;
    
    quality_subflag_per(ii+1) = (sum(data.quality_subflag==ii)/(sum(not(isnan(data.quality_subflag)))))*100;
    
end


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


% plot percentage of each type of subflag

figure()
title('percentage of subflag values')

bar(quality_subflag_ind,quality_subflag_per)
xticks(quality_subflag_ind);

% plot other variables not yest looked at 

%raw data figure
fid = figure; 
ax(1) = subplot(4,1,1); 
h(1) = plot(data.time, data.tm);
hold on; grid on;
datetick('x','dd-mmm'); 
text(0.05, 0.95,'(a)','units','normalized'); 
ylabel('tm (s)'); 
xlabel('Date'); 

ax(2) = subplot(4,1,2); 
plot(data.time, data.dm); 
hold on; grid on; 
datetick('x','dd-mmm');
xlabel('Date'); 
ylabel('dm (deg from)'); 


ax(3) = subplot(4,1,3); 
plot(data.time, data.pkspr); 
hold on; grid on; 
datetick('x','dd-mmm');
xlabel('Date'); 
ylabel('pkspr (deg)'); 

ax(4) = subplot(4,1,4); 
plot(data.time, data.meanspr); 
hold on; grid on; 
datetick('x','dd-mmm');
xlabel('Date'); 
ylabel('meanspr (deg)'); 

set(fid, 'PaperPositionMode', 'manual','PaperUnits','centimeters','units','centimeters',...
'position',[1 1 24 18], 'PaperPosition', [0 0 24 18])
%%

