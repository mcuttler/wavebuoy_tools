%% Assess QA/QC bulk parameters

%%

function [] = assess_qaqc_bulkparams(bulkparams,savefig)

%check each column (variabile) in QC flag variables
vars_mean = {'hs','tm','dm','meanspr'}; 

%mean parameters 
for i = 1:length(vars_mean)
    eval(['dum = bulkparams.' vars_mean{i} ';']); 
    clear h
    figure;     
    plot(bulkparams.time, dum); 
    hold on;
    
    idx1 = find(bulkparams.qf15_mean(:,i)==3|bulkparams.qf15_mean(:,i)==4);     
    idx2 = find(bulkparams.qf16_mean(:,i)==3|bulkparams.qf16_mean(:,i)==4);
    idx3 = find(bulkparams.qf19_mean==3|bulkparams.qf19_mean==4); 
    idx4 = find(bulkparams.qf_lims(:,1)==3|bulkparams.qf_lims(:,1)==4); 
    idx5 = find(bulkparams.qf_lims(:,2)==3|bulkparams.qf_lims(:,2)==4);     

    if ~isempty(idx1)
        h(1)= plot(bulkparams.time(bulkparams.qf15_mean(:,i)==3|bulkparams.qf15_mean(:,i)==4), dum(bulkparams.qf15_mean(:,i)==3|bulkparams.qf15_mean(:,i)==4),'ro');                       
        plt(1) = 1; 
        per(1) = (length(idx1)/length(dum)).*100; 
    else
        per(1) =0; 
        plt(1) = 0; 
    end
    
    if ~isempty(idx2) 
        h(2) = plot(bulkparams.time(bulkparams.qf16_mean(:,i)==3|bulkparams.qf16_mean(:,i)==4), dum(bulkparams.qf16_mean(:,i)==3|bulkparams.qf16_mean(:,i)==4),'yo'); 
        plt(2) = 1; 
          per(2) = (length(idx2)/length(dum)).*100; 
    else 
        per(2) =0; 
        plt(2) = 0; 
    end
    
    if ~isempty(idx3)
        h(3) = plot(bulkparams.time(bulkparams.qf19_mean==3|bulkparams.qf19_mean==4), dum(bulkparams.qf19_mean==3|bulkparams.qf19_mean==4),'bo'); 
        plt(3) = 1; 
          per(3) = (length(idx3)/length(dum)).*100; 
    else
        per(3) = 0; 
        plt(3)=0; 
    end
    
    if ~isempty(idx4)
        h(4) = plot(bulkparams.time(bulkparams.qf_lims(:,1)==3|bulkparams.qf_lims(:,1)==4), dum(bulkparams.qf_lims(:,1)==3|bulkparams.qf_lims(:,1)==4),'ko'); 
        plt(4) = 1; 
          per(4) = (length(idx4)/length(dum)).*100; 
    else
        per(4)=0;
        plt(4)=0; 
    end
    
    if ~isempty(idx5)
        h(5) = plot(bulkparams.time(bulkparams.qf_lims(:,2)==3|bulkparams.qf_lims(:,2)==4), dum(bulkparams.qf_lims(:,2)==3|bulkparams.qf_lims(:,2)==4),'co'); 
        plt(5)=1; 
        per(5) = (length(idx5)/length(dum)).*100; 
    else
        per(5)=0; 
        plt(5)=0;
    end
    
    datetick('x','mm-yy','keepticks'); 
    xlabel('Date'); 
    ylabel(vars_mean{i}); 
    grid on; 
    
    leg_labs = {['QARTOD15 (Mean + STD): ' num2str(round(per(1),1)) '%'];['QARTOD16 (Flat line): ' num2str(round(per(2),1)) '%']'; ['QARTOD 19 (Range): ' num2str(round(per(3),1)) '%']';...
        ['Sofar Limits (Hs): ' num2str(round(per(4),1)) '%'];['Sofar Limits (Tp): ' num2str(round(per(5),1)) '%']};
    legend(h(plt==1),leg_labs{plt==1},'location','northoutside'); 
    text(0.05, 0.95,['Total flagged: ' num2str(round((sum([length(idx1), length(idx2), length(idx3), length(idx4), length(idx5)])/length(dum))*100,1)) '%'],'units','normalized','fontweight','bold'); 
    
    clear h dum idx1 idx2 idx3 idx4 idx5 per plt
    %hard coded path for saving figure - change in future to save to github
    %path related location (e.g. similar to CoastSat)
    if savefig==1
        if strcmp(vars_mean{i},'hs')
            print(['D:\Active_Projects\LOWE_IMOS_WaveBuoys\Data\QualityControl\Figures\assess_qaqc_' vars_mean{i} '_mean'],'-r300','-dpng'); 
        else
            print(['D:\Active_Projects\LOWE_IMOS_WaveBuoys\Data\QualityControl\Figures\assess_qaqc_' vars_mean{i}],'-r300','-dpng');
        end
    end
        
    
end
%%
%peak parameters 
vars_peak = {'hs','tp','dp','pkspr'}; 
for i = 1:length(vars_peak)
    eval(['dum = bulkparams.' vars_peak{i} ';']); 
    clear h
    figure;     
    plot(bulkparams.time, dum); 
    hold on;
    
    idx1 = find(bulkparams.qf15_peak(:,i)==3|bulkparams.qf15_peak(:,i)==4);     
    idx2 = find(bulkparams.qf16_peak(:,i)==3|bulkparams.qf16_peak(:,i)==4);
    idx3 = find(bulkparams.qf19_peak==3|bulkparams.qf19_peak==4); 
    idx4 = find(bulkparams.qf_lims(:,1)==3|bulkparams.qf_lims(:,1)==4); 
    idx5 = find(bulkparams.qf_lims(:,2)==3|bulkparams.qf_lims(:,2)==4);     

    if ~isempty(idx1)
        h(1)= plot(bulkparams.time(bulkparams.qf15_peak(:,i)==3|bulkparams.qf15_peak(:,i)==4), dum(bulkparams.qf15_peak(:,i)==3|bulkparams.qf15_peak(:,i)==4),'ro');                       
        plt(1) = 1; 
        per(1) = (length(idx1)/length(dum)).*100; 
    else
        per(1) =0; 
        plt(1) = 0; 
    end
    
    if ~isempty(idx2) 
        h(2) = plot(bulkparams.time(bulkparams.qf16_peak(:,i)==3|bulkparams.qf16_peak(:,i)==4), dum(bulkparams.qf16_peak(:,i)==3|bulkparams.qf16_peak(:,i)==4),'yo'); 
        plt(2) = 1; 
          per(2) = (length(idx2)/length(dum)).*100; 
    else 
        per(2) =0; 
        plt(2) = 0; 
    end
    
    if ~isempty(idx3)
        h(3) = plot(bulkparams.time(bulkparams.qf19_peak==3|bulkparams.qf19_peak==4), dum(bulkparams.qf19_peak==3|bulkparams.qf19_peak==4),'bo'); 
        plt(3) = 1; 
          per(3) = (length(idx3)/length(dum)).*100; 
    else
        per(3) = 0; 
        plt(3)=0; 
    end
    
    if ~isempty(idx4)
        h(4) = plot(bulkparams.time(bulkparams.qf_lims(:,1)==3|bulkparams.qf_lims(:,1)==4), dum(bulkparams.qf_lims(:,1)==3|bulkparams.qf_lims(:,1)==4),'ko'); 
        plt(4) = 1; 
          per(4) = (length(idx4)/length(dum)).*100; 
    else
        per(4)=0;
        plt(4)=0; 
    end
    
    if ~isempty(idx5)
        h(5) = plot(bulkparams.time(bulkparams.qf_lims(:,2)==3|bulkparams.qf_lims(:,2)==4), dum(bulkparams.qf_lims(:,2)==3|bulkparams.qf_lims(:,2)==4),'co'); 
        plt(5)=1; 
        per(5) = (length(idx5)/length(dum)).*100; 
    else
        per(5)=0; 
        plt(5)=0;
    end
    
    datetick('x','mm-yy','keepticks'); 
    xlabel('Date'); 
    ylabel(vars_peak{i}); 
    grid on; 
    
    leg_labs = {['QARTOD15 (Mean + STD): ' num2str(round(per(1),1)) '%'];['QARTOD16 (Flat line): ' num2str(round(per(2),1)) '%']'; ['QARTOD 19 (Range): ' num2str(round(per(3),1)) '%']';...
        ['Sofar Limits (Hs): ' num2str(round(per(4),1)) '%'];['Sofar Limits (Tp): ' num2str(round(per(5),1)) '%']};
    legend(h(plt==1),leg_labs{plt==1},'location','northoutside'); 
    text(0.05, 0.95,['Total flagged: ' num2str(round((sum([length(idx1), length(idx2), length(idx3), length(idx4), length(idx5)])/length(dum))*100,1)) '%'],'units','normalized','fontweight','bold'); 
    
    clear h dum idx1 idx2 idx3 idx4 idx5 per plt
    %hard coded path for saving figure - change in future to save to github
    %path related location (e.g. similar to CoastSat)
    if savefig==1
        if strcmp(vars_peak{i},'hs')
            print(['D:\Active_Projects\LOWE_IMOS_WaveBuoys\Data\QualityControl\Figures\assess_qaqc_' vars_peak{i} '_peak'],'-r300','-dpng'); 
        else
            print(['D:\Active_Projects\LOWE_IMOS_WaveBuoys\Data\QualityControl\Figures\assess_qaqc_' vars_peak{i}],'-r300','-dpng');
        end
    end
    
end
end