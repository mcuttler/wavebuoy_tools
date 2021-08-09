%% check netCDF output prior to aodn upload

ncfile = 'Y:\LOWE_IMOS_Deakin_Collab_JUN2020\Data\SofarSpotter\ProcessedData_DelayedMode\nc\TorbayEast01\IMOS_NTP-WAVE_W_20200115T002922Z_TORE01_WAVERIDER_FV01_timeseries_END-20200523T235919Z.nc';

time = double(ncread(ncfile,'TIME'))+datenum(1950,1,1); 
hsig = ncread(ncfile,'WSSH'); 
tm = ncread(ncfile,'WPFM'); 
lat = ncread(ncfile,'LATITUDE'); 
lon = ncread(ncfile,'LONGITUDE'); 
%add in quality flag probably to include in plot

%% plot figure 
fid = figure;
ax(1) = subplot(2,2,1); 
plot(time, hsig); 
grid on; 
ylabel('H_{sig} [m]'); 
datetick('x','dd-mmm'); 

ax(2) = subplot(2,2,2);
plot(time, hsig); 
grid on; 
ylabel('T_{m} [s]'); 
datetick('x','dd-mmm'); 

ax(3) = subplot(2,2,3); 
geoshow('landareas.shp', 'FaceColor', [0.5 0.5 0.5]);
hold on
plot(nanmean(lon), nanmean(lat),'r.','markersize',18); 
set(ax(3),'xlim',[100 160],'ylim',[-36 -10]); 
xlabel('Longitude [deg]');
ylabel('Latitude [deg]'); 

ax(4) = subplot(2,2,4); 
geoshow('landareas.shp', 'FaceColor', [0.5 0.5 0.5]);
hold on
plot(nanmean(lon), nanmean(lat),'r.','markersize',18); 
set(ax(4),'xlim',[nanmin(lon)-2 nanmax(lon)+2],'ylim',[nanmin(lat)-2 nanmax(lat)+2]); 
xlabel('Longitude [deg]');
ylabel('Latitude [deg]'); 


set(fid, 'PaperPositionMode', 'manual','PaperUnits','centimeters','units','centimeters',...
    'position',[2 2 22 14], 'PaperPosition', [0 0 20 14],'color','w')

set(ax,'box','on','units','centimeters'); 
set(ax(1),'Position',[1.5 8 7 3]);
set(ax(2),'Position',[1.5 3 7 3]);
set(ax(3),'Position',[11 5.5 10 12])
set(ax(4),'Position',[11 1.5 4 4])


