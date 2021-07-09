%% quick plot of qc results tests

%% qartod 15
outfields={'hs_15','tm_15','tp_15','dm_15','dp_15'}; 
fields = {'hs','tm','tp','dm','dp'};

%% qartod 16
outfields={'hs_16','tm_16','tp_16','dm_16','dp_16'}; 
fields = {'hs','tm','tp','dm','dp'};

%% qartod 19
for i =1 :length(fields);
    figure;
    plot(bulkparams.time, bulkparams.(fields{i}),'b-.'); 
    hold on; grid on; 
    if any(bulkparams.qf_19(:,2)==1)
        plot(bulkparams.time(bulkparams.qf_19(:,2)==1), bulkparams.(fields{i})(bulkparams.qf_19(:,2)==1),'k*');
    end
    if any(bulkparams.qf_19(:,2)==2)
        plot(bulkparams.time(bulkparams.qf_19(:,2)==2), bulkparams.(fields{i})(bulkparams.qf_19(:,2)==2),'y*');
    end
    if any(bulkparams.qf_19(:,2)==3)
        plot(bulkparams.time(bulkparams.qf_19(:,2)==3), bulkparams.(fields{i})(bulkparams.qf_19(:,2)==3),'r*');
    end
    if any(bulkparams.qf_19(:,2)==4)
        plot(bulkparams.time(bulkparams.qf_19(:,2)==4), bulkparams.(fields{i})(bulkparams.qf_19(:,2)==4),'c*');
    end
    datetick('x');
    title(fields{i}); 
end

%% qartod 20

outfields={'hs_20','tm_20','tp_20','dm_20','dp_20'};
fields = {'hs','tm','tp','dm','dp'};        

%% uwa spike
outfields={'hs_spike','tm_spike','tp_spike','dm_spike','dp_spike'};
fields = {'hs','tm','tp','dm','dp'};        

%%

for i = 1:length(outfields); 
    figure;
    plot(bulkparams.time, bulkparams.(fields{i}),'b.-'); 
    hold on; grid on;
    
    if any(bulkparams.(outfields{i})==2)
        plot(bulkparams.time(bulkparams.(outfields{i})==2),bulkparams.(fields{i})(bulkparams.(outfields{i})==2),'k*'); 
    end
    if any(bulkparams.(outfields{i})==3)
        plot(bulkparams.time(bulkparams.(outfields{i})==3),bulkparams.(fields{i})(bulkparams.(outfields{i})==3),'y*'); 
    end
    if any(bulkparams.(outfields{i})==4)
         plot(bulkparams.time(bulkparams.(outfields{i})==4),bulkparams.(fields{i})(bulkparams.(outfields{i})==4),'r*'); 
    end
    
    title(fields{i}); 
    datetick('x'); 
end




