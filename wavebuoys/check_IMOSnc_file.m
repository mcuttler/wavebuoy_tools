%% Check IMOS-compliant netCDF file

%% read netCDF file
%set file path (wherever file downloaded to)
filepath = 'F:\Active_Projects\LOWE_IMOS_WaveBuoys\Data\SofarSpotter\ProcessedData_DelayedMode\nc\CapeBridgewater01';
%IMOS file name
filename = 'IMOS_NTP-WAVE_W_20191220T153816Z_CAPEBW01_WAVERIDER_FV01_timeseries_END-20200722T040641Z.nc';

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
plot(data.time(data.quality_flag==3), data.dp(data.quality_flag==3),'ro'); 
plot(data.time(data.quality_flag==4), data.dp(data.quality_flag==4),'ro'); 
datetick('x','dd-mmm');
xlabel('Date'); 
ylabel('Dp (deg from)'); 

set(fid, 'PaperPositionMode', 'manual','PaperUnits','centimeters','units','centimeters',...
'position',[1 1 24 18], 'PaperPosition', [0 0 24 18])

% %% check sources of flags
% [flag_source] =  qaqc_error_source(data.quality_subflag);



