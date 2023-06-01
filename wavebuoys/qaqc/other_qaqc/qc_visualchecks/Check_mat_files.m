% code for looking at Spotter data from Matlab files from Parser.
% "bulkparams, locations, spec, displacements etc.



figure()
scatter(locations.lon, locations.lat)

figure()
subplot(2,1,1)
plot(locations.time,locations.lat)
title('lat')
datetick;
subplot(2,1,2)
plot(locations.time,locations.lon)
title('lon')
datetick


figure()


for ii=1:length(spec.time)

plot(spec.freq(1,:),spec.Szz(ii,:))
ylim([0 2])
title(datestr(spec.time(ii)))
pause (0.001)


clf

end


figure()
subplot(3,1,1)
imagesc(spec.Szz',[0 3])
set(gca,'YDir','normal')


subplot(3,1,2)
imagesc(spec.Sxx',[0 2])
set(gca,'YDir','normal')
subplot(3,1,3)
imagesc(spec.Syy',[0 2])
set(gca,'YDir','normal')




figure()
for ii=1:length(spec.time)

plot(spec.freq(1,:),spec.Szz(ii,:))
hold on
plot(spec.freq(1,:),spec.Sxx(ii,:))
plot(spec.freq(1,:),spec.Syy(ii,:))
ylim([0 1])
legend('Szz','Sxx','Syy')
title(datestr(spec.time(ii)))
pause (0.001)

clf

end

figure()

for ii=1:length(spec.time)

subplot(3,1,1)
plot(spec.freq(1,:),spec.Szz(ii,:))
hold on
plot(spec.freq(1,:),spec.Sxx(ii,:))
plot(spec.freq(1,:),spec.Syy(ii,:))
ylim([0 1])
legend('Szz','Sxx','Syy')
title(datestr(spec.time(ii)))

subplot(3,1,2)
scatter(bulkparams.lon(ii),bulkparams.lat(ii))
pause (0.01)

clf
end

% Subflag labelling

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

% flag and subflag percentages

figure()
histogram(data.qc_flag_wave,'Normalization','pdf')

figure()
histogram(data.qc_subflag_wave,[-127:-1 0:36],'Normalization','pdf')


subflag_labels = cellstr(num2str(data.qc_subflag_wave));
dx = 0.01; dy = 0.01; % displacement so the text does not overlay the data points

figure(); 
h(1) = plot(data.time, data.hs);
hold on; grid on;
if any(data.qc_flag_wave==3)
h(2) = plot(data.time(data.qc_flag_wave==3), data.hs(data.qc_flag_wave==3),'co'); 
text(data.time(data.qc_flag_wave==3)+dx,data.hs(data.qc_flag_wave==3)+dy, subflag_labels(data.qc_flag_wave==3));
end
if any(data.qc_flag_wave==4)
h(3) = plot(data.time(data.qc_flag_wave==4), data.hs(data.qc_flag_wave==4),'ro'); 
text(data.time(data.qc_flag_wave==4)+dx,data.hs(data.qc_flag_wave==4)+dy, subflag_labels(data.qc_flag_wave==4));
end
datetick('x','dd-mmm'); 
ylabel('hs (m)'); 

figure()
plot(data.time, data.tm); 
hold on; grid on;
plot(data.time, data.tp,'r'); 
if any(data.qc_flag_wave==3)
h(2) = plot(data.time(data.qc_flag_wave==3), data.tp(data.qc_flag_wave==3),'co');
text(data.time(data.qc_flag_wave==3)+dx,data.tp(data.qc_flag_wave==3)+dy, subflag_labels(data.qc_flag_wave==3));
end
if any(data.qc_flag_wave==4)
h(3) = plot(data.time(data.qc_flag_wave==4), data.tp(data.qc_flag_wave==4),'ko'); 
text(data.time(data.qc_flag_wave==4)+dx,data.tp(data.qc_flag_wave==4)+dy, subflag_labels(data.qc_flag_wave==4));
end
datetick('x','dd-mmm');
ylabel('tm, tp (s)'); 


figure()
plot(data.time, data.dm); 
hold on; grid on; 
plot(data.time, data.dp,'r'); 
if any(data.qc_flag_wave==3)
h(2) = plot(data.time(data.qc_flag_wave==3), data.dp(data.qc_flag_wave==3),'co');
text(data.time(data.qc_flag_wave==3)+dx,data.dp(data.qc_flag_wave==3)+dy, subflag_labels(data.qc_flag_wave==3));
end
if any(data.qc_flag_wave==4)
h(3) = plot(data.time(data.qc_flag_wave==4), data.dp(data.qc_flag_wave==4),'ko'); 
text(data.time(data.qc_flag_wave==4)+dx,data.dp(data.qc_flag_wave==4)+dy, subflag_labels(data.qc_flag_wave==4));
end
datetick('x','dd-mmm');
ylabel('SSWMD, WPDI (deg from)'); 
legend('SSWMD','WPDI')


figure()
scatter(data.time, data.qc_flag_wave); 
hold on; grid on;
datetick('x','dd-mmm');
ylabel('WAVE quality control'); 


