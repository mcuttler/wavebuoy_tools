clc
close all
clear all

cd('C:\Users\00104893\LocalDocuments\Projects\Wave buoys\Spotters\data\dashboard DLs\Bundigi_SPOT1578');

% Minderoo changes SPOT1578 out with SPOT1608, Looking to plot temps and
% look for offset in temps at time of change, to see about accuracy of
% smart mooring temp node calibration. 

fn1='SPOT-1578_2024-01-31_2024-02-22_download.csv';
fn2='SPOT-1578_2024-01-31_2024-02-22_download-sensor-data.csv';

opts1 = detectImportOptions(fn1);
vars1 = readtable(fn1,opts1);

var_names1 = opts1.VariableNames;

A=table2struct(vars1);


opts2 = detectImportOptions(fn2);
vars2 = readtable(fn2,opts2);

var_names2 = opts2.VariableNames;

A2=table2struct(vars2);

%SPOT 1608
cd('C:\Users\00104893\LocalDocuments\Projects\Wave buoys\Spotters\data\dashboard DLs\Bundigi_SPOT1608');

fn3='SPOT-1608_2024-02-18_2024-02-23_download.csv';
fn4='SPOT-1608_2024-02-18_2024-02-23_download-sensor-data.csv';

opts3 = detectImportOptions(fn3);
vars3 = readtable(fn3,opts3);

var_names3 = opts3.VariableNames;

A3=table2struct(vars3);


opts4 = detectImportOptions(fn4);
vars4 = readtable(fn4,opts4);

var_names4 = opts4.VariableNames;

A4=table2struct(vars4);

site_name(1) = "Bundigi";

for i=1:length(A2)

     S1578_sens_tvec(i) = datenum(str2num(A2(i).utc_timestamp(1:4)),str2num(A2(i).utc_timestamp(6:7))...
        ,str2num(A2(i).utc_timestamp(9:10)),str2num(A2(i).utc_timestamp(12:13))...
        ,str2num(A2(i).utc_timestamp(15:16)),str2num(A2(i).utc_timestamp(18:23)));
    
     S1578_sens_temp(i) = A2(i).value;
     S1578_sens_lat(i) = A2(i).latitude;
     S1578_sens_lon(i) = A2(i).longitude;
     
     S1578_sens_pos(i) = A2(i).sensor_position;
end

clearvars i

for i=1:length(A4)

     S1608_sens_tvec(i) = datenum(str2num(A4(i).utc_timestamp(1:4)),str2num(A4(i).utc_timestamp(6:7))...
        ,str2num(A4(i).utc_timestamp(9:10)),str2num(A4(i).utc_timestamp(12:13))...
        ,str2num(A4(i).utc_timestamp(15:16)),str2num(A4(i).utc_timestamp(18:23)));
    
     S1608_sens_temp(i) = A4(i).value;
     S1608_sens_lat(i) = A4(i).latitude;
     S1608_sens_lon(i) = A4(i).longitude;
     
     S1608_sens_pos(i) = A4(i).sensor_position;
end

clearvars i

S1608_sens1_temp=[];
S1608_sens1_tvec=[];
S1608_sens1_lat=[];
S1608_sens1_lon=[];
S1608_sens2_temp=[];
S1608_sens2_tvec=[];
S1608_sens2_lat=[];
S1608_sens2_lon=[];

for i=1:length(S1608_sens_pos)

    if S1608_sens_pos(i) == 1
        
        S1608_sens1_temp = [S1608_sens1_temp S1608_sens_temp(i)];
        S1608_sens1_tvec = [S1608_sens1_tvec S1608_sens_tvec(i)];
        S1608_sens1_lat = [S1608_sens1_lat S1608_sens_lat(i)];
        S1608_sens1_lon = [S1608_sens1_lon S1608_sens_lon(i)];
    
    else
        S1608_sens2_temp = [S1608_sens2_temp S1608_sens_temp(i)];
        S1608_sens2_tvec = [S1608_sens2_tvec S1608_sens_tvec(i)];
        S1608_sens2_lat = [S1608_sens2_lat S1608_sens_lat(i)];
        S1608_sens2_lon = [S1608_sens2_lon S1608_sens_lon(i)];
            
    end
    
    
end

clearvars i

S1578_sens1_temp=[];
S1578_sens1_tvec=[];
S1578_sens1_lat=[];
S1578_sens1_lon=[];
S1578_sens2_temp=[];
S1578_sens2_tvec=[];
S1578_sens2_lat=[];
S1578_sens2_lon=[];

for i=1:length(S1578_sens_pos)

    if S1578_sens_pos(i) == 1
        
        S1578_sens1_temp = [S1578_sens1_temp S1578_sens_temp(i)];
        S1578_sens1_tvec = [S1578_sens1_tvec S1578_sens_tvec(i)];
        S1578_sens1_lat = [S1578_sens1_lat S1578_sens_lat(i)];
        S1578_sens1_lon = [S1578_sens1_lon S1578_sens_lon(i)];
    
    else
        S1578_sens2_temp = [S1578_sens2_temp S1578_sens_temp(i)];
        S1578_sens2_tvec = [S1578_sens2_tvec S1578_sens_tvec(i)];
        S1578_sens2_lat = [S1578_sens2_lat S1578_sens_lat(i)];
        S1578_sens2_lon = [S1578_sens2_lon S1578_sens_lon(i)];
            
    end
    
    
end


% plots

figure
subplot(3,1,1)

plot(S1578_sens1_tvec,S1578_sens1_temp,'-*')
hold on
plot(S1608_sens1_tvec,S1608_sens1_temp,'r-*')
title('Sensor1 (surface, always?) Temp')
xlim([7.392982405913979e+05 7.393028319892474e+05])
legend('SPOT1578','SPOT1608')
datetick;

subplot(3,1,2)

plot(S1578_sens2_tvec,S1578_sens2_temp,'-*')
hold on
plot(S1608_sens2_tvec,S1608_sens2_temp,'r-*')
xlim([7.392982405913979e+05 7.393028319892474e+05])
title('Sensor2 (bottom, always?) Temp')
legend('SPOT1578','SPOT1608')
datetick;

subplot(3,1,3)


plot(S1578_sens1_tvec,S1578_sens1_lat,'-*')
hold on
plot(S1608_sens1_tvec,S1608_sens1_lat,'r-*')
xlim([7.392982405913979e+05 7.393028319892474e+05])
title('Sensor1 Lat')
legend('SPOT1578','SPOT1608')
datetick;




[xgrab ygrab] = ginput(2);


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

%saving figures

cd('C:\Users\00104893\LocalDocuments\IMOS NPT\Analysis\Downloaded_VicWaves_CapeBridgewater_20210429\Figures');

saveas(figure(1),'CapeBridgewater_FB_BPs.png');
saveas(figure(2),'CapeBridgewater_FB_Location.png');
saveas(figure(4),'CapeBridgewater_FB_Location_Wave_Event.png');

