%% Organise Sofar FLT from specific buoys

% Use 'process_SofarSpotter_delayed_mode to get displacements, then
% organise into hourly blocks 

%MC - Novemeber 2021

%% data paths and buoy to process 
clear; clc; 
% lcoation of all 'raw' delayed mode data for Spotters
datapath = 'I:\Active_Projects\LOWE_IMOS_WaveBuoys\Data\SofarSpotter\RAW_delayed_mode'; 

%sofar parser 
parserpath = 'I:\Active_Projects\LOWE_IMOS_WaveBuoys\Data\SofarSpotter\SofarParser\parser_v1.12.0'; 
parser = 'parser_v1.12.0.py'; 

% specific folders for buoys to process, uncomment for each buoy - could
% process all together, but easier for now to do one at a time

%Torbay East
spotname = {'TorbayEast','TorbayWest','CapeBW','Tantabiddi'};
spotdata= {'SPOT0171_TorbayEast_20200319_to_20200529','SPOT0171_TorbayEast_20210212_to_20210712','SPOT0559_TorbayEast_20210710_to_20210907'}; 
spotdata{2,1} =  'SPOT0172_TorbayWest_20190131_to_20200316'; 
spotdata{2,2} = 'SPOT0757_TorbayWest_20210212_to_20210712'; 
spotdata{2,3} = 'SPOT0757_TorbayWest_20210712_to_20210827'; 
spotdata{3,1} = 'SPOT0297_CapeBridgewater_20191124_to_20200722';
spotdata{4,1} = 'SPOT0558_Tantabiddi_20201101_20210401';

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
clc;

for s = 2:length(spotname)
    disp(['Getting data for ' spotname{s}]); 
    if s == 1 | s == 2
        kk = 3;
    else
        kk = 1; 
    end
    
    for k = 1:kk  
        sofarpath = fullfile(datapath,spotdata{s,k},'Raw'); 
        
        %     [bulkparams, displacements, locations, spec, ~] = process_SofarSpotter_delayed_mode(sofarpath, parserpath, parser, 10);
        [~, displacements, ~, ~, ~] = process_SofarSpotter_delayed_mode(sofarpath, parserpath, parser, 10);
        
        
        %save to dout
        if k == 1
            dout = displacements; 
        else
            fields = fieldnames(dout);
            for jj = 1:length(fields)
                dout.(fields{jj}) = [dout.(fields{jj}); displacements.(fields{jj})]; 
            end
        end
        
        %rename to buoy name if last buoy folder
        if k == kk
            eval([spotname{s} '=dout;']); 
        end
        clear displacements
    end
    
    %% Now organise to hourly blocks
    clc; 
    disp('Hourly blocking'); 
    eval(['dt = datevec(' spotname{s} '.time);']); 
    eval(['dbuoy = ' spotname{s} ';']); 
    hrs = unique(dt(:,1:4),'rows'); 
    [r,c] = size(hrs); 
    %this should be 2.5 hz * 3600 s = 9000
    sample_rate = 2.5; 
    blocks = 3600; 
    dum_block = ones(r,sample_rate*blocks).*nan; 
    
    dbuoy.time_hourly = dum_block; 
    dbuoy.x_hourly = dum_block; 
    dbuoy.y_hourly = dum_block; 
    dbuoy.z_hourly = dum_block; 
    
    for j = 1:size(hrs,1); 
        idx = find(dt(:,1) == hrs(j,1) & dt(:,2) == hrs(j,2) & dt(:,3) == hrs(j,3) & dt(:,4) == hrs(j,4)); 
        dbuoy.time_hourly(j,1:length(idx)) = dbuoy.time(idx)'; 
        dbuoy.x_hourly(j,1:length(idx)) = dbuoy.x(idx)'; 
        dbuoy.y_hourly(j,1:length(idx)) = dbuoy.y(idx)'; 
        dbuoy.z_hourly(j,1:length(idx)) = dbuoy.z(idx)';
        clear idx 
    end
    
    eval([spotname{s} '=dbuoy;']);
    clear dbuoy
    
    %save somewhere
    outpath = 'I:\Active_Projects\LOWE_IMOS_WaveBuoys\Data\Displacements_for_final_STAC';
    savename = [spotname{s} '_displacements.mat']; 
    savefile = fullfile(outpath,savename); 
    
    save(savefile, strcat('', spotname{s},''),'-v7.3'); 
     

end





    
    

    
    
