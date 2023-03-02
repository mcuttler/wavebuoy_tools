%%  Apply QARTOD QA/QC 
%    
% Test 15 --- MEAN - STD 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%     
% Code history
% 
%     Author          | Date             | Script Version     | Update
%     --------------------------------------------------------
%     M. Cuttler     | 09 Oct 2020  | 1.0                      | Initial creation
% --------------------------------------------------------------------------------------------------------------------------------  
%     M. Cuttler     | 21 Dec 2020  | 1.1                      | Remove real-time option, re-arrange so that can be run for individual parameters

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [QCFlag] = qartod_15_mean_std(in, data)
QCFlag = []; 
for ii = 1:size(in.time,1)    
    tnow = in.time(ii);
    tstart = in.time(ii) - datenum(0,0,0,in.time_window, 0,0); 
    tend = in.time(ii) + datenum(0,0,0,in.time_window, 0,0); 
    
    if tstart>= in.time(1) & tend<=in.time(end)
        idx = find(in.time>=tstart & in.time<=tend);                                    
        ddata = data(idx); 
        M = nanmean(ddata); 
        Mhi = M+(in.STD*nanstd(ddata));
        Mlow = M-(in.STD*nanstd(ddata));
        
        if data(ii)>Mhi | data(ii)<Mlow
            QCFlag(ii,1) = 3;
        else 
            QCFlag(ii,1) = 1; 
        end
        clear dumdata ddata M Mhi Mlow idx      
    else
        %not assessed
        QCFlag(ii,1) = 2; 
    end
end       
        
        
        
    %% subfunction - not used (Dec 2020). 
    
    function [qc] = check_std(var, std_lim)
        for i = 1:length(var)
            if var(i) > mean(var)+(std_lim*std(var)) | var(i) < mean(var)-(std_lim*std(var))
                qc(i,1) = 3;
            else
                qc(i,1) = 1; 
            end
        end       
    end


end

