clc
close all
clear all

cd('C:\Users\00104893\LocalDocuments\Projects\Wave buoys\Spotters\data\Dash_DL_CygnetBay');

% Cape Bridgewater FB Spotter Downloaded to look at potential mooring
% movements

fn1='SPOT-30959C_CygnetBay_2024-01-22_2024-01-31_download.csv';

station_name(1) = "Cygnet Bay";


opts1 = detectImportOptions(fn1);
BP1 = readmatrix(fn1);

var_names1 = opts1.VariableNames;

% convert to datetime from "unix_timestamp", note didn't account for a
% timezone, so this conversion assumes Unix_timestamps are in UTC. this is
% likely incorrect. Expect they are set to Timezone of Melbourne Victoria

tvec1 = datetime(BP1(:,1),'ConvertFrom','posixtime');

t_st = datetime(2021,04,01,00,00,00) ;
t_end = datetime(2021,04,18,00,00,00) ;

[jnk_min tsi] = min(abs(tvec1-t_st));
[jnk_min tei] = min(abs(tvec1-t_end));



figure()
subplot(4,1,1)
plot(tvec1(tsi:tei),BP1((tsi:tei),9),'*-')

title ('Cape Bridgewater FB Hs');
ylabel ('m')

subplot(4,1,2)
plot(tvec1(tsi:tei),BP1((tsi:tei),10),'*-')

title ('Tp');
ylabel ('s')

subplot(4,1,3)
plot(tvec1(tsi:tei),BP1((tsi:tei),11),'*-')

title ('Tm');
ylabel ('s')

subplot(4,1,4)
plot(tvec1(tsi:tei),BP1((tsi:tei),12),'*-')

title ('Dir peak');
ylabel ('deg')


% Convert locations to M

%first find center of original mooring

t_st = datetime(2021,03,10,00,00,00) ;
t_end = datetime(2021,03,31,00,00,00) ;

[jnk_min tsi] = min(abs(tvec1-t_st));
[jnk_min tei] = min(abs(tvec1-t_end));

lat_mooring = mean(BP1(tsi:tei,16));
lon_mooring = mean(BP1(tsi:tei,17));

% at Lat 38: 1 deg lat= 110996.45m, 1 deg lon = 87832.43m

lat_m= (BP1(:,16) - lat_mooring)*110996.45;
lon_m=(BP1(:,17) - lon_mooring)*87832.43;

%plot bouy location

figure()
pointsize = 14;      %adjust as needed
numpoints = length(lat_m)
pointidx = 1 : numpoints;
scatter(lon_m,lat_m, pointsize, pointidx);
colormap( jet(numpoints) )
colorbar
title(strcat(datestr(tvec1(1)),'to',datestr(tvec1(end))))
xlabel('m');
ylabel('m');

figure()
scatter(lon_m(tsi:tei),lat_m(tsi:tei))

%Look just at swell event

t_st = datetime(2021,04,01,00,00,00) ;
t_end = datetime(2021,04,18,00,00,00) ;

[jnk_min tsi] = min(abs(tvec1-t_st));
[jnk_min tei] = min(abs(tvec1-t_end));


figure()
subplot(2,1,1)

ylabel (station_name(1))
pointsize = 14;      %adjust as needed
numpoints = length(tvec1(tsi:tei))
pointidx = 1 : numpoints;
scatter(tvec1(tsi:tei),BP1(tsi:tei,9), pointsize, pointidx)
colormap( jet(numpoints) )
colorbar

title ('Hs');
ylabel('m');

subplot(2,1,2)
pointsize = 14;      %adjust as needed
numpoints = length(lat_m(tsi:tei))
pointidx = 1 : numpoints;
scatter(lon_m(tsi:tei),lat_m(tsi:tei), pointsize, pointidx);
colormap( jet(numpoints) )
colorbar
xlabel('m');
ylabel('m');
title('Location');

return

%Section fro Smart mooring data if required







%saving figures

cd('C:\Users\00104893\LocalDocuments\IMOS NPT\Analysis\Downloaded_VicWaves_CapeBridgewater_20210429\Figures');

saveas(figure(1),'CapeBridgewater_FB_BPs.png');
saveas(figure(2),'CapeBridgewater_FB_Location.png');
saveas(figure(4),'CapeBridgewater_FB_Location_Wave_Event.png');

