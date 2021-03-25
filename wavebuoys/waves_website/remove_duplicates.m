%% Function to remove/check for duplicate times (partiuclarly for Smart Mooring sensors

%% 
function [dataout] = remove_duplicates(data)

t_wave = unique(data.time); 

fields = fieldnames(data); 
for j = 1:length(fields)
    dataout.(fields{j}) = []; 
end

%wave data
for i = 1:length(t_wave)
    dataout.time(i,1) = t_wave(i); 
    idx = find(data.time==t_wave(i));     
    for j = 1:length(fields)
        if strcmp(fields{j},'temp_time')|strcmp(fields{j},'surf_temp')|strcmp(fields{j},'bott_temp')|strcmp(fields{j},'qf_sst')|strcmp(fields{j},'qf_bott_temp')
            dum = 1;
        else
            if length(idx)>1            
                t1 = data.(fields{j})(idx(1));
                t2 = data.(fields{j})(idx(2));                 
                if isnan(t1)&isnan(t2)
                    dataout.(fields{j}) = [dataout.(fields{j}); nan]; 
                elseif isnan(t1)&~isnan(t2)
                    dataout.(fields{j}) = [dataout.(fields{j}); data.(fields{j})(idx(2))]; 
                elseif ~isnan(t1)&isnan(t2)
                    dataout.(fields{j}) = [dataout.(fields{j}); data.(fields{j})(idx(1))]; 
                else                
                    dataout.(fields{j})=[dataout.(fields{j}); data.(fields{j})(idx(1))];
                end
            else
                dataout.(fields{j}) = [dataout.(fields{j}); data.(fields{j})(idx)];
            end
        end
    end
    clear idx t1 t2 
end

%temp data
if isfield(data,'temp_time')
    t_temp = unique(data.temp_time); 
    for i = 1:length(t_temp)
        dataout.temp_time(i,1) = t_temp(i); 
        idx = find(data.temp_time==t_temp(i));     
        for j = 1:length(fields)
            if strcmp(fields{j},'surf_temp')|strcmp(fields{j},'bott_temp')|strcmp(fields{j},'qf_sst')|strcmp(fields{j},'qf_bott_temp')
                if length(idx)>1
                    t1 = data.(fields{j})(idx(1));
                    t2 = data.(fields{j})(idx(2));                 
                    if isnan(t1)&isnan(t2)
                        dataout.(fields{j}) = [dataout.(fields{j}); nan]; 
                    elseif isnan(t1)&~isnan(t2)
                        dataout.(fields{j}) = [dataout.(fields{j}); data.(fields{j})(idx(2))]; 
                    elseif ~isnan(t1)&isnan(t2)
                        dataout.(fields{j}) = [dataout.(fields{j}); data.(fields{j})(idx(1))]; 
                    else
                        dataout.(fields{j})=[dataout.(fields{j}); data.(fields{j})(idx(1))];
                    end
                else
                    dataout.(fields{j}) = [dataout.(fields{j}); data.(fields{j})(idx)];
                end                            
            end
        end
        clear idx t1 t2
    end
end

end
        
        
