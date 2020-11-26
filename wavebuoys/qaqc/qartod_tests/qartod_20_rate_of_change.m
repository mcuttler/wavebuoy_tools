%%  Apply QARTOD QA/QC 
%    
%test19: Function to do Qartod test 20 on a time series -
%rate of change test
% 
%   See QARTOD manual for further details
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   inputs:
% 
% in.time - time vector : datenum format
% in.data - timeseries
% in.rate_of_change

%    User defined test criteria
% in.rate_of_change = difference between successive time points 
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
%           [qf_bulkparams] = qartod_20_rate_of_change(in) 
%     
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%     
% Code history
% 
%     Author          | Date             | Script Version     | Update
%     --------------------------------------------------------
%     M. Cuttler     | 26 Nov 2020 | 1.0                      | Initial creation
% --------------------------------------------------------------------------------------------------------------------------------

%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [QCFlag] = qartod_20_rate_of_change(in)

% intialize QC flag vector

QCFlag  = zeros(length(in.data),1);
 
for ii=1:length(in.data)
    if ii == 1
        QCFlag(ii) = -1; 
    else
        if abs(in.data(ii)-in.data(ii-1))>=in.rate_of_change        
            QCFlag(ii)=4;
        else
            QCFlag(ii)=1; 
        end
    end
end


end

