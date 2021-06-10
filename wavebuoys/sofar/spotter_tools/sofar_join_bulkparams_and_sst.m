%% Joint Spotter version 2 surface temperature to bulkparams

% Spotter temperature is sampled every minute, but wave parameters only every 30 min. 
% This code just grabs the temperature data point that is closest to the bulkparameters
% timestamp and adds it to the bulkparameters structure. 

%input:
%    bulkparams structure containing time
%   sst structure containing raw temperature time stamps and values

%output:
%   out : bulkparams input structure with 'temp' field that has temperature values at corresponding time stamps

%M Cuttler, UWA, June 2021

%%

function [out] = sofar_join_bulkparams_and_sst(bulkparams, sst)
out = bulkparams; 
for i = 1:size(bulkparams.time,1)
    idx = find(abs(bulkparams.time(i)-sst.time)==min(abs(bulkparams.time(i)-sst.time))); 
    if isempty(idx)
        out.temp(i,1) = nan; 
    else
        if length(idx)>1
            out.temp(i,1) = sst.sst(idx(1));
        else
            out.temp(i,1) = sst.sst(idx);
        end
    end
end
end

            
    
   
    