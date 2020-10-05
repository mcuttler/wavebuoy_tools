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
% in.MINWH - Min wave height : MINWH (e.g. 0.05)
% in.MAXWH - Max wave height : MAXWH (e.g. 8)
% in.MINWP - Min wave period : MINWP (e.g. 2)
% in.MAXWP - Max wave period : MAXWP (e.g. 16)
% in.MINSV - Min spreading : MINSV  (e.g. 0.07)
% in.MAXSV - Max Spreading : MAXSV  (e.g. 1.0)
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
%     M. Hatcher   | 02 Oct 2020 | 1.0                      | Initial creation
% --------------------------------------------------------------------------------------------------------------------------------
%     M. Cuttler     | 05 Oct 2020 | 1.1                      | Modify code
%                                                                           operation (pull inputs out of function loop), and incorporate into
%                                                                           Process_SofarSpotty_delayed_mode code
% --------------------------------------------------------------------------------------------------------------------------------  
%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [QCFlag] = qartod_bulkparams_range(in)

% intialize QC flag vector

QCFlag  = zeros(length(in.WVHGT),1);
 
for ii=1:length(in.WVHGT)
    
   if in.WVHGT(ii)>in.MAXWH
       QCFlag(ii) = 4;
   elseif in.WVHGT(ii)<in.MINWH
       QCFlag(ii) = 4;
   elseif in.WVPD(ii) < in.MINWP
       QCFlag(ii) = 3;
   elseif in.WVPD(ii) > in.MAXWP
       QCFlag(ii) = 3;
   elseif in.WVDIR(ii) < 0
       QCFlag(ii) = 3;
   elseif in.WVDIR(ii) > 360
       QCFlag(ii) = 3;
   elseif in.WVSP(ii)< in.MINSV
       QCFlag(ii) = 3;
   elseif in.WVSP(ii) > in.MAXSV
       QCFlag(ii) = 3;
   else
       QCFlag(ii) = 1;
              
   end
end

end

