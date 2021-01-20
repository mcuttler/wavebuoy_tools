%% Make SST plot from wave buoy SST

%grabs NOAA SST data for region around wave buoy and plots

function [] = make_SST_plot(buoy_info, temp_time, temp, plot_idx); 

url =  'https://pae-paha.pacioos.hawaii.edu/thredds/dodsC/dhw_5km'; 
noaa.time = (double(ncread(url,'time'))./(60*60*24))+datenum(1981,1,1); 
noaa.lat = ncread(url,'latitude'); 
noaa.lon = ncread(url,'longitude'); 

%isolate lat and lon for range within wave buoy - may need to be tweaked to
%make figure pretty
idxlat = find(abs(noaa.lat-buoy_info.DeployLat)==min(abs(noaa.lat-buoy_info.DeployLat)));
idxlon = find(abs(noaa.lon-buoy_info.DeployLon)==min(abs(noaa.lon-buoy_info.DeployLon)));

lat_range = idxlat-10:idxlat+10; 
lon_range = idxlon-10:idxlon+10; 
[x,y] = meshgrid(noaa.lon(lon_range), noaa.lat(lat_range)); 

% plot all times
if plot_idx==0
    for ii = 1:size(temp_time,1)
        
    end
else
    for ii = 1:size(plot_idx)
        tidx = find(abs(noaa.time-temp_time(plot_idx))==min(abs(noaa.time-temp_time(plot_idx))));
        noaa.sst = ncread(url,'CRW_SST',[lon_range(1) lat_range(1) tidx],[length(lon_range) length(lat_range) 1])';
        mask = isnan(noaa.sst); 
        
        ax(1) = subplot(211); 
        scatter(x(mask), y(mask),25, [0.5 0.5 0.5],'filled');
        hold on;        
        pcolor(x,y,noaa.sst); shading interp;                                 
        plot(buoy_info.DeployLon, buoy_info.DeployLat,'r.','markersize',18);         
        title(['NOAA SST - ' datestr(noaa.time(tidx),'dd-mmm-yyyy')]); 
        xlabel('Longtiude'); 
        ylabel('Latitude'); 
        
        ax(2) = subplot(212);
        plot(temp_time, temp,'k-','linewidth',1.5); 
        grid on;
        set(gca,'xlim',[temp_time(plot_idx)-2 temp_time(plot_idx)]); 
        datetick('x','dd-mm HH:MM','keepticks');        
        set(gca,'xlim',[temp_time(plot_idx)-2 temp_time(plot_idx)],'ylim',[min(temp)-0.5 max(temp)+0.5]); 
        
        ylabel('SST (degC)'); 
        xlabel('Date (dd-mmm-yy)'); 
        
        
    end
    
        






end

