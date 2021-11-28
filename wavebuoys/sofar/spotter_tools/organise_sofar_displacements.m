%% Organise Sofar FLT from specific buoys

% Use 'process_SofarSpotter_delayed_mode to get displacements, then
% organise into hourly blocks 

%MC - Novemeber 2021

%% data paths and buoy to process 
clear; clc; 
% lcoation of all 'raw' delayed mode data for Spotters
datapath = 'X:\LOWE_IMOS_Deakin_Collab_JUN2020\Data\SofarSpotter\RAW_delayed_mode'; 

%sofar parser 
parserpath = 'X:\LOWE_IMOS_Deakin_Collab_JUN2020\Data\SofarSpotter\SofarParser\parser_v1.12.0'; 
parser = 'parser_v1.12.0.py'; 

% specific folders for buoys to process, uncomment for each buoy - could
% process all together, but easier for now to do one at a time

%Torbay East
spotname = 'TorbayEast'; 
spotdata = {'SPOT0171_TorbayEast_20200319_to_20200529';'SPOT0171_TorbayEast_20210212_to_20210712';'SPOT0559_TorbayEast_20210710_to_20210907'}; 
%Torbay West 
% spotname = 'TorbayWest'; 
% spotdata = {'SPOT0172_TorbayWest_20190131_to_20200316';'SPOT0757_TorbayWest_20210212_to_20210712';'SPOT0757_TorbayWest_20210712_to_20210827'}; 
%Cape Bridgewater
% spotname = 'CapeBW'; 
% buoyddata ={'SPOT0297_CapeBridgewater_20191124_to_20200722'};
%Tantabiddi 
% spotname = 'Tantabiddi'; 
% spotdata = {'SPOT0558_Tantabiddi_20201101_20210401'}; 

%% get displacement data 

for k = 1:length(spotdata)
    clc; 
    sofarpath = fullfile(datapath,spotdata{k},'Raw'); 
    
    [bulkparams, displacements, locations, spec, ~] = process_SofarSpotter_delayed_mode(sofarpath, parserpath, parser, 10);
    
    
    %save to dout
    if k == 1
        dout = ddisp; 
    else
        fields = fieldnames(dout); 
        for jj = 1:length(fields)
            dout.(fields{jj}) = [dout.(fields{jj}); ddisp.(fields{jj})]; 
        end
    end
    
    %rename to buoy name if last buoy folder
    if k == length(spotdata)
        eval([spotname '=dout;']); 
    end
    clear ddisp
end

%% Now organise to hourly blocks 
eval(['dt = datevec(' spotname '.timeutc);']); 
eval(['dbuoy = ' spotname ';']); 
hrs = unique(dt(:,1:4),'rows'); 
[r,c] = size(hrs); 
dhourly = struct('timeutc',ones(r,10000).*nan,'x',ones(r,10000).*nan,'y',ones(r,10000).*nan,'z',ones(r,10000).*nan); 
for j = 1:size(hrs,1); 
    idx = find(dt(:,1) == hrs(j,1) & dt(:,2) == hrs(j,2) & dt(:,3) == hrs(j,3) & dt(:,4) == hrs(j,4)); 
    dhourly.timeutc(j,1:length(idx)) = dbuoy.timeutc(idx)'; 
    dhourly.x(j,1:length(idx)) = dbuoy.x(idx)'; 
    dhourly.y(j,1:length(idx)) = dbuoy.y(idx)'; 
    dhourly.z(j,1:length(idx)) = dbuoy.z(idx)';
end

    
    

    
    
