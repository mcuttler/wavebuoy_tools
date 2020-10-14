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

QCFlag_tmp(:,1) = check_std(in.WVHGT, in.STD);
QCFlag_tmp(:,2) = check_std(in.WVPD, in.STD);
QCFlag_tmp(:,3) = check_std(in.WVDIR, in.STD);
QCFlag_tmp(:,4) = check_std(in.WVSP, in.STD);

QCFlag = max(QCFlag_tmp,[],2); 

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

