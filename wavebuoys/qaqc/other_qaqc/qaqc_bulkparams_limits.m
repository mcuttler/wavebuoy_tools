%% QAQC - brute force

% Set basic limits for rough quality control on delayed mode data
% 
% Includes: 
%  - max wave period
%  - wave height step

%input must contain values for these limits:
%     in.maxT = 25; 
%     in.diffHS = [0.5 1]; 


%Flags:
%     1 = pass
%     3 = suspect
%     4 = fail 

%%

function [QCflag] = qaqc_bulkparams_limits(in)

QCflag = ones(size(in.time,1),2).*-9999;
%flag based on change in wave height
%assume first time point is suspect
for i = 1:size(in.time,1)
    if i == 1
        QCflag(i,1) = 3; 
    elseif in.WVHGT(i,1) - in.WVHGT(i-1,1) > in.diffHS(1)
        if in.WVHGT(i,1) - in.WVHGT(i-1,1) > in.diffHS(2)
            QCflag(i,1) = 4;
        else
            QCflag(i,1) = 3;
        end
    else
        QCflag(i,1) = 1;
    end
end

%flag based on period
for i =1:size(in.time,1)
    if in.WVPD(i,1)>in.maxT
        QCflag(i,2) = 4;
    else
        QCflag(i,2) = 1; 
    end
end

end


    