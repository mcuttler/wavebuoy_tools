%% quality control real time waves data for display on website 

function [qf_waves, qf_sst, qf_bott_temp] = qaqc_uwa_waves_website(qaqc); 

%need at least 3 points to run 'UWA master code'
% if size(qaqc.time,1)>=3
%     qf_waves = qaqc_uwa_masterflag(qaqc, qaqc.WVHGT, qaqc.WVPD); 
%     
%     %quick spike test for temperature
%     for ii = 1:size(qaqc.time_temp,1); 
%         if ii == 1
%             qf_sst(ii,1) = 4;             
%         elseif ii == size(qaqc.time_temp,1)
%             qf_sst(ii,1) = 4; 
%         else
%             dumSST = diff(qaqc.SST(ii-1:ii+1));      
%             %check SST spikes
%             if dumSST(1)>0&dumSST(2)<0&abs(dumSST)>qaqc.rocSST
%                 qf_sst(ii,1) = 4; 
%             elseif dumSST(1)<0&dumSST(2)>0&abs(dumSST)>qaqc.rocSST
%                 qf_sst(ii,1) = 4; 
%             else
%                 qf_sst(ii,1) = 1;
%             end
%         end
%     end
%     
% %otherwise, just run range and simple rate of change test 
% else

    %wave parameters
    for ii = 1:size(qaqc.time,1)
        %range test
        if qaqc.WVHGT(ii)<qaqc.MINWH | qaqc.WVHGT(ii)>qaqc.MAXWH | qaqc.WVPD(ii)<qaqc.MINWP | qaqc.WVPD(ii)>qaqc.MAXWP
            qf_waves_dum(ii,1) = 4;
        else
            qf_waves_dum(ii,1) = 1; 
        end
        %rate of change test
        if ii>1
            if abs(diff(qaqc.WVHGT(ii-1:ii)))>qaqc.rocHs | abs(diff(qaqc.WVPD(ii-1:ii)))>qaqc.rocTp
                qf_waves_dum(ii,2) = 4;
            else
                qf_waves_dum(ii,2) = 1; 
            end
        end        
    end
    
    %SST
    if isfield(qaqc,'time_temp')
        for ii = 1:size(qaqc.time_temp,1)        
            %range test
            if qaqc.SST(ii)<qaqc.MINT | qaqc.SST(ii)>qaqc.MAXT 
                qf_sst_dum(ii,1) = 4;
            else
                qf_sst_dum(ii,1)=1;
            end
            %rate of change test
            if ii>1
                if abs(diff(qaqc.SST(ii-1:ii)))>qaqc.rocSST
                    qf_sst_dum(ii,2) = 4;
                else
                    qf_sst_dum(ii,2) = 1;
                end
            end
        end
    end
    
    %BOTT_TEMP
    if isfield(qaqc,'time_temp')
        for ii = 1:size(qaqc.time_temp,1)        
            %range test
            if qaqc.BOTT_TEMP(ii)<qaqc.MINT | qaqc.BOTT_TEMP(ii)>qaqc.MAXT 
                qf_bott_temp_dum(ii,1) = 4;
            else
                qf_bott_temp_dum(ii,1)=1;
            end
            %rate of change test
            if ii>1
                if abs(diff(qaqc.BOTT_TEMP(ii-1:ii)))>qaqc.rocSST
                    qf_bott_temp_dum(ii,2) = 4;
                else
                    qf_bott_temp_dum(ii,2) = 1;
                end
            end
        end
    end
    
    %clean up and make output variables
    for ii = 1:size(qaqc.time,1)
        if any(qf_waves_dum(ii,:)>1)
            qf_waves(ii,1) = 4; 
        else
            qf_waves(ii,1) = 1; 
        end
    end
    
    if isfield(qaqc,'time_temp')
        for ii = 1:size(qaqc.time_temp,1)
            if any(qf_sst_dum(ii,:)>1)
                qf_sst(ii,1) = 4; 
            else
                qf_sst(ii,1) = 1;
            end
        end
    else
        qf_sst = nan; 
    end
    
    if isfield(qaqc,'time_temp')
        for ii = 1:size(qaqc.time_temp,1)
            if any(qf_bott_temp_dum(ii,:)>1)
                qf_bott_temp(ii,1) = 4; 
            else
                qf_bott_temp(ii,1) = 1;
            end
        end
    else
        qf_bott_temp = nan;
    end
    
% end              

end