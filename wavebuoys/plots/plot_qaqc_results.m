%% plots QAQC results for height, period, direction

function [] = plot_qaqc_results(bulkparams)


%% wave height 
fidhs = figure;
plot(bulkparams.time, bulkparams.hs); 
hold on; 
grid on; 
ylabel('Hs (m)'); 
set(gca,'xlim',[bulkparams.time(1) bulkparams.time(end)],'xtick',linspace(bulkparams.time(1), bulkparams.time(end),12)); 
datetick('x','dd-mmm','keepticks'); 
set(gca,'xlim',[bulkparams.time(1) bulkparams.time(end)]); 
%only look for fails 
idx15 = find(bulkparams.qf15(:,1)>1); 
idx16 = find(bulkparams.qf16(:,1)>1); 
idx19 = find(bulkparams.qf19>1); 
idxlim = find(bulkparams.qf_lims(:,1)>1); 
clear h; 

if isempty(idx15)
    h(1) = plot(0,0,'ro'); 
else
    h(1) = plot(bulkparams.time(idx15), bulkparams.hs(idx15),'ro','linewidth',2); 
end

if isempty(idx16)
    h(2) = plot(0,0,'go'); 
else
    h(2) = plot(bulkparams.time(idx16), bulkparams.hs(idx16),'go','linewidth',2); 
end

if isempty(idx19)
    h(3) = plot(0,0,'yo'); 
else
    h(3) = plot(bulkparams.time(idx19), bulkparams.hs(idx19),'yo','linewidth',2);  
end

if ~isempty(idxlim)
    h(4) = plot(0,0,'co'); 
else
    h(4) = plot(bulkparams.time(idxlim), bulkparams.hs(idxlim),'co','linewidth',2); 
end

legend(h,{'Mean+Std test','Flat line test','Range test','hard line test'})

total_flag_per = ((length(idx15)+length(idx16)+length(idx19)+length(idxlim))./length(bulkparams.hs)).*100; 
text(0.05, 0.9, ['Percent flagged: ' num2str(round(total_flag_per)) '%'],'units','normalized','fontweight','bold'); 

set(gcf, 'PaperPositionMode', 'manual','PaperUnits','centimeters','units','centimeters',...
    'position',[2 2 18 12], 'PaperPosition', [0 0 18 12],'color','w')
% print(gcf,'E:\Active_Projects\LOWE_IMOS_WaveBuoys\General\Presentations\IMOS_NTP_group_meetings\2020_10_23\Figures\Hs_qaqc','-dpng','-r300'); 

%% period
fidtp = figure;
plot(bulkparams.time, bulkparams.tp); 
hold on; 
grid on; 
ylabel('Tp (s)'); 
set(gca,'xlim',[bulkparams.time(1) bulkparams.time(end)],'xtick',linspace(bulkparams.time(1), bulkparams.time(end),12)); 
datetick('x','dd-mmm','keepticks'); 
set(gca,'xlim',[bulkparams.time(1) bulkparams.time(end)]); 
%only look for fails 
idx15 = find(bulkparams.qf15(:,2)>1); 
idx16 = find(bulkparams.qf16(:,2)>1); 
idx19 = find(bulkparams.qf19>1); 
idxlim = find(bulkparams.qf_lims(:,2)>1); 
clear h; 

if isempty(idx15)
    h(1) = plot(0,0,'ro'); 
else
    h(1) = plot(bulkparams.time(idx15), bulkparams.tp(idx15),'ro','linewidth',2); 
end

if isempty(idx16)
    h(2) = plot(0,0,'go'); 
else
    h(2) = plot(bulkparams.time(idx16), bulkparams.tp(idx16),'go','linewidth',2); 
end

if isempty(idx19)
    h(3) = plot(0,0,'yo'); 
else
    h(3) = plot(bulkparams.time(idx19), bulkparams.tp(idx19),'yo','linewidth',2); 
end

if ~isempty(idxlim)
    h(4) = plot(0,0,'co'); 
else
    h(4) = plot(bulkparams.time(idxlim), bulkparams.tp(idxlim),'co','linewidth',2); 
end

legend(h,{'Mean+Std test','Flat line test','Range test','hard line test'})

total_flag_per = ((length(idx15)+length(idx16)+length(idx19)+length(idxlim))./length(bulkparams.hs)).*100; 
text(0.05, 0.9, ['Percent flagged: ' num2str(round(total_flag_per)) '%'],'units','normalized','fontweight','bold'); 

set(gcf, 'PaperPositionMode', 'manual','PaperUnits','centimeters','units','centimeters',...
    'position',[2 2 18 12], 'PaperPosition', [0 0 18 12],'color','w')

% print(gcf,'E:\Active_Projects\LOWE_IMOS_WaveBuoys\General\Presentations\IMOS_NTP_group_meetings\2020_10_23\Figures\Tp_qaqc','-dpng','-r300'); 


