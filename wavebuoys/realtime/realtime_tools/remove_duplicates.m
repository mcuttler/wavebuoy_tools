%% Function to remove/check for duplicate times (partiuclarly for Smart Mooring sensors

%% 
function [dataout] = remove_duplicates(data)
if isfield(data,'qf_waves'); 
    data = rmfield(data,'qf_waves'); 
end

if isfield(data,'qf_sst')
    data = rmfield(data,'qf_sst'); 
end
if isfield(data,'qf_bott_temp')
    data = rmfield(data,'qf_bott_temp'); 
end

%extra cleanup for datawell
if isfield(data,'file20')
    data = rmfield(data,{'tnow','file20','file21','file25','file28','file82'});
end

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
        if strcmp(fields{j},'temp_time')|strcmp(fields{j},'surf_temp')|strcmp(fields{j},'bott_temp')|strcmp(fields{j},'time')|strcmp(fields{j},'curr_mag')|strcmp(fields{j},'curr_dir')|strcmp(fields{j},'curr_mag_std')|strcmp(fields{j},'curr_dir_std')|strcmp(fields{j},'w') | strcmp(fields{j},'w_std')|strcmp(fields{j},'press_time')|strcmp(fields{j},'press_std_time')|strcmp(fields{j},'pressure')|strcmp(fields{j},'pressure_std')
            dum = 1;
        elseif strcmp(fields{j},'spec_time')|strcmp(fields{j},'a1')|strcmp(fields{j},'a2')|strcmp(fields{j},'b1')|strcmp(fields{j},'b2')|strcmp(fields{j},'varianceDensity')|strcmp(fields{j},'frequency')|strcmp(fields{j},'df')|strcmp(fields{j},'directionalSpread')|strcmp(fields{j},'direction')|strcmp(fields{j},'ndirec')            
            dum = 1;
        elseif contains(fields{j},'swell')|(contains(fields{j},'sea')&~contains(fields{j},'wind'))|strcmp(fields{j},'part_time')
            dum = 1;
        elseif contains(fields{j},'batt') | contains(fields{j},'sys') | contains(fields{j},'Volt')|contains(fields{j},'humid')
            dum = 1; 
        elseif strcmp(fields{j},'serialID')|strcmp(fields{j},'name')
            dataout.(fields{j}) = [dataout.(fields{j}); data.(fields{j})(idx(1))];             
        else
            if length(idx)>1            
                t1 = data.(fields{j})(idx(1));
                t2 = data.(fields{j})(idx(2));                 
                if isnan(t1)&isnan(t2)
                    dataout.(fields{j}) = [dataout.(fields{j}); nan]; 
                elseif isnan(t1)&~isnan(t2)
                    dataout.(fields{j}) = [dataout.(fields{j}); data.(fields{j})(idx(2),:)]; 
                elseif ~isnan(t1)&isnan(t2)
                    dataout.(fields{j}) = [dataout.(fields{j}); data.(fields{j})(idx(1),:)]; 
                else                
                    dataout.(fields{j})=[dataout.(fields{j}); data.(fields{j})(idx(1),:)];
                end
            else
                dataout.(fields{j}) = [dataout.(fields{j}); data.(fields{j})(idx,:)];
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
            if strcmp(fields{j},'surf_temp')|strcmp(fields{j},'bott_temp')|strcmp(fields{j},'curr_mag')|strcmp(fields{j},'curr_dir')|strcmp(fields{j},'curr_mag_std')|strcmp(fields{j},'curr_dir_std')|strcmp(fields{j},'w') | strcmp(fields{j},'w_std') 
                if length(idx)>1
                    t1 = data.(fields{j})(idx(1));
                    t2 = data.(fields{j})(idx(2));                 
                    if isnan(t1)&isnan(t2)
                        dataout.(fields{j}) = [dataout.(fields{j}); nan]; 
                    elseif isnan(t1)&~isnan(t2)
                        dataout.(fields{j}) = [dataout.(fields{j}); data.(fields{j})(idx(2),:)]; 
                    elseif ~isnan(t1)&isnan(t2)
                        dataout.(fields{j}) = [dataout.(fields{j}); data.(fields{j})(idx(1),:)]; 
                    else
                        dataout.(fields{j})=[dataout.(fields{j}); data.(fields{j})(idx(1),:)];
                    end
                else
                    dataout.(fields{j}) = [dataout.(fields{j}); data.(fields{j})(idx,:)];
                end                            
            end
        end
        clear idx t1 t2
    end
end
%pressure data
if isfield(data,'press_time')
    p_temp = unique(data.press_time); 
    for i = 1:length(p_temp)
        dataout.press_time(i,1) = p_temp(i);         
        idx = find(data.press_time==p_temp(i));     
        for j = 1:length(fields)
            if strcmp(fields{j},'pressure')
                if length(idx)>1
                    t1 = data.(fields{j})(idx(1));
                    t2 = data.(fields{j})(idx(2));                 
                    if isnan(t1)&isnan(t2)
                        dataout.(fields{j}) = [dataout.(fields{j}); nan]; 
                    elseif isnan(t1)&~isnan(t2)
                        dataout.(fields{j}) = [dataout.(fields{j}); data.(fields{j})(idx(2),:)]; 
                    elseif ~isnan(t1)&isnan(t2)
                        dataout.(fields{j}) = [dataout.(fields{j}); data.(fields{j})(idx(1),:)]; 
                    else
                        dataout.(fields{j})=[dataout.(fields{j}); data.(fields{j})(idx(1),:)];
                    end
                else
                    dataout.(fields{j}) = [dataout.(fields{j}); data.(fields{j})(idx,:)];
                end                            
            end
        end
        clear idx t1 t2
    end
end
%pressure std data
if isfield(data,'press_std_time')
    p_temp = unique(data.press_std_time); 
    for i = 1:length(p_temp)
        dataout.press_std_time(i,1) = p_temp(i);         
        idx = find(data.press_std_time==p_temp(i));     
        for j = 1:length(fields)
            if strcmp(fields{j},'pressure_std')
                if length(idx)>1
                    t1 = data.(fields{j})(idx(1));
                    t2 = data.(fields{j})(idx(2));                 
                    if isnan(t1)&isnan(t2)
                        dataout.(fields{j}) = [dataout.(fields{j}); nan]; 
                    elseif isnan(t1)&~isnan(t2)
                        dataout.(fields{j}) = [dataout.(fields{j}); data.(fields{j})(idx(2),:)]; 
                    elseif ~isnan(t1)&isnan(t2)
                        dataout.(fields{j}) = [dataout.(fields{j}); data.(fields{j})(idx(1),:)]; 
                    else
                        dataout.(fields{j})=[dataout.(fields{j}); data.(fields{j})(idx(1),:)];
                    end
                else
                    try
                        dataout.(fields{j}) = [dataout.(fields{j}); data.(fields{j})(idx,:)];
                    catch
                        dataout.(fields{j}) = [dataout.(fields{j}); nan]; 
                    end
                end                            
            end
        end
        clear idx t1 t2
    end
end

% %spectral data
% %add spec time for Datawell 
% if isfield(data,'ndirec')
%   t_spec = unique(data.time); 
%     for i = 1:length(t_spec)        
%         idx = find(data.time==t_spec(i));     
%         for j = 1:length(fields)
%             if strcmp(fields{j},'a1')|strcmp(fields{j},'a2')|strcmp(fields{j},'b1')|strcmp(fields{j},'b2')
%                 if length(idx)>1
%                     t1 = data.(fields{j})(idx(1));
%                     t2 = data.(fields{j})(idx(2));                 
%                     if isnan(t1)&isnan(t2)
%                         dataout.(fields{j}) = [dataout.(fields{j}); nan]; 
%                     elseif isnan(t1)&~isnan(t2)
%                         dataout.(fields{j}) = [dataout.(fields{j}); data.(fields{j})(idx(2),:)]; 
%                     elseif ~isnan(t1)&isnan(t2)
%                         dataout.(fields{j}) = [dataout.(fields{j}); data.(fields{j})(idx(1),:)]; 
%                     else
%                         dataout.(fields{j})=[dataout.(fields{j}); data.(fields{j})(idx(1),:)];
%                     end
%                 else
%                     dataout.(fields{j}) = [dataout.(fields{j}); data.(fields{j})(idx,:)];
%                 end  
%             elseif strcmp(fields{j},'frequency')||strcmp(fields{j},'ndirec')
%                 dataout.(fields{j}) = data.(fields{j}); 
%             end
%         end
%         clear idx t1 t2
%     end
% end

%spectral data - Spotter
if isfield(data,'spec_time')
    t_spec = unique(data.spec_time); 
    for i = 1:length(t_spec)
        dataout.spec_time(i,1) = t_spec(i); 
        idx = find(data.spec_time==t_spec(i));     
        for j = 1:length(fields)
            if strcmp(fields{j},'a1')|strcmp(fields{j},'a2')|strcmp(fields{j},'b1')|strcmp(fields{j},'b2')|strcmp(fields{j},'varianceDensity')|strcmp(fields{j},'frequency')|strcmp(fields{j},'df')|strcmp(fields{j},'directionalSpread')|strcmp(fields{j},'direction')|strcmp(fields{j},'ndirec')
                if length(idx)>1
                    %add catch for datawell frequency and ndirc
                    if size(data.(fields{j}),1)==1
                        dataout.(fields{j}) = data.(fields{j});
                    else
                        t1 = data.(fields{j})(idx(1));
                        t2 = data.(fields{j})(idx(2));                 
                        if isnan(t1)&isnan(t2)
                            dataout.(fields{j}) = [dataout.(fields{j}); nan]; 
                        elseif isnan(t1)&~isnan(t2)
                            dataout.(fields{j}) = [dataout.(fields{j}); data.(fields{j})(idx(2),:)]; 
                        elseif ~isnan(t1)&isnan(t2)
                            dataout.(fields{j}) = [dataout.(fields{j}); data.(fields{j})(idx(1),:)]; 
                        else
                            dataout.(fields{j})=[dataout.(fields{j}); data.(fields{j})(idx(1),:)];
                        end
                    end
                else
                    %add catch for datawell frequency and ndirc
                    if size(data.(fields{j}),1)==1
                        dataout.(fields{j}) = data.(fields{j});
                    else
                        dataout.(fields{j}) = [dataout.(fields{j}); data.(fields{j})(idx,:)];
                    end
                end                            
            end
        end
        clear idx t1 t2
    end
end

%partitioned data - Spotter
if isfield(data,'part_time')
    t_spec = unique(data.part_time); 
    for i = 1:length(t_spec)
        dataout.part_time(i,1) = t_spec(i); 
        idx = find(data.part_time==t_spec(i));     
        for j = 1:length(fields)
            if contains(fields{j},'swell')|(contains(fields{j},'sea')&~contains(fields{j},'wind'))
                if length(idx)>1
                    t1 = data.(fields{j})(idx(1));
                    t2 = data.(fields{j})(idx(2));                 
                    if isnan(t1)&isnan(t2)
                        dataout.(fields{j}) = [dataout.(fields{j}); nan]; 
                    elseif isnan(t1)&~isnan(t2)
                        dataout.(fields{j}) = [dataout.(fields{j}); data.(fields{j})(idx(2),:)]; 
                    elseif ~isnan(t1)&isnan(t2)
                        dataout.(fields{j}) = [dataout.(fields{j}); data.(fields{j})(idx(1),:)]; 
                    else
                        dataout.(fields{j})=[dataout.(fields{j}); data.(fields{j})(idx(1),:)];
                    end
                else
                    dataout.(fields{j}) = [dataout.(fields{j}); data.(fields{j})(idx,:)];
                end                            
            end
        end
        clear idx t1 t2
    end
end

%system data - Spotter
if isfield(data,'systime')
    t_spec = unique(data.systime); 
    for i = 1:length(t_spec)
        dataout.systime(i,1) = t_spec(i); 
        idx = find(data.systime==t_spec(i));     
        for j = 1:length(fields)
            if contains(fields{j},'batt')|(contains(fields{j},'Volt')|contains(fields{j},'humid'))
                if length(idx)>1
                    t1 = data.(fields{j})(idx(1));
                    t2 = data.(fields{j})(idx(2));                 
                    if isnan(t1)&isnan(t2)
                        dataout.(fields{j}) = [dataout.(fields{j}); nan]; 
                    elseif isnan(t1)&~isnan(t2)
                        dataout.(fields{j}) = [dataout.(fields{j}); data.(fields{j})(idx(2),:)]; 
                    elseif ~isnan(t1)&isnan(t2)
                        dataout.(fields{j}) = [dataout.(fields{j}); data.(fields{j})(idx(1),:)]; 
                    else
                        dataout.(fields{j})=[dataout.(fields{j}); data.(fields{j})(idx(1),:)];
                    end
                else
                    dataout.(fields{j}) = [dataout.(fields{j}); data.(fields{j})(idx,:)];
                end                            
            end
        end
        clear idx t1 t2
    end
end


end
        
        
