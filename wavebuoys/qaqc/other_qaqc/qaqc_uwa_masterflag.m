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

function [QCFlagWave, QCFlagTemp] = qaqc_uwa_masterflag(in, hs, tp,temp)
%% wave data 
QCFlagWave =[]; 

%range test
for i = 1:size(in.time,1)
    if hs(i)>in.HsLim | hs(i)<in.tp(i)>in.TpLim
        QCFlagWave(i,1) = 4; 
    end
end

%spike test
for i = 1:size(in.time,1)
    if ielse
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
            QCFlagWave = [QCFlagWave; 4];
        else
            QCFlagWave = [QCFlagWave; 1]; 
        end        
    end
end
                    
%% temperature data
QCFlagTemp =[]; 
%first find spikes
for i = 1:size(in.time,1)
    if i == 1
        QCFlagTemp(i,1) = 4; 
    elseif i == size(in.time,1)
        QCFlagTemp(i,1) = 4; 
    elseif temp(i)>in.TLim | temp(i)>in.TLim
        QCFlagTemp(i,1) = 4; 
    else        
        dumT = diff(temp(i-1:i+1)); 
        
        %check T spikes
        if dumT(1)>0&dumT(2)<0&abs(dumT)>in.rocT
            checkT = 4; 
        %negative spike
        elseif dumT(1)<0&dumT(2)>0&abs(dumT)>in.dumT
            checkT = 4; 
        else
            checkT = 1;
        end        
      
        %add QC value 
        if checkT==4
            QCFlagTemp = [QCFlagTemp; 4];
        else
            QCFlagTemp = [QCFlagTemp; 1]; 
        end        
    end
end


end