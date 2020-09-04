%% plot drifting buoy, delayed mode
datapath = 'E:\Active_Projects\LOWE_IMOS_WaveBuoys\Data\SofarSpotter\SPOT0093_PerthCanyon_20191015_to_20200903'; 
locations = importdata([datapath '\location.csv']);
bulkparams = importdata([datapath '\bulkparameters.csv']);

%%
for i = 1:size(bulkparams.data,1)
    disp(['Crunching ' num2str(i) ' out of ' num2str(size(bulkparams.data,1)) '...']); 
    %find closest time point, if greater than 5 min
    
    idx = find(abs(datenum(bulkparams.data(i,1:6))-datenum(locations.data(:,1:6)))==min(abs(datenum(bulkparams.data(i,1:6))-datenum(locations.data(:,1:6))))); 
    %check if empty
    if ~isempty(idx)
        %if not empty but more than 1 corresponding location point averge
        if length(idx)>1
            buoy.lat(i,1) = mean(locations.data(idx,8)); 
            buoy.lon(i,1) = mean(locations.data(idx,9)); 
            buoy.hs(i,1) = bulkparams.data(i,8);
         %if not empty and only 1 point, make sure not more than 5 minutes
         %apart 
        else
            if abs(datenum(bulkparams.data(i,1:6))-datenum(locations.data(:,1:6)))>5/1440 %5 minutes
                buoy.lat(i,1) = nan;
                buoy.lon(i,1) = nan; 
                buoy.hs(i,1) = nan; 
            else
                buoy.lat(i,1) = locations.data(idx,8);
                buoy.lon(i,1) = locations.data(idx,9); 
                buoy.hs(i,1) = bulkparams.data(i,8); 
            end
        end
     %if empty fill with nan
    else
        buoy.lat(i,1) = nan;
        buoy.lon(i,1) = nan; 
        buoy.hs(i,1) = nan; 
    end
    
end
%% figure;
addpath('C:\Users\00084142\Dropbox\matlab\MCuttler\File_exchange')
fid = figure;
start = 1575; 
for i = start:10:size(buoy.lat); 
    ax(1) = subplot(2,1,1); 
    geoshow('landareas.shp', 'FaceColor', [0.5 0.5 0.5]);
    hold on
    if i ==start
        plot(buoy.lon(i), buoy.lat(i), 'r.','markersize',18); 
    else
        plot(buoy.lon(start:i), buoy.lat(start:i), 'b.','markersize',6);
        hold on
        plot(buoy.lon(i), buoy.lat(i), 'r.','markersize',18);         
    end
    set(ax(1),'xlim',[105 125],'ylim',[-40 -10]);
    xlabel('Longitude (deg)'); 
    ylabel('Latitude (deg)'); 
    hold off;
    
    ax(2) = subplot(2,1,2); 
    plot(datenum(bulkparams.data(:,1:6)), buoy.hs,'k-'); 
    hold on; grid on; 
    plot(datenum(bulkparams.data(i,1:6)), buoy.hs(i),'r.','markersize',18);     
    set(gca,'xlim',[datenum(bulkparams.data(start,1:6)) datenum(2020,09,05)], 'xtick',...
        [datenum(2020,02,05), datenum(2020, 03, 05), datenum(2020, 04, 05), datenum(2020, 05, 05),...
        datenum(2020,06,05), datenum(2020,07,05), datenum(2020,08,05), datenum(2020,09,05)]); 
    datetick('x','dd-mmm-yy','keepticks'); 
    set(gca,'xlim',[datenum(bulkparams.data(start,1:6)) datenum(2020,09,05)]); 
    ylabel('Wave Height (m)'); 
    xlabel('Date'); 
    hold off; 
    
    set(gcf, 'PaperPositionMode', 'manual','PaperUnits','centimeters','units','centimeters',...
        'position',[1 1 17 16], 'PaperPosition', [0 0 17 16],'color','w')
    set(ax,'box','on','units','centimeters'); 
    set(ax(1), 'Position', [2.5 6 12 8]); 
    set(ax(2),'Position', [1.5 1.5 14.5 3]);     
    if i == start                         
        % Create a new gif file and write the first frame: 
        gif(['E:\Active_Projects\LOWE_IMOS_WaveBuoys\Data\SofarSpotter\ProcessedData_DelayedMode\Figures\SPOT0093_PerthCanyon_Drifting.gif'],'DelayTime',0.05,'LoopCount',5,'frame',gcf)
    else
        % Loop through every other frame.
        gif
    end    
  
end




