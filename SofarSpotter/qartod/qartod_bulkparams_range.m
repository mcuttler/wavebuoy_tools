%%  Apply QARTOD QA/QC 
% This script processes Sofar Spotter data stored on the SD card (i.e. processes data after retrieval of buoy). 
% This requires the Sofar parser script (Python), accessible here: https://www.sofarocean.com/posts/parsing-script
% 
% The parser script will process all available data files (_FLT, _LOC, _SYS) available in a folder, however, due to computer memory issues, 
% this code chunks the data files into temporary folders and then concatenates results at the end. 
% 
% Final output files include: 
%     -bulkparameters.csv : CSV file containing wave parameters (Hs, Tp, Dp, etc.)
%     -displacements.csv: CSV file containin the raw displacements
%
% Example usage
%     MC to fill when finished
%     
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%     
% Code history
% 
%     Author          | Date             | Script Version     | Update
%     --------------------------------------------------------
%     M. Hatcher   | 02 Oct 2020 | 1.0                      | Initial creation
%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [out1] = test19(in1,in2,in3,in4,in5,in6,in7,in8,in9,in10,in11)
%test19: Function to do Qartod test 19 on a time series 
%   inputs:
% in1 - time vector : datenum format
% in2 - timeseries wave height : WVHGT
% in3 - timeseries wave period : WVPD
% in4 - timeseries wave direction : WVDIR
% in5 - timeseries wave spreading : WVSP
%    User defined test criteria
% in6 - Min wave height : MINWH (e.g. 0.05)
% in7 - Max wave height : MAXWH (e.g. 8)
% in8 - Min wave period : MINWP (e.g. 2)
% in9 - Max wave period : MAXWP (e.g. 16)
% in10 - Min spreading : MINSV  (e.g. 0.07)
% in11 - Max Spreading : MAXSV  (e.g. 1.0)
%
%     Outputs:
% out1 - QC test flag of same length of time vector. values 1,3,4. 
%        1 = pass (see Qartod manual
%        "QARTOD-IOOS_Manual_for_Real-Time_Quality_Control_of_Waves_v2.1.pdf"
%        3 = suspect
%        4 = fail 
%

tvec = in1 ; 
WVHGT = in2;
WVPD= in3;
WVDIR= in4;
WVSP=in5;
MINWH=in6;
MAXWH=in7;
MINWP=in8;
MAXWP=in9;
MINSV=in10;
MAXSV=in11;

% intialize QC flag vector

QCFlag  = zeros(length(WVHGT),1);
 
for ii=1:length(WVHGT)
    
   if WVHGT(ii)>MAXWH
       QCFlag(ii) = 4;
   elseif WVHGT(ii)<MINWH
       QCFlag(ii) = 4;
   elseif WVPD(ii) < MINWP
       QCFlag(ii) = 3;
   elseif WVPD(ii) > MAXWP
       QCFlag(ii) = 3;
   elseif WVDIR(ii) < 0
       QCFlag(ii) = 3;
   elseif WVDIR(ii) > 360
       QCFlag(ii) = 3;
   elseif WVSP(ii)< MINSV
       QCFlag(ii) = 3;
   elseif WVSP(ii) > MAXSV
       QCFlag(ii) = 3;
   else
       QCFlag(ii) = 1;
              
   end
end

out1 = QCFlag;

end

