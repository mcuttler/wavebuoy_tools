%% Function for UWA spike test

% 1 = pass
% 2 = not assessed (insufficient data)
% 4 = fail

function [QCFlag] = qaqc_uwa_spike(time, data, roc)
%% wave data 
QCFlag =[]; 
%spike test
for i = 1:size(time,1)
    if i == 1
        QCFlag = [QCFlag; 2]; 
    elseif i == size(time,1)
        QCFlag = [QCFlag; 2]; 
    else
        dum = diff(data(i-1:i+1)); 
        
        %check spikes
        if dum(1)>0&dum(2)<0&abs(dum)>roc
            check_data = 4; 
        %negative spike
        elseif dum(1)<0&dum(2)>0&abs(dum)>roc
            check_data = 4; 
        else
            check_data = 1;
        end
        
        %add QC value 
        if check_data==4
            QCFlag = [QCFlag; 4];
        else
            QCFlag = [QCFlag; 1];
        end
    end
end

end