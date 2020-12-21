%% Function for 'master' QA/QC flag

% This code combines QARTOD test 19 and QARTOD test 20. 
% It first uses an approach similar to test 19 and checks for points outside of Hs and Tp range. 
% The modified time series is then checked for test 20 (rate of change) and looks for 'spikes' in the data, 
% that correspond to a positive and negative rate of change above/below given threshold. 

%This will optionally remove bad data and flag as -9999 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%     
% Code history
% 
%     Author          | Date             | Script Version     | Update
%     --------------------------------------------------------
%     M. Cuttler     | 21 Dec 2020 | 1.0                      | Initial creation
% --------------------------------------------------------------------------------------------------------------------------------
%    

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [QCFlag] = qaqc_uwa_masterflag(in, hs, tp)
QCFlag =[]; 
%first find spikes
for i = 1:size(in.time,1)
    if i == 1
        QCFlag(i,1) = 4; 
    elseif i == size(in.time,1)
        QCFlag(i,1) = 4; 
    elseif hs(i)>in.HsLim | tp(i)>in.TpLim
        QCFlag(i,1) = 4; 
    else        
        dumHs = diff(hs(i-1:i+1)); 
        dumTp = diff(tp(i-1:i+1)); 
        
        %check Hs spikes
        if dumHs(1)>0&dumHs(2)<0&abs(dumHs)>in.rocHs
            checkHs = 4; 
        %negative spike
        elseif dumHs(1)<0&dumHs(2)>0&abs(dumHs)>in.rocHs
            checkHs = 4; 
        else
            checkHs = 1;
        end
        
        %check Tp spikes
        if dumTp(1)>0&dumTp(2)<0&abs(dumTp)>in.rocTp
            checkTp = 4; 
         %negative spike
        elseif dumTp(1)<0&dumTp(2)>0&abs(dumTp)>in.rocTp
            checkTp = 4; 
        else
            checkTp = 1;
        end
        
        %add QC value 
        if checkTp==4|checkHs==4
            QCFlag = [QCFlag; 4];
        else
            QCFlag = [QCFlag; 1]; 
        end        
    end
end
                          


end