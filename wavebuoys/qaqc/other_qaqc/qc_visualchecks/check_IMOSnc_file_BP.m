%% Check IMOS-compliant netCDF file

close all
clear all
clc

%% read netCDF file
%set file path (wherever file downloaded to)
filepath = 'E:\wawaves\KingGeorgeSound\delayedmode\ProcessedData_DelayedMode\dep04_b';
%IMOS file name
filename = 'UWA_20221109_King-George-Sound_DM_WAVE-PARAMETERS_20230129.nc';

ncfile = fullfile(filepath, filename); 

% file info

finfo = ncinfo(ncfile);
%% read in variables


data.TIME = ncread(ncfile,'TIME')+datenum(1950,1,1); 
data.LONGITUDE = ncread(ncfile,'LONGITUDE');
data.LATITUDE = ncread(ncfile,'LATITUDE');
data.WSSH = ncread(ncfile,'WSSH'); 
data.WPFM = ncread(ncfile,'WPFM'); 
data.WPPE = ncread(ncfile,'WPPE');
data.SSWMD = ncread(ncfile,'SSWMD');
data.WPDI = ncread(ncfile,'WPDI'); 
data.WMDS = ncread(ncfile,'WMDS'); 
data.WPDS = ncread(ncfile,'WPDS'); 

data.WAVE_quality_control = ncread(ncfile,'WAVE_quality_control'); 


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


%Plot all Bulk parameters

fid = figure; 
ax(1) = subplot(4,1,1); 
h(1) = plot(data.TIME, data.WSSH);
hold on; grid on;
datetick('x','dd-mmm'); 
text(0.05, 0.95,'(a)','units','normalized'); 
ylabel('WSSH (m)'); 

ax(2) = subplot(4,1,2); 
plot(data.TIME, data.WPFM); 
hold on; grid on;
plot(data.TIME, data.WPPE,'r'); 
datetick('x','dd-mmm');

ylabel('WPFM, WPPE (s)'); 


ax(3) = subplot(4,1,3); 
plot(data.TIME, data.SSWMD); 
hold on; grid on; 
plot(data.TIME, data.WPDI,'r'); 
datetick('x','dd-mmm');
ylabel('SSWMD, WPDI (deg from)'); 
legend('SSWMD','WPDI')

ax(4) = subplot(4,1,4); 
plot(data.TIME, data.WMDS); 
hold on; grid on; 
plot(data.TIME, data.WPDS,'r'); 
datetick('x','dd-mmm');
ylabel('WMDS, WPDS (deg from)'); 
legend('WMDS','WPDS')

set(fid, 'PaperPositionMode', 'manual','PaperUnits','centimeters','units','centimeters',...
'position',[1 1 24 18], 'PaperPosition', [0 0 24 18])


% Plot WAVE quality Control

figure(); 
subplot(3,1,1); 
h(1) = plot(data.TIME, data.WSSH);
hold on; grid on;
if any(data.WAVE_quality_control==3)
h(2) = plot(data.TIME(data.WAVE_quality_control==3), data.WSSH(data.WAVE_quality_control==3),'co'); 
end
if any(data.WAVE_quality_control==4)
h(3) = plot(data.TIME(data.WAVE_quality_control==4), data.WSSH(data.WAVE_quality_control==4),'ro'); 
end
datetick('x','dd-mmm'); 
ylabel('WSSH (m)'); 

subplot(3,1,2); 
plot(data.TIME, data.WPFM); 
hold on; grid on;
plot(data.TIME, data.WPPE,'r'); 
if any(data.WAVE_quality_control==3)
h(2) = plot(data.TIME(data.WAVE_quality_control==3), data.WPPE(data.WAVE_quality_control==3),'co'); 
end
if any(data.WAVE_quality_control==4)
h(3) = plot(data.TIME(data.WAVE_quality_control==4), data.WPPE(data.WAVE_quality_control==4),'ko'); 
end
datetick('x','dd-mmm');
ylabel('WPFM, WPPE (s)'); 

subplot(3,1,3); 
plot(data.TIME, data.WAVE_quality_control); 
hold on; grid on;
datetick('x','dd-mmm');
ylabel('WAVE quality control'); 


return

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



%return



%temp data, don;t include for non temp SPotters
data.TEMP = ncread(ncfile,'TEMP'); 
data.TEMP_quality_control = ncread(ncfile,'TEMP_quality_control'); 


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

