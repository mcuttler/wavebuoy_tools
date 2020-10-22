%%  Apply QARTOD QA/QC 
%    
%test19: Function to do Qartod test 19 on a time series -
%min/max/acceptable range 
% 
%   See QARTOD manual for further details
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   inputs:
% 
% in.time - time vector : datenum format
% in.WVHGT - timeseries wave height : WVHGT
% in.WVPD - timeseries wave period : WVPD
% in.WVDIR - timeseries wave direction : WVDIR
% in.WVSP - timeseries wave spreading : WVSP

%    User defined test criteria
% in.STD - number of standard deviations values can be from mean 
%
%     Outputs:
% out1 - QC test flag of same length of time vector. values 1,3,4. 
%        1 = pass (see Qartod manual
%        "QARTOD-IOOS_Manual_for_Real-Time_Quality_Control_of_Waves_v2.1.pdf"
%        3 = suspect
%        4 = fail 
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Example usage
% 
%           [qf_bulkparams] = qartod_bulkdparams_range(in) 
%     
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%     
% Code history
% 
%     Author          | Date             | Script Version     | Update
%     --------------------------------------------------------
%     M. Cuttler     | 09 Oct 2020  | 1.0                      | Initial creation
% --------------------------------------------------------------------------------------------------------------------------------  
%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [QCFlag] = qartod_15_mean_std(in)

% intialize QC flag vector

QCFlag_tmp  = zeros(length(in.WVHGT),4);

dumt = datevec(in.time); 
hh = unique(dumt(:,1:4),'rows'); 
for ii = 1:size(hh,1)                   
    if ii>in.window    
        %find preceding window hours 
        tend = datenum([hh(ii,:),0,0]); 
        tstart = tend-datenum(0,0,0,window,0,0); 
        
        idx = find(in.time>=tstart&in.time<=tend); 
        
        %test each parameter 
        if ~isempty(idx) & length(idx)>1
            fields = {'in.WVHGT','in.WVPD','in.WVDIR','in.WVSP'};
            for j = 1:length(fields)
                eval(['dum =' fields{j} ';']); 
                ddata = dum(idx); 
                M = nanmean(ddata); 
                Mhi = M+(in.STD*nanstd(ddata));
                Mlow = M-(in.STD*nanstd(ddata)); 
                
                for jj = 1:length(idx) 
                    if ddata(jj)>Mhi | ddata(jj)<Mlow
                        QCFlag(idx(jj),j) = 3;
                    end
                end
            end
        else
            %not assessed
            QCFlag(idx(jj),:) = -1; 
        end
    else
        %not assessed
        QCFlag(ii,:) = -1; 
    end
end

%% subfunction

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

