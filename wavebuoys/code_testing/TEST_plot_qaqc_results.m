%% plot timeseries figure
clear; clc; 
filepath = 'F:\Active_Projects\LOWE_IMOS_WaveBuoys\Data\SofarSpotter\ProcessedData_DelayedMode\nc\CapeBridgewater01';
%IMOS file name
filename = 'IMOS_NTP-WAVE_W_20191220T153816Z_CAPEBW01_WAVERIDER_FV01_timeseries_END-20200722T040641Z.nc';

ncfile = fullfile(filepath, filename); 


%% read in some variables

bulkparams.time = ncread(ncfile,'TIME')+datenum(1950,1,1); 
bulkparams.hs = ncread(ncfile,'WSSH'); 
bulkparams.tp = ncread(ncfile,'WPPE');
bulkparams.tm = ncread(ncfile,'WPFM'); 
bulkparams.dp = ncread(ncfile,'WPDI'); 
bulkparams.dm = ncread(ncfile,'SSWMD');
bulkparams.pkspr = ncread(ncfile,'WPDS'); 
bulkparams.meanspr = ncread(ncfile,'WMDS'); 
bulkparams.temp = ones(size(bulkparams.time,1),1).*-9999; 

[bulkparams] = qaqc_bulkparams(bulkparams);

%%

qc_subflag = bulkparams.qc_subflag_wave;
qc_flag = bulkparams.qc_flag_wave; 

qc_subflag = qc_subflag+1; %subflags are assigned from 0 to 36 in netCDF
errors = unique(qc_subflag); 
errors = errors(errors>0); %disregard good results 

qaqc_errors = {'unspecified error','too few data','hs outside mean+3std', 'tp outside mean+3std', 'dp outside mean+3std',...
        'hs and tp outside mean+3std','hs and dp outside mean+3std', 'tp and dp outside mean+3std','hs tp dp outside mean+3std',...
        'hs flatline','tp flatline','dp flatline','hs and tp flatline','hs and dp flatline', 'tp and dp flatline',...
        'hs tp dp flatline','hs outside range', 'tp outside range','dp outside range','hs and tp outside range',...
        'hs and dp outside range','tp and dp outside range','hs tp dp outside range','hs rate of change',...
        'tp rate of change','dp rate of change','hs and tp rate of change','hs and dp rate of change',...
        'tp and dp rate of change','hs tp dp rate of change','hs spike','tp spike','dp spike',...
        'hs and tp spike','hs_and_dp spike','tp and dp spike','hs tp dp spike'};

%%
clear h ax 
fid = figure;
ax(1) = subplot(5,1,1); 
plot(bulkparams.time, bulkparams.hs);
hold on; grid on;
leg = {'r*','b*','g*','y*','c*','m*','k*','ro','bo','go','yo','co','mo','ko'}; 
for i = 1:length(errors)
    h(i) = plot(bulkparams.time(qc_subflag==errors(i)), bulkparams.hs(qc_subflag==errors(i)),leg{i});     
end
datetick('x','dd-mmm'); 
text(0.05, 0.95,'(a)','units','normalized'); 
ylabel('Hs (m)'); 
l = legend(h, qaqc_errors(errors),'units','centimeters','fontsize',10); 
title('Assigned with Mean Params (strict criteria)'); 

ax(2) = subplot(5,1,2); 
plot(bulkparams.time, bulkparams.tp); 
hold on; grid on; 
for i = 1:length(errors)
    h(i) = plot(bulkparams.time(qc_subflag==errors(i)), bulkparams.tp(qc_subflag==errors(i)),leg{i}); 
end
datetick('x','dd-mmm');
ylabel('Tp (s)'); 

ax(3) = subplot(5,1,3); 
plot(bulkparams.time, bulkparams.tm); 
hold on; grid on; 
for i = 1:length(errors)
    h(i) = plot(bulkparams.time(qc_subflag==errors(i)), bulkparams.tm(qc_subflag==errors(i)),leg{i}); 
end
datetick('x','dd-mmm');
ylabel('Tm (s)'); 


ax(4) = subplot(5,1,4); 
plot(bulkparams.time, bulkparams.dp); 
hold on; grid on; 
for i = 1:length(errors)
    h(i) = plot(bulkparams.time(qc_subflag==errors(i)), bulkparams.dp(qc_subflag==errors(i)),leg{i}); 
end
datetick('x','dd-mmm');
ylabel('Dp (deg from)'); 

ax(5) = subplot(5,1,5); 
plot(bulkparams.time, bulkparams.dm); 
hold on; grid on; 
for i = 1:length(errors)
    h(i) = plot(bulkparams.time(qc_subflag==errors(i)), bulkparams.dm(qc_subflag==errors(i)),leg{i}); 
end
datetick('x','dd-mmm');
xlabel('Date'); 
ylabel('Dm (deg from)'); 

set(fid, 'PaperPositionMode', 'manual','PaperUnits','centimeters','units','centimeters',...
'position',[1 1 28 19], 'PaperPosition', [0 0 28 19])

set(ax,'box','on','units','centimeters') 
set(ax(1),'Position',[1.5 15.5 20 2.5]); 
set(ax(2),'Position',[1.5 12 20 2.5]); 
set(ax(3),'Position',[1.5 8.5 20 2.5]); 
set(ax(4),'Position',[1.5 5 20 2.5]); 
set(ax(5),'Position',[1.5 1.5 20 2.5]); 
l.Position(1:2) = [22,13];

%% zoomed in to time period (Feb-Mar)
clear h ax 
fid = figure;
ax(1) = subplot(5,1,1); 
plot(bulkparams.time, bulkparams.hs);
hold on; grid on;
leg = {'r*','b*','g*','y*','c*','m*','k*','ro','bo','go','yo','co','mo','ko'}; 
for i = 1:length(errors)
    h(i) = plot(bulkparams.time(qc_subflag==errors(i)), bulkparams.hs(qc_subflag==errors(i)),leg{i});     
end
set(gca,'xlim',[datenum(2020,2,1) datenum(2020,3,1)]); 
datetick('x','dd-mmm'); 
set(gca,'xlim',[datenum(2020,2,1) datenum(2020,3,1)]); 
text(0.05, 0.95,'(a)','units','normalized'); 
ylabel('Hs (m)'); 
l = legend(h, qaqc_errors(errors),'units','centimeters','fontsize',10); 
title('Assigned with Mean Params (strict criteria)'); 

ax(2) = subplot(5,1,2); 
plot(bulkparams.time, bulkparams.tp); 
hold on; grid on; 
for i = 1:length(errors)
    h(i) = plot(bulkparams.time(qc_subflag==errors(i)), bulkparams.tp(qc_subflag==errors(i)),leg{i}); 
end
set(gca,'xlim',[datenum(2020,2,1) datenum(2020,3,1)]); 
datetick('x','dd-mmm'); 
set(gca,'xlim',[datenum(2020,2,1) datenum(2020,3,1)]); 
ylabel('Tp (s)'); 

ax(3) = subplot(5,1,3); 
plot(bulkparams.time, bulkparams.tm); 
hold on; grid on; 
for i = 1:length(errors)
    h(i) = plot(bulkparams.time(qc_subflag==errors(i)), bulkparams.tm(qc_subflag==errors(i)),leg{i}); 
end
set(gca,'xlim',[datenum(2020,2,1) datenum(2020,3,1)]); 
datetick('x','dd-mmm'); 
set(gca,'xlim',[datenum(2020,2,1) datenum(2020,3,1)]); 
ylabel('Tm (s)'); 


ax(4) = subplot(5,1,4); 
plot(bulkparams.time, bulkparams.dp); 
hold on; grid on; 
for i = 1:length(errors)
    h(i) = plot(bulkparams.time(qc_subflag==errors(i)), bulkparams.dp(qc_subflag==errors(i)),leg{i}); 
end
set(gca,'xlim',[datenum(2020,2,1) datenum(2020,3,1)]); 
datetick('x','dd-mmm'); 
set(gca,'xlim',[datenum(2020,2,1) datenum(2020,3,1)]); 
ylabel('Dp (deg from)'); 

ax(5) = subplot(5,1,5); 
plot(bulkparams.time, bulkparams.dm); 
hold on; grid on; 
for i = 1:length(errors)
    h(i) = plot(bulkparams.time(qc_subflag==errors(i)), bulkparams.dm(qc_subflag==errors(i)),leg{i}); 
end
set(gca,'xlim',[datenum(2020,2,1) datenum(2020,3,1)]); 
datetick('x','dd-mmm'); 
set(gca,'xlim',[datenum(2020,2,1) datenum(2020,3,1)]); 
xlabel('Date'); 
ylabel('Dm (deg from)'); 

set(fid, 'PaperPositionMode', 'manual','PaperUnits','centimeters','units','centimeters',...
'position',[1 1 28 19], 'PaperPosition', [0 0 28 19])

set(ax,'box','on','units','centimeters') 
set(ax(1),'Position',[1.5 15.5 20 2.5]); 
set(ax(2),'Position',[1.5 12 20 2.5]); 
set(ax(3),'Position',[1.5 8.5 20 2.5]); 
set(ax(4),'Position',[1.5 5 20 2.5]); 
set(ax(5),'Position',[1.5 1.5 20 2.5]); 
l.Position(1:2) = [22,13];
