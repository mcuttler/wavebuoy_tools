%% Fix Smart-mooring archive - daily


%%
function [] = fix_smart_mooring_daily(buoy_info, tstart, tend)

%create list of dates from tstart to tend
dd = [tstart:tend]'; 
for d = 1:size(dd,1)
    disp(['Processing ' datestr(dd(d))]); 
    %get daily data
    startDate = [datestr(dd(d),30) 'Z']; 
    endDate = [datestr(dd(d)+0.99999,30) 'Z'];
    %there may not be data for each day, but doesn't matter
    try      
        [SpotData,flag] = Get_Spoondrift_SmartMooring_time_period(buoy_info, startDate, endDate); 
        for i = 1:size(SpotData.time,1)
            SpotData.name{i,1} = buoy_info.name; 
        end
        [check] = check_archive_path(buoy_info.archive_path, buoy_info, SpotData);   
        if all(check)~=0        
            [archive_data] = load_archived_data(buoy_info.archive_path, buoy_info, SpotData);                  
            %add serial ID and name if not already there
            if ~isfield(archive_data,'serialID')
                for i = 1:size(archive_data.time,1)
                    archive_data.serialID{i,1} = buoy_info.serial;
                end
            end
            if ~isfield(archive_data,'name')
                for i = 1:size(archive_data.time,1)
                    archive_data.name{i,1} = buoy_info.name;
                end
            end                
            %check that it's new data
            if SpotData.time(1)>archive_data.time(end)
                %if smart mooring, only keep new temp and wave data
                idx_w = find(SpotData.time>archive_data.time(end)); 
                idx_t = find(SpotData.temp_time>archive_data.temp_time(end)); 
                ff = fieldnames(SpotData); 
                for f = 1:length(ff)
                    if strcmp(ff{f},'temp_time')|strcmp(ff{f},'surf_temp')|strcmp(ff{f},'bott_temp')
                        SpotData.(ff{f}) = SpotData.(ff{f})(idx_t,:); 
                    else
                        SpotData.(ff{f}) = SpotData.(ff{f})(idx_w,:); 
                    end
                end
                clear ff idx_w idx_t f
                %perform some QA/QC --- QARTOD 19 and QARTOD 20        
                [data] = qaqc_bulkparams_realtime_website(buoy_info, archive_data, SpotData);                                        

                %save data to different formats        
                realtime_archive_mat(buoy_info, data);
%                 realtime_backup_mat(buoy_info, data);
                realtime_archive_text(buoy_info, data, size(SpotData.time,1)); 
                %output MEM and SST plots 
                if strcmp(buoy_info.DataType,'spectral')        
                    [NS, NE, ndirec] = lygre_krogstad(SpotData.a1,SpotData.a2,SpotData.b1,SpotData.b2,SpotData.varianceDensity);
                    make_MEM_plot(ndirec, SpotData.frequency, NE, SpotData.hsig, SpotData.tp, SpotData.dp, SpotData.time, buoy_info)        
                end
                
                %code to update the buoy info master file for website to read
%                 update_website_buoy_info(buoy_info, data); 
            end
        else
            SpotData.qf_waves = ones(size(SpotData.time,1),1).*1;
            if isfield(SpotData,'temp_time')
                SpotData.qf_sst = ones(size(SpotData.temp_time,1),1).*1; 
                SpotData.qf_bott_temp = ones(size(SpotData.temp_time,1),1).*1; 
                
            end
            realtime_archive_mat(buoy_info, SpotData);
%             realtime_backup_mat(buoy_info, SpotData);
            realtime_archive_text(buoy_info, SpotData, size(SpotData.time,1));  
            
            %output MEM and SST plots 
            if strcmp(buoy_info.DataType,'spectral')        
                [NS, NE, ndirec] = lygre_krogstad(SpotData.a1,SpotData.a2,SpotData.b1,SpotData.b2,SpotData.varianceDensity);
                make_MEM_plot(ndirec, SpotData.frequency, NE, SpotData.hsig, SpotData.tp, SpotData.dp, SpotData.time, buoy_info)        
            end
            
            %code to update the buoy info master file for website to read
%             update_website_buoy_info(buoy_info, SpotData); 
        end     
    catch
        disp(['No data between for ' datestr(dd(d))]); 
    end      
end  
end
