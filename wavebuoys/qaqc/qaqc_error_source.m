%% check source of QAQC errors

function [source] = qaqc_error_source(qc_subflag, type)

if strcmp(type,'bulkparams')
    qaqc_errors = {'unspecified error',
        'too few data',
        'hs outside mean+3std',
        'tp outside mean+3std',
        'dp outside mean+3std',
        'hs and tp outside mean+3std',
        'hs and dp outside mean+3std',
        'tp and dp outside mean+3std',
        'hs tp dp outside mean+3std',
        'hs flatline',
        'tp flatline',
        'dp flatline',
        'hs and tp flatline',
        'hs and dp flatline',
        'tp and dp flatline',
        'hs tp dp flatline',
        'hs outside range',
        'tp outside range',
        'dp outside range',
        'hs and tp outside range',
        'hs and dp outside range',
        'tp and dp outside range',
        'hs tp dp outside range',
        'hs rate of change',
        'tp rate of change',
        'dp rate of change',        
        'hs and tp rate of change',
        'hs and dp rate of change',
        'tp and dp rate of change',
        'hs tp dp rate of change',
        'hs spike',
        'tp spike',
        'dp spike',
        'hs and tp spike',
        'hs_and_dp spike',
        'tp and dp spike',
        'hs tp dp spike'};
elseif strcmp(type,'temp')
    qaqc_errors = {'unspecified error',
        'too few data',
        'temp outside mean+3std',
        'temp_flatline',
        'temp_outside_range',
        'temp_rate_of_change',
        'temp_spike'}; 
end

errors = unique(qc_subflag); 
errors = errors(errors>0); %disregard good results 
fid = figure; 
histogram(qc_subflag(qc_subflag>0));
xlabel('Flag Number/Value');
ylabel('Count'); 

set(fid, 'PaperPositionMode', 'manual','PaperUnits','centimeters','units','centimeters',...
'position',[1 1 19 18], 'PaperPosition', [0 0 19 18])

ytxt = 0.95;
for i = 1:length(errors); 
    counts(i,1) = length(find(qc_subflag==errors(i))); 
    text(0.05, ytxt, ['Flag ' num2str(errors(i)) ': ' qaqc_errors{errors(i)} ' = ' num2str(counts(i,1))],'units','normalized','fontsize',10); 
    ytxt = ytxt-0.025; 
end

source = [errors counts];
end


    
