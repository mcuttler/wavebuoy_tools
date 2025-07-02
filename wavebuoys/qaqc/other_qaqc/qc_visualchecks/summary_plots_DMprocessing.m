
% save directory

sdirec = 'C:\Users\00104893\LocalDocuments\Projects\Wave buoys\Spotters\data\collaroy_deploy20241205_retrieve20250404_SPOT-31880C\proccessed\Summary';

% temp ot look at orig metadata Cape bridgewater location
Vic_logCB_lat=-38.355717 ;
Vic_logCB_lon= 141.270633;

%run before to save original data before clipping
disp_o=displacements;
gps_o=gps;
surface_temp_o=surface_temp;
baro_o=baro;

% Plot whole record displacements
figure()
subplot(3,1,1)
plot(disp_o.Time,disp_o.x);
title(strcat('X disp whole record',{'    '}, buoy_info.site_name));
ylabel ('displacement [m]')
subplot(3,1,2)
plot(disp_o.Time,disp_o.y);
title('Y disp whole record');
ylabel ('displacement [m]')
subplot(3,1,3)
plot(disp_o.Time,disp_o.z);
title('Z disp whole record');
ylabel ('displacement [m]')
xlabel ('Time');

cd(sdirec);
saveas(gcf, 'whole_rec_disp.png');

%plot whole record positions
figure()
subplot(2,2,1)
plot(gps_o.Time,gps_o.longitude);
title(strcat('whole record longitude',{'    '},buoy_info.site_name));
xlabel('Time')
ylabel ('longitude [deg]')
subplot(2,2,2)
plot(gps_o.Time,gps_o.latitude);
title('whole record latitude')
xlabel('Time')
ylabel('latitude [deg]')
subplot(2,2,3)
plot(gps_o.longitude,gps_o.latitude);
title('whole record buoy position')
ylabel('latitude [deg]')
xlabel('longitude [deg]')
hold on
scatter(buoy_info.DeployLon,buoy_info.DeployLat,80,'red','filled');
%scatter(Vic_logCB_lon,Vic_logCB_lat,80,'green','filled')
C = load('coastlines');
plot(C.coastlon,C.coastlat,'k')
xlim([min(gps_o.longitude)-0.5 max(gps_o.longitude)+0.5]);
ylim([min(gps_o.latitude)-0.5 max(gps_o.latitude)+0.55]);
ylabel('latitude [deg]')
xlabel('longitude [deg]')
legend('measured position','metadata deploy location');

subplot(2,2,4)
scatter(gps_o.longitude,gps_o.latitude,'.');
title('whole record buoy position-zoomed into vicintiy of deployment')
hold on
scatter(buoy_info.DeployLon,buoy_info.DeployLat,80,'red','filled');
%scatter(Vic_logCB_lon,Vic_logCB_lat,80,'green','filled')
C = load('coastlines');
plot(C.coastlon,C.coastlat,'k')
xlim([buoy_info.DeployLon-0.008 buoy_info.DeployLon+0.008]);
ylim([buoy_info.DeployLat-0.008 buoy_info.DeployLat+0.008]);
ylabel('latitude [deg]')
xlabel('longitude [deg]')
legend('measured position','metadata deploy location');

set(gcf, 'Position', get(0, 'Screensize'));
cd(sdirec);
saveas(gcf, 'whole_rec_positions.png');

%plot distance from DEPLOY lat and lon
figure()
plot(gps.Time,dum_distance,'LineWidth',2)
title(strcat('distance from deploy lat and lon, after start(YYYYMMDD 00:00:00) and end(YYYYMMDD 00:00:00) day clipping',{'    '}, buoy_info.site_name))
hold on
plot(gps.Time, ones(length(gps.Time),1)*buoy_info.watch_circle,'r','LineWidth',2)
plot(gps.Time, ones(length(gps.Time),1)*buoy_info.watch_circle*buoy_info.watch_circle_multiplier,'k','LineWidth',2)
ylim([0 buoy_info.watch_circle+100]);
xlabel('Time')
ylabel('distance from metadata deploy location [m]')

legend('dist from deploy position','watch circle radius', string(strcat('watch circ * multiplier =',{' '},num2str(buoy_info.watch_circle),' * ',num2str(buoy_info.watch_circle_multiplier))) );

set(gcf, 'Position', get(0, 'Screensize'));
cd(sdirec);
saveas(gcf, 'distance_fr_deploy.png');

%plot whole record surface temp and baro

figure()
subplot(2,1,1)
plot(surface_temp_o.Time,surface_temp_o.temperature,'LineWidth',2);
title ('whole record surface temp');
xlabel('Time')
ylabel ('Temp [deg C]')
subplot(2,1,2)
plot(baro_o.Time,baro_o.baro_pressure,'LineWidth',2);
title ('whole record barometer');
xlabel('Time')
ylabel(' Pressure [hPa] ')

set(gcf, 'Position', get(0, 'Screensize'));
cd(sdirec);
saveas(gcf, 'whole_rec_tempbaro.png');

%plot clipped position record
figure()
subplot(2,2,1)
plot(gps.Time,gps.longitude,'LineWidth',2);
title('data to go to spec processing - longitude')
xlabel('Time');
ylabel('longitude')
subplot(2,2,2)
plot(gps.Time,gps.latitude,'LineWidth',2);
title('data to go to spec processing -latitude')
xlabel('Time');
ylabel('latitude')
subplot(2,2,3)
plot(gps.longitude,gps.latitude,'LineWidth',2);
title('data to go to spec processing - buoy position')
xlabel('longitude')
ylabel('latitude')
hold on
scatter(buoy_info.DeployLon,buoy_info.DeployLat,80,'red','filled');
C = load('coastlines');
plot(C.coastlon,C.coastlat,'k')
legend('data','metadata position')
xlim([min(gps_o.longitude)-0.5 max(gps_o.longitude)+0.5]);
ylim([min(gps_o.latitude)-0.5 max(gps_o.latitude)+0.55]);

subplot(2,2,4)
scatter(gps.longitude,gps.latitude,'.');
title('data to go to spec processing - buoy position - zoomed into area of deployment')
hold on
scatter(buoy_info.DeployLon,buoy_info.DeployLat,80,'red','filled');
C = load('coastlines');
plot(C.coastlon,C.coastlat,'k')
xlim([buoy_info.DeployLon-0.004 buoy_info.DeployLon+0.004]);
ylim([buoy_info.DeployLat-0.004 buoy_info.DeployLat+0.004]);
xlabel('longitude')
ylabel('latitude')
legend('data','metadata deploy position')

set(gcf, 'Position', get(0, 'Screensize'));
cd(sdirec);
saveas(gcf, 'cropped_and_filtered_positions.png');

% plot positions comparison
figure()
subplot(3,2,1)
plot(gps_o.Time,gps_o.longitude,'--');
hold on
plot(gps.Time,gps.longitude,'r');
title('longitude data comparison once cropped and watch circle filtered - beginning')
xlabel ('Time');
ylabel('longitude')
xlim([gps_o.Time(1) gps_o.Time(700)])
legend('whole record','data remaining')

subplot(3,2,2)
plot(gps_o.Time,gps_o.longitude,'--');
hold on
plot(gps.Time,gps.longitude,'r');
title('longitude data comparison once cropped and watch circle filtered - end')
xlabel ('Time');
ylabel('longitude')
xlim([gps_o.Time(end-6000) gps_o.Time(end)+1])
legend('whole record','data remaining')

subplot(3,2,3)
plot(gps_o.Time,gps_o.latitude,'--');
hold on
plot(gps.Time,gps.latitude,'r');
title('latitude data comparison once cropped and watch circle filtered - beginning')
xlabel ('Time');
ylabel('latitude')
xlim([gps_o.Time(1) gps_o.Time(700)])
legend('whole record','data remaining')
subplot(3,2,4)
plot(gps_o.Time,gps_o.latitude,'--');
hold on
plot(gps.Time,gps.latitude,'r');
title('latitude data comparison once cropped and watch circle filtered -end')
xlabel ('Time');
ylabel('latitude')
xlim([gps_o.Time(end-6000) gps_o.Time(end)+1])
legend('whole record','data remaining')

subplot(3,2,5)
plot(gps_o.longitude,gps_o.latitude);
title('buoy position comparison once cropped and watch circel filtered')
hold on
plot(gps.longitude,gps.latitude,'k.');
scatter(buoy_info.DeployLon,buoy_info.DeployLat,80,'red','filled');
C = load('coastlines');
plot(C.coastlon,C.coastlat,'k')
xlabel('longitude');
ylabel('latitude');
xlim([min(gps_o.longitude)-0.5 max(gps_o.longitude)+0.5]);
ylim([min(gps_o.latitude)-0.5 max(gps_o.latitude)+0.55]);
legend('whole data set','data remaining','deploy loc metadata','coast')

subplot(3,2,6)
scatter(gps_o.longitude,gps_o.latitude);
title('buoy position comparison once cropped and watch circel filtered -zoomed to deploy location')
hold on
scatter(gps.longitude,gps.latitude,'k.');
scatter(buoy_info.DeployLon,buoy_info.DeployLat,80,'red','filled');
C = load('coastlines');
plot(C.coastlon,C.coastlat,'k')
xlabel('longitude');
ylabel('latitude');
xlim([buoy_info.DeployLon-0.002 buoy_info.DeployLon+0.002]);
ylim([buoy_info.DeployLat-0.002 buoy_info.DeployLat+0.002]);
legend('whole data set','data remaining','deploy loc metadata','coast')

set(gcf, 'Position', get(0, 'Screensize'));
cd(sdirec);
saveas(gcf, 'compare_positions_to_filteredpostitions.png');

% plot displacements comparison
figure()
subplot(3,1,1)
plot(disp_o.Time,disp_o.x);
hold on
plot(data.disp_time,data.x);
title('X disp comparison after crop and watch circle filtering');
xlabel('time')
ylabel('displacement [m]')
legend('whole data record','data remaining')
subplot(3,1,2)
plot(disp_o.Time,disp_o.y);
hold on
plot(data.disp_time,data.y);
title('Y disp comparison after crop and watch circle filtering');
xlabel('time')
ylabel('displacement [m]')
legend('whole data record','data remaining')
subplot(3,1,3)
plot(disp_o.Time,disp_o.z);
hold on
plot(data.disp_time,data.z);
title('Z disp comparison after crop and watch circle filtering');
xlabel('time')
ylabel('displacement [m]')
legend('whole data record','data remaining')

set(gcf, 'Position', get(0, 'Screensize'));
cd(sdirec);
saveas(gcf, 'compare_disp_after_filter.png');

%plot disp comparison start and end

figure()
subplot(3,2,1)
plot(disp_o.Time,disp_o.x);
hold on
plot(data.disp_time,data.x);
xlim([disp_o.Time(1)-0.3 data.disp_time(1)+0.3])
title('X disp - beginning');
xlabel('time')
ylabel('displacement [m]')
legend('whole record','data remainig')

subplot(3,2,2)
plot(disp_o.Time,disp_o.x);
hold on
plot(data.disp_time,data.x);

xlim([data.disp_time(end)-0.3 disp_o.Time(end)+0.3])
title('X disp - end');
xlabel('time')
ylabel('displacement [m]')

subplot(3,2,3)
plot(disp_o.Time,disp_o.y);
hold on
plot(data.disp_time,data.y);
xlim([disp_o.Time(1)-0.3 data.disp_time(1)+0.3])
title('Y disp - beginning');
xlabel('time')
ylabel('displacement [m]')

subplot(3,2,4)
plot(disp_o.Time,disp_o.y);
hold on
plot(data.disp_time,data.y);
xlim([data.disp_time(end)-0.3 disp_o.Time(end)+0.3])
title('Y disp - end');
xlabel('time')
ylabel('displacement [m]')

subplot(3,2,5)
plot(disp_o.Time,disp_o.z);
hold on
plot(data.disp_time,data.z);
xlim([disp_o.Time(1)-0.3 data.disp_time(1)+0.3])
title('Z disp - beginning');
xlabel('time')
ylabel('displacement [m]')

subplot(3,2,6)
plot(disp_o.Time,disp_o.z);
hold on
plot(data.disp_time,data.z);
xlim([data.disp_time(end)-0.3 disp_o.Time(end)+0.3])
title('Z disp - end');
xlabel('time')
ylabel('displacement [m]')

set(gcf, 'Position', get(0, 'Screensize'));
cd(sdirec);
saveas(gcf, 'compare_disp_after_filter_strtend.png');

%plot comparison clipped suurface temp and baro

figure()
subplot(2,1,1)
plot(surface_temp_o.Time,surface_temp_o.temperature,'LineWidth',2);
hold on
plot(surface_temp.Time,surface_temp.temperature,'LineWidth',2);
legend('whole record','data remaining')
xlabel ('Time');
ylabel('temperature [deg C]')
title ('surface temp');
subplot(2,1,2)
plot(baro_o.Time,baro_o.baro_pressure,'LineWidth',2);
hold on
plot(baro.Time,baro.baro_pressure,'LineWidth',2);
title ('barometer');
xlabel('Time');
ylabel('pressure [hPa]');


set(gcf, 'Position', get(0, 'Screensize'));
cd(sdirec);
saveas(gcf, 'compare_tempbaro_after_filter.png');


% plot diff T-VECS for clipped data

figure()
subplot(4,1,1)
plot(datenum(data.disp_time(2:end)),(24*60*60)*datenum(diff(data.disp_time)),'LineWidth',2);
title ('difference time vec displacements ');
%ylim([0.3 time2num(max(diff(data.disp_time)),seconds)+1])
datetick
xlabel('time');
ylabel('time difference [s]');

subplot(4,1,2)
plot(datenum(gps.Time(2:end)),(24*60*60)*datenum(diff(gps.Time)),'LineWidth',2);
title ('diff time vec gps');
%ylim([55 time2num(max(diff(gps.Time)),seconds)])
datetick
xlabel('time');
ylabel('time difference [s]');

subplot(4,1,3)
plot(datenum(surface_temp.Time(2:end)),(24*60*60)*datenum(diff(surface_temp.Time)),'LineWidth',2);
title ('difference time vector surface_temp ');
%ylim([55 time2num(max(diff(surface_temp.Time)),seconds)])
datetick
xlabel('time');
ylabel('time difference [s]');

subplot(4,1,4)
plot(datenum(baro.Time(2:end)),(24*60*60)*datenum(diff(baro.Time)),'LineWidth',2);
title ('difference time vector barometer');
%ylim([55 time2num(max(diff(baro.Time)),seconds)])
datetick
xlabel('time');
ylabel('time difference [s]');

set(gcf, 'Position', get(0, 'Screensize'));
cd(sdirec);
saveas(gcf, 'difference_time_vectors.png');


%calculate max hight in segment from upcrossing
for ii = 1: length(data.height_0)
    height_0_max(ii) = max(cell2mat(data.height_0(ii)));
end



% plot Spectral processing outputs
figure()
subplot(2,1,1)
plot(data.time,data.hs,'LineWidth',2)
hold on
plot(data.time,data.hrms,'LineWidth',2)
plot(data.time,data.hsSwell,'LineWidth',2)
plot(data.time,data.hsSea,'LineWidth',2)
plot(data.time,cell2mat(data.hs_0),'k','LineWidth',2);
plot(data.time,height_0_max,'k','LineWidth',2)
legend('hs','hrms','hswell','hsea','height0','height0 max')
xlabel('time')
ylabel('height [m]')

subplot(2,1,2)
plot(data.time,data.tp,'LineWidth',2)
hold on
plot(data.time,data.tm,'LineWidth',2)
plot(data.time,data.tm2,'LineWidth',2)
plot(data.time,data.tmSwell,'LineWidth',2)
plot(data.time,data.tm2Swell,'LineWidth',2)
plot(data.time,data.tmSea,'LineWidth',2)
plot(data.time,data.tm2Sea,'LineWidth',2)
plot(data.time,cell2mat(data.tz_0),'k--','LineWidth',2)
legend('tp','tm','tm2','tmswell','tm2swell','tmSea','tm2sea','tz_0')
xlabel('time');
ylabel('period [s]')

set(gcf, 'Position', get(0, 'Screensize'));
cd(sdirec);
saveas(gcf, 'Heights and periods.png');

%plot more Spec processing outputs

figure()

subplot(2,1,1)
plot(data.time,data.dp,'LineWidth',2)
hold on
plot(data.time,data.dm,'LineWidth',2)
plot(data.time,data.dm2,'LineWidth',2)
plot(data.time,data.dmSwell,'LineWidth',2)
plot(data.time,data.dm2Swell,'LineWidth',2)
plot(data.time,data.dmSea,'k','LineWidth',2)
plot(data.time,data.dm2Sea,'LineWidth',2)
legend('dp','dm','dm2','dmswell','dm2swell','dmSea','dm2sea')
title('mean direction')
xlabel('time')
ylabel('direction [degrees]')

subplot(2,1,2)
plot(data.time,data.dpspr,'LineWidth',2)
hold on
plot(data.time,data.dmspr,'LineWidth',2)
plot(data.time,data.dmsprSwell,'LineWidth',2)
plot(data.time,data.dmsprSea,'LineWidth',2)
legend('dpspr','dmspr','dmsprSwell','dmsprSea');
title('directional spread')
xlabel('time')
ylabel('directional spread [degrees]')

set(gcf, 'Position', get(0, 'Screensize'));
cd(sdirec);
saveas(gcf, 'direction and directional spread.png');

% plots segement and segments used and spectral processed time vec
figure()
subplot(3,1,1)
plot(data.time,'LineWidth',2)
title('time vector for spectral processed data')
xlabel('sample');
ylabel('time');

subplot(3,1,2)
plot(data.time(2:end),diff(data.time),'LineWidth',2);
title('difference in time vector');
ylim([duration(0,0,0) duration(1,0,0)]);
xlabel('time')
ylabel('time difference');

subplot(3,1,3)
plot(data.time,data.segments,'LineWidth',2)
hold on
plot(data.time,data.segments_used,'LineWidth',2)
ylim([min(data.segments_used)-1 max(data.segments_used)+1])
legend('segments in 30min chunk','segements used')
xlabel('time')
ylabel('segements in 30 minute data chunk')

set(gcf, 'Position', get(0, 'Screensize'));
cd(sdirec);
saveas(gcf, 'time_vec_and_segments.png');

%segment stats

per_segs_notused=((sum(data.segments)-sum(data.segments_used))/sum(data.segments))*100;

%plotQC wave flags
figure()
subplot(3,1,1)
plot(data.time,data.segments,'LineWidth',2)
hold on
plot(data.time,data.segments_used,'LineWidth',2)
ylim([min(data.segments_used)-1 max(data.segments_used)+1])
legend('segments','segements used')
xlabel('time')
ylabel('segemnts in each 30 min data chunk')

subplot(3,1,2)
plot(data.time,data.qc_flag_wave,'LineWidth',2)
title('wave flag')
xlabel('time')
ylabel('wave flag value')

subplot(3,1,3)
plot(data.time,data.qc_subflag_wave,'LineWidth',2)
title('wave subflag')
xlabel('time')
ylabel('wave subflag value')

set(gcf, 'Position', get(0, 'Screensize'));
cd(sdirec);
saveas(gcf, 'segements_and_qcflags.png');

% qc wave flag stats
per_flag_wave4 = (length(find(data.qc_flag_wave==4))/length(data.qc_flag_wave))*100;
per_flag_wave3 = (length(find(data.qc_flag_wave==3))/length(data.qc_flag_wave))*100;
per_flag_wave1 = (length(find(data.qc_flag_wave==1))/length(data.qc_flag_wave))*100;

% q c subflag statistics
for ii=1:37
per_sub(ii)=(length(find(data.qc_subflag_wave==(ii-1)))/length(data.qc_subflag_wave))*100;
if ii==37
per_sub(ii+1) = (length(find(data.qc_subflag_wave==(-127)))/length(data.qc_subflag_wave))*100;

end
end

sub_per = [0:37; per_sub]'
sub_per(38,1) = -127;
clearvars per_sub

%subflag histogram
figure()
histogram(data.qc_subflag_wave,[-127:36])
xlim([0 36])
ylim([0 70])
title ('subflag histogram')
xlabel('subflag value')
ylabel('counts')

set(gcf, 'Position', get(0, 'Screensize'));
cd(sdirec);
saveas(gcf, 'subflag histogram.png');

%plot subflags on hs, tp and dm
figure()
ax(1) = subplot(3,1,1); 
h(1) = plot(data.time,data.hs);
hold on; grid on;
h(2) = scatter(data.time(find(data.qc_flag_wave==3)),data.hs(find(data.qc_flag_wave==3)),'ko'); 
h(3) = scatter(data.time(find(data.qc_flag_wave==4)),data.hs(find(data.qc_flag_wave==4)),'ro');
ylabel('Hs (m)'); 
legend('Data','Suspect','Fail'); 
text(data.time(find(data.qc_flag_wave==3 | data.qc_flag_wave==4)),data.hs(find(data.qc_flag_wave==3 | data.qc_flag_wave==4)), num2str(data.qc_subflag_wave(find(data.qc_flag_wave==3 | data.qc_flag_wave==4)))  );


ax(1) = subplot(3,1,2); 
h(1) = plot(data.time,data.tp);
hold on; grid on;
h(2) = scatter(data.time(find(data.qc_flag_wave==3)),data.tp(find(data.qc_flag_wave==3)),'ko'); 
h(3) = scatter(data.time(find(data.qc_flag_wave==4)),data.tp(find(data.qc_flag_wave==4)),'ro');
ylabel('Tp (s)'); 
legend('Data','Suspect','Fail'); 
text(data.time(find(data.qc_flag_wave==3 | data.qc_flag_wave==4)),data.tp(find(data.qc_flag_wave==3 | data.qc_flag_wave==4)), num2str(data.qc_subflag_wave(find(data.qc_flag_wave==3 | data.qc_flag_wave==4)))  );

ax(1) = subplot(3,1,3); 
h(1) = plot(data.time,data.dp);
hold on; grid on;
h(2)=plot(data.time,data.dm);
h(3) = scatter(data.time(find(data.qc_flag_wave==3)),data.dp(find(data.qc_flag_wave==3)),'ko'); 
h(4) = scatter(data.time(find(data.qc_flag_wave==4)),data.dp(find(data.qc_flag_wave==4)),'ro');
ylabel('Dm Dp (s)'); 
legend('Data dp','data dm','Suspect','Fail'); 
text(data.time(find(data.qc_flag_wave==3 | data.qc_flag_wave==4)),data.dp(find(data.qc_flag_wave==3 | data.qc_flag_wave==4)), num2str(data.qc_subflag_wave(find(data.qc_flag_wave==3 | data.qc_flag_wave==4)))  );



%Calc missing segmeents info
miss_seg_ind = find(data.segments~=data.segments_used);
miss_seg_time = data.time(miss_seg_ind)';

% plot energy spectrogram


figure()
colormap parula;
subplot(3,1,1)
imagesc(data.time,(data.frequency),data.energy')
set(gca,'YDir','normal')
%caxis([0 1]);
hold on
scatter(miss_seg_time,ones(1,length(miss_seg_time))*0.01,'mo','filled')

%ylim([0 0.5]);
title('energy')
ylabel('frequency [Hz]');
colorbar;

subplot(3,1,2)
imagesc(data.time,(data.frequency),10*log10(data.energy'))
set(gca,'YDir','normal')
%caxis([0 0.2]);
%ylim([0 0.5]);
hold on
scatter(miss_seg_time,ones(1,length(miss_seg_time))*0.01,'mo','filled')
title('energy dB arb ref')
ylabel('frequency [Hz]');
colorbar;

subplot(3,1,3)
imagesc(data.time,(data.frequency),data.check_fact')
set(gca,'YDir','normal')
caxis([0 10]);
hold on
scatter(miss_seg_time,ones(1,length(miss_seg_time))*0.01,'mo','filled')

%ylim([0 0.5]);
title('check factor')
ylabel('frequency [Hz]');
colorbar

set(gcf, 'Position', get(0, 'Screensize'));
cd(sdirec);
saveas(gcf, 'energy_and_check.png');

% PLot Energy

figure()
subplot(3,1,1)
imagesc(data.time,(data.frequency),data.energy')
set(gca,'YDir','normal')
caxis([0 1]);
hold on
scatter(miss_seg_time,ones(1,length(miss_seg_time))*0.01,'mo','filled')

ylim([0 0.5]);
title('energy')
ylabel('frequency [Hz]');
legend('places with missing segements')
colorbar;

subplot(3,1,2)
imagesc(data.time,(data.frequency),10*log10(data.energy'))
set(gca,'YDir','normal')
%caxis([0 0.2]);
ylim([0 0.5]);
hold on
scatter(miss_seg_time,ones(1,length(miss_seg_time))*0.01,'mo','filled')
title('energy dB arb ref')
ylabel('frequency [Hz]');
legend('places with missing segements')
colorbar;

subplot(3,1,3)
imagesc(data.time,(data.frequency),data.check_fact')
set(gca,'YDir','normal')
caxis([0 2]);
ylim([0 0.5]);
hold on
scatter(miss_seg_time,ones(1,length(miss_seg_time))*0.01,'mo','filled')
title('check factor')
ylabel('frequency [Hz]');
legend('places with missing segements')
colorbar

set(gcf, 'Position', get(0, 'Screensize'));
cd(sdirec);
saveas(gcf, 'energy_and_check_2.png');

%plot a's, b's
figure()
subplot(4,1,1)
imagesc(data.time,(data.frequency),data.a1')
set(gca,'YDir','normal')
%caxis([0 1.5]);
ylim([0 0.8]);
title('a1')
ylabel('frequency [Hz]')
colorbar;

subplot(4,1,2)
imagesc(data.time,(data.frequency),data.a2')
set(gca,'YDir','normal')
%caxis([0 1.5]);
ylim([0 0.8]);
title('a2')
ylabel('frequency [Hz]')
colorbar;

subplot(4,1,3)
imagesc(data.time,(data.frequency),data.b1')
set(gca,'YDir','normal')
%caxis([0 1.5]);
ylim([0 0.8]);
title('b1')
ylabel('frequency [Hz]')
colorbar;

subplot(4,1,4)
imagesc(data.time,(data.frequency),data.b2')
set(gca,'YDir','normal')
%caxis([0 1.5]);
ylim([0 0.8]);
title('b2')
ylabel('frequency [Hz]')
colorbar;

set(gcf, 'Position', get(0, 'Screensize'));
cd(sdirec);
saveas(gcf, 'as_bs.png');

%plot displacement snippets where not all segments used


fs=1/0.4;
clearvars ii disp_ind
for ii = 1:length(miss_seg_ind)
   disp_ind(ii)=find(data.disp_time==miss_seg_time(ii));
   figure()
   subplot(3,1,1)
   plot(data.disp_time(disp_ind(ii)-(30*60*fs):disp_ind(ii)),data.x(disp_ind(ii)-(30*60*fs):disp_ind(ii)));
   hold on
   plot(data.disp_time(disp_ind(ii)-(30*60*fs):disp_ind(ii)),data.y(disp_ind(ii)-(30*60*fs):disp_ind(ii)));
   plot(data.disp_time(disp_ind(ii)-(30*60*fs):disp_ind(ii)),data.z(disp_ind(ii)-(30*60*fs):disp_ind(ii)));
   legend('x','y','z');
   title (strcat('time = ',datestr(data.time(miss_seg_ind(ii)-1)),'segments = ',num2str(data.segments(miss_seg_ind(ii)-1)) ,' segments used = ',num2str(data.segments_used(miss_seg_ind(ii)-1))));

   subplot(3,1,2)
   plot(data.disp_time(disp_ind(ii):disp_ind(ii)+(30*60*fs)),data.x(disp_ind(ii):disp_ind(ii)+(30*60*fs)));
   hold on
   plot(data.disp_time(disp_ind(ii):disp_ind(ii)+(30*60*fs)),data.y(disp_ind(ii):disp_ind(ii)+(30*60*fs)));
   plot(data.disp_time(disp_ind(ii):disp_ind(ii)+(30*60*fs)),data.z(disp_ind(ii):disp_ind(ii)+(30*60*fs)));
   legend('x','y','z');
   title (strcat('time = ',datestr(data.time(miss_seg_ind(ii))),'segments = ',num2str(data.segments(miss_seg_ind(ii))) ,' segments used = ',num2str(data.segments_used(miss_seg_ind(ii)))));

   subplot(3,1,3)
   plot(data.disp_time(disp_ind(ii)+(30*60*fs):disp_ind(ii)+(60*60*fs)),data.x(disp_ind(ii)+(30*60*fs):disp_ind(ii)+(60*60*fs)));
   hold on
   plot(data.disp_time(disp_ind(ii)+(30*60*fs):disp_ind(ii)+(60*60*fs)),data.y(disp_ind(ii)+(30*60*fs):disp_ind(ii)+(60*60*fs)));
   plot(data.disp_time(disp_ind(ii)+(30*60*fs):disp_ind(ii)+(60*60*fs)),data.z(disp_ind(ii)+(30*60*fs):disp_ind(ii)+(60*60*fs)));
   legend('x','y','z');
   title (strcat('time = ',datestr(data.time(miss_seg_ind(ii)+1)),'segments = ',num2str(data.segments(miss_seg_ind(ii)+1)) ,' segments used = ',num2str(data.segments_used(miss_seg_ind(ii)+1))));

end
