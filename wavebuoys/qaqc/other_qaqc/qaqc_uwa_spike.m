%% Function for UWA spike test

% 1 = pass
% 2 = not assessed (insufficient data)
% 4 = fail

function [QCFlag] = qaqc_uwa_spike(data, roc,type)
%% wave data 

%spike test
for i = 1:size(data,1)
    if i == 1 | i == size(data,1)
        QCFlag(i,1) = 2; 
    else
        if strcmp(type,'directional')
            spike1 = abs(mod(data(i) - data(i-1) + 180,360)) - 180; 
            spike2 = abs(mod(data(i) - data(i-1) + 180,360)) - 180;             

        else
            spike1 = data(i) - data(i-1);
            spike2 = data(i+1) - data(i); 
        end
        
        if abs(spike1) > roc & abs(spike2) > roc
            QCFlag(i,1) = 4; 
        else
            QCFlag(i,1) =1; 
        end                        
    end
end

end