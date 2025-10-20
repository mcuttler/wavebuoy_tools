%% netCDF checker

%Run this code after processing a wave buoy memory card to check final
%results. 
%Use figures in this code to update the buoy_info metadata CSV that was
%used for netCDF generation and update as needed to re-run 

%2025-03: 
%   - file creation - MC

%% read nc files 
clear; clc; 

dpath = 'X:\CUTTLER_wawaves\Data\wawaves\OceanBeach\delayedmode\ProcessedData_DelayedMode'; 
nc_int =  'UWA_20240701_OCEAN-BEACH_DM_WAVE-PARAMETERS_20241204.nc'; 
nc_spec = 'UWA_20240701_OCEAN-BEACH_DM_WAVE-SPECTRA_20241204.nc'; 
nc_disp = 'UWA_20241007_OCEAN-BEACH_DM_WAVE-RAW-DISPLACEMENTS_20241021.nc'; 


info = ncinfo(fullfile(dpath,nc_int)); 
for i = 1:length(info.Variables)
    bulkparams.(info.Variables(i).Name) = ncread(fullfile(dpath,nc_int),info.Variables(i).Name); 
    if strcmp(info.Variables(i).Name,'TIME')
        bulkparams.TIME = datetime(bulkparams.TIME+datenum(1950,1,1),'convertfrom','datenum');
    end

end

%spectra
info = ncinfo(fullfile(dpath,nc_spec)); 
for i = 1:length(info.Variables)
    spec.(info.Variables(i).Name) = ncread(fullfile(dpath,nc_spec),info.Variables(i).Name); 
    if strcmp(info.Variables(i).Name,'TIME')
        spec.TIME = datetime(spec.TIME+datenum(1950,1,1),'convertfrom','datenum'); 
    end
end

%displacements
% info = ncinfo(fullfile(dpath,nc_disp)); 
% for i = 1:length(info.Variables)
%     spec.(info.Variables(i).Name) = ncread(fullfile(dpath,nc_disp),info.Variables(i).Name); 
% end

%% make bulk params figures

vars = {'WSSH','WPFM','WPPE','SSWMD','WPDI','WMDS','WPDS'}; 
labels = {'Hs','Tm','Tp','Dm','Dp','DmSpr','DpSpr'}; 

fid = figure; 
for i = 1:size(vars,2)
    ax(i) = subplot(size(vars,2),1,i);
    plot(bulkparams.TIME, bulkparams.(vars{i})); 
    hold on; grid on; 
    plot(bulkparams.TIME(bulkparams.WAVE_quality_control>1), bulkparams.(vars{i})(bulkparams.WAVE_quality_control>1),'ro')
    ylabel(labels{i});    
    set(gca,'xlim',[bulkparams.TIME(1) bulkparams.TIME(end)]); 
    if i == 1
        flag_per = sum(bulkparams.WAVE_quality_control>1)/size(bulkparams.TIME,1); 
        text(0.05, 1.15, ['flagged percentage = ' num2str(round(flag_per,2)) '%'],'units','normalized','fontweight','bold'); 
         ll = legend('data','flagged data');          
    end
end

set(fid, 'PaperPositionMode', 'manual','PaperUnits','centimeters','units','centimeters',...
    'position',[1 1 22 22], 'PaperPosition', [0 0 22 22],'color','w')
ll.Units = 'centimeters';
ll.Position(2) = ll.Position(2)+0.75;
clear ax; 

%% plot lat/lon

%make timetable for re-averaging to ID times when anchor moved - could
%potenitally try to do something with fortnightly averaged positions...
positions = timetable(bulkparams.LATITUDE, bulkparams.LONGITUDE,'RowTimes',bulkparams.TIME,'VariableNames',{'latitude','longitude'}); 
positions_fortnightly = retime(positions,'regular',@nanmean,'TimeStep',days(14)); 

fid = figure;
set(fid, 'PaperPositionMode', 'manual','PaperUnits','centimeters','units','centimeters',...
    'position',[1 1 26 12], 'PaperPosition', [0 0 26 12],'color','w')

ax(1) = subplot(1,2,1);
geoscatter(bulkparams.LATITUDE, bulkparams.LONGITUDE,22,datenum(bulkparams.TIME),'filled'); 
c = colorbar; 
c.Label.String = 'time (datenum)'; 
geolimits([nanmean(bulkparams.LATITUDE)-0.25 nanmean(bulkparams.LATITUDE)+0.25],...
    [nanmean(bulkparams.LONGITUDE)-0.25 nanmean(bulkparams.LONGITUDE)+0.25]); 

ax(2) = subplot(1,2,2);
geoscatter(bulkparams.LATITUDE, bulkparams.LONGITUDE,12,datenum(bulkparams.TIME),'filled'); 
c = colorbar; 
c.Label.String = 'time (datenum)'; 


fid = figure; clear ax 
set(fid, 'PaperPositionMode', 'manual','PaperUnits','centimeters','units','centimeters',...
    'position',[1 1 26 12], 'PaperPosition', [0 0 26 12],'color','w')

ax(1) = subplot(1,2,1);
plot(positions.Time, positions.latitude); hold on; grid on;
xlabel('Time'); ylabel('Latitude'); 

ax(2) = subplot(1,2,2);
plot(positions.Time, positions.longitude); hold on; grid on;
xlabel('Time'); ylabel('Longitude'); 

set(ax,'box','on','units','centimeters'); 
 %%




