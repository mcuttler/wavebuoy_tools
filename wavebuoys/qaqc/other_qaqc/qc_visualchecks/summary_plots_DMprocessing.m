
% save directory

sdirec = 'C:\Users\00104893\LocalDocuments\Projects\Wave buoys\Spotters\data\cape-bridgewater_deploy20240618_retrieve20241027_SPOT31670C\processed\summary';

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
C = load('coastlines');
plot(C.coastlon,C.coastlat,'k')
xlim([min(gps_o.longitude)-0.5 max(gps_o.longitude)+0.5]);
ylim([min(gps_o.latitude)-0.5 max(gps_o.latitude)+0.55]);
ylabel('latitude [deg]')
xlabel('longitude [deg]')
legend('measured position','metadata deploy location');

subplot(2,2,4)
scatter(gps_o.longitude,gps_o.latitude,'.');
title('whole record buoy position')
hold on
scatter(buoy_info.DeployLon,buoy_info.DeployLat,80,'red','filled');
C = load('coastlines');
plot(C.coastlon,C.coastlat,'k')
xlim([buoy_info.DeployLon-0.003 buoy_info.DeployLon+0.003]);
ylim([buoy_info.DeployLat-0.003 buoy_info.DeployLat+0.003]);
ylabel('latitude [deg]')
xlabel('longitude [deg]')

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
plot(gps.Time,gps.longitude);
title('clipped longitude')
subplot(2,2,2)
plot(gps.Time,gps.latitude);
title('clipped latitude')
subplot(2,2,3)
plot(gps.longitude,gps.latitude);
title('clipped buoy position')
hold on
scatter(buoy_info.DeployLon,buoy_info.DeployLat,80,'red','filled');
C = load('coastlines');
plot(C.coastlon,C.coastlat,'k')
xlim([min(gps_o.longitude)-0.5 max(gps_o.longitude)+0.5]);
ylim([min(gps_o.latitude)-0.5 max(gps_o.latitude)+0.55]);

subplot(2,2,4)
scatter(gps.longitude,gps.latitude,'.');
title('clipped buoy position')
hold on
scatter(buoy_info.DeployLon,buoy_info.DeployLat,80,'red','filled');
C = load('coastlines');
plot(C.coastlon,C.coastlat,'k')
xlim([buoy_info.DeployLon-0.001 buoy_info.DeployLon+0.001]);
ylim([buoy_info.DeployLat-0.001 buoy_info.DeployLat+0.001]);

% plot positions comparison
figure()
subplot(3,2,1)
plot(gps_o.Time,gps_o.longitude,'--');
hold on
plot(gps.Time,gps.longitude,'r');
title('longitude clip comparison')
xlim([gps_o.Time(1) gps_o.Time(700)])
legend('whole record','clipped')
subplot(3,2,2)
plot(gps_o.Time,gps_o.longitude,'--');
hold on
plot(gps.Time,gps.longitude,'r');
title('longitude clip comparison')
xlim([gps_o.Time(end-6000) gps_o.Time(end)])
legend('whole record','clipped')
subplot(3,2,3)
plot(gps_o.Time,gps_o.latitude,'--');
hold on
plot(gps.Time,gps.latitude,'r');
title('latitude clip comparison')
xlim([gps_o.Time(1) gps_o.Time(700)])
legend('whole record','clipped')
subplot(3,2,4)
plot(gps_o.Time,gps_o.latitude,'--');
hold on
plot(gps.Time,gps.latitude,'r');
title('latitude clip comparison')
xlim([gps_o.Time(end-6000) gps_o.Time(end)])
legend('whole record','clipped')

subplot(3,2,5)
plot(gps_o.longitude,gps_o.latitude);
title('buoy position')
hold on
plot(gps.longitude,gps.latitude,'k.');
scatter(buoy_info.DeployLon,buoy_info.DeployLat,80,'red','filled');
C = load('coastlines');
plot(C.coastlon,C.coastlat,'k')
xlim([min(gps_o.longitude)-0.5 max(gps_o.longitude)+0.5]);
ylim([min(gps_o.latitude)-0.5 max(gps_o.latitude)+0.55]);
legend('whole','clipped','deploy loc','coast')

subplot(3,2,6)
scatter(gps_o.longitude,gps_o.latitude);
title('buoy position')
hold on
scatter(gps.longitude,gps.latitude,'k.');
scatter(buoy_info.DeployLon,buoy_info.DeployLat,80,'red','filled');
C = load('coastlines');
plot(C.coastlon,C.coastlat,'k')
xlim([buoy_info.DeployLon-0.002 buoy_info.DeployLon+0.002]);
ylim([buoy_info.DeployLat-0.002 buoy_info.DeployLat+0.002]);
legend('whole','clipped','deploy loc','coast')

% plot displacements comparison
figure()
subplot(3,1,1)
plot(disp_o.Time,disp_o.x);
hold on
plot(data.disp_time,data.x);
title('X disp clipped');
legend('whole record','clipped')
subplot(3,1,2)
plot(disp_o.Time,disp_o.y);
hold on
plot(data.disp_time,data.y);
title('Y disp clipped');
legend('whole record','clipped')
subplot(3,1,3)
plot(disp_o.Time,disp_o.z);
hold on
plot(data.disp_time,data.z);
title('Z disp clipped');
legend('whole record','clipped')

%plot disp comparison start and end

figure()
subplot(3,2,1)
plot(disp_o.Time,disp_o.x);
hold on
plot(data.disp_time,data.x);
xlim([disp_o.Time(1)-0.3 data.disp_time(1)+0.3])
title('X disp');
legend('whole record','clipped')
subplot(3,2,2)
plot(disp_o.Time,disp_o.x);
hold on
plot(data.disp_time,data.x);
xlim([data.disp_time(end)-0.3 disp_o.Time(end)+0.3])
title('X disp');

subplot(3,2,3)
plot(disp_o.Time,disp_o.y);
hold on
plot(data.disp_time,data.y);
xlim([disp_o.Time(1)-0.3 data.disp_time(1)+0.3])
title('Y disp');
subplot(3,2,4)
plot(disp_o.Time,disp_o.y);
hold on
plot(data.disp_time,data.y);
xlim([data.disp_time(end)-0.3 disp_o.Time(end)+0.3])
title('Y disp');

subplot(3,2,5)
plot(disp_o.Time,disp_o.z);
hold on
plot(data.disp_time,data.z);
xlim([disp_o.Time(1)-0.3 data.disp_time(1)+0.3])
title('Z disp');
subplot(3,2,6)
plot(disp_o.Time,disp_o.z);
hold on
plot(data.disp_time,data.z);
xlim([data.disp_time(end)-0.3 disp_o.Time(end)+0.3])
title('Z disp');

%plot comparison clipped suurface temp and baro

figure()
subplot(2,1,1)
plot(surface_temp_o.Time,surface_temp_o.temperature);
hold on
plot(surface_temp.Time,surface_temp.temperature);
legend('whole record','clipped')
title ('surface temp');
subplot(2,1,2)
plot(baro_o.Time,baro_o.baro_pressure);
hold on
plot(baro.Time,baro.baro_pressure);
title ('barometer');

% plot diff T-VECS for clipped data

figure()
subplot(4,1,1)
plot(datenum(data.disp_time(2:end)),(24*60*60)*datenum(diff(data.disp_time)));
title ('diff tvec displacements clipped ');
%ylim([0.3 time2num(max(diff(data.disp_time)),seconds)+1])

subplot(4,1,2)
plot(datenum(gps.Time(2:end)),(24*60*60)*datenum(diff(gps.Time)));
title ('diff tvec gps clipped ');
%ylim([55 time2num(max(diff(gps.Time)),seconds)])

subplot(4,1,3)
plot(datenum(surface_temp.Time(2:end)),(24*60*60)*datenum(diff(surface_temp.Time)));
title ('diff tvec surface_temp clipped ');
%ylim([55 time2num(max(diff(surface_temp.Time)),seconds)])

subplot(4,1,4)
plot(datenum(baro.Time(2:end)),(24*60*60)*datenum(diff(baro.Time)));
title ('diff tvec baro clipped ');
%ylim([55 time2num(max(diff(baro.Time)),seconds)])



%calculate max hight in segment from upcrossing
for ii = 1: length(data.height_0)
    height_0_max(ii) = max(cell2mat(data.height_0(ii)));
end



% plot Spectral processing outputs
figure()
subplot(2,1,1)
plot(data.time,data.hs)
hold on
plot(data.time,data.hrms)
plot(data.time,data.hsSwell)
plot(data.time,data.hsSea)
plot(data.time,cell2mat(data.hs_0),'k--')
plot(data.time,height_0_max,'k')
legend('hs','hrms','hswell','hsea','height0','height0 max')

subplot(2,1,2)
plot(data.time,data.tp)
hold on
plot(data.time,data.tm)
plot(data.time,data.tm2)
plot(data.time,data.tmSwell)
plot(data.time,data.tm2Swell)
plot(data.time,data.tmSea)
plot(data.time,data.tm2Sea)
plot(data.time,cell2mat(data.tz_0),'k--')
legend('tp','tm','tm2','tmswell','tm2swell','tmSea','tm2sea','tz_0')


%plot more Spec processing outputs

figure()

subplot(2,1,1)
plot(data.time,data.dp)
hold on
plot(data.time,data.dm)
plot(data.time,data.dm2)
plot(data.time,data.dmSwell)
plot(data.time,data.dm2Swell)
plot(data.time,data.dmSea,'k')
plot(data.time,data.dm2Sea)
legend('dp','dm','dm2','dmswell','dm2swell','dmSea','dm2sea')

subplot(2,1,2)
plot(data.time,data.dpspr)
hold on
plot(data.time,data.dmspr)
plot(data.time,data.dmsprSwell)
plot(data.time,data.dmsprSea)
legend('dpspr','dmspr','dmsprSwell','dmsprSea');

% plots segement and segments used and spectral processed time vec
figure()
subplot(3,1,1)
plot(data.time)
title('time')

subplot(3,1,2)
plot(data.time(2:end),diff(data.time));
title('diff tvec)');
ylim([duration(0,0,0) duration(1,0,0)]);

subplot(3,1,3)
plot(data.time,data.segments)
hold on
plot(data.time,data.segments_used)
ylim([min(data.segments_used)-1 max(data.segments_used)+1])
legend('segments','segements used')

%segment stats

per_segs_notused=((sum(data.segments)-sum(data.segments_used))/sum(data.segments))*100;

%plotQC wave flags
figure()
subplot(3,1,1)
plot(data.time,data.segments)
hold on
plot(data.time,data.segments_used)
ylim([min(data.segments_used)-1 max(data.segments_used)+1])
legend('segments','segements used')

subplot(3,1,2)
plot(data.time,data.qc_flag_wave)
title('wave flag')

subplot(3,1,3)
plot(data.time,data.qc_subflag_wave)
title('wave subflag')

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
scatter(miss_seg_time,ones(1,length(miss_seg_time))*0.3,'ro')

%ylim([0 0.5]);
title('energy')
colorbar;

subplot(3,1,2)
imagesc(data.time,(data.frequency),10*log10(data.energy'))
set(gca,'YDir','normal')
%caxis([0 0.2]);
%ylim([0 0.5]);
hold on
scatter(miss_seg_time,ones(1,length(miss_seg_time))*0.3,'ro')
title('energy dB arb ref')
colorbar;

subplot(3,1,3)
imagesc(data.time,(data.frequency),data.check_fact')
set(gca,'YDir','normal')
caxis([0 10]);
hold on
scatter(miss_seg_time,ones(1,length(miss_seg_time))*0.3,'ro')

%ylim([0 0.5]);
title('check factor')
colorbar

figure()
subplot(3,1,1)
imagesc(data.time,(data.frequency),data.energy')
set(gca,'YDir','normal')
caxis([0 1]);
hold on
scatter(miss_seg_time,ones(1,length(miss_seg_time))*0.3,'ro')

ylim([0 0.5]);
title('energy')
colorbar;

subplot(3,1,2)
imagesc(data.time,(data.frequency),10*log10(data.energy'))
set(gca,'YDir','normal')
%caxis([0 0.2]);
ylim([0 0.5]);
hold on
scatter(miss_seg_time,ones(1,length(miss_seg_time))*0.3,'ro')
title('energy dB arb ref')
colorbar;

subplot(3,1,3)
imagesc(data.time,(data.frequency),data.check_fact')
set(gca,'YDir','normal')
caxis([0 2]);
ylim([0 0.5]);
hold on
scatter(miss_seg_time,ones(1,length(miss_seg_time))*0.3,'ro')
title('check factor')
colorbar


%plot a's, b's
figure()
subplot(4,1,1)
imagesc(data.time,(data.frequency),data.a1')
set(gca,'YDir','normal')
%caxis([0 1.5]);
ylim([0 0.8]);
title('a1')
colorbar;

subplot(4,1,2)
imagesc(data.time,(data.frequency),data.a2')
set(gca,'YDir','normal')
%caxis([0 1.5]);
ylim([0 0.8]);
title('a2')
colorbar;

subplot(4,1,3)
imagesc(data.time,(data.frequency),data.b1')
set(gca,'YDir','normal')
%caxis([0 1.5]);
ylim([0 0.8]);
title('b1')
colorbar;
subplot(4,1,4)
imagesc(data.time,(data.frequency),data.b2')
set(gca,'YDir','normal')
%caxis([0 1.5]);
ylim([0 0.8]);
title('b2')
colorbar;

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
