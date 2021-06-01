%% Process Datawell buoy data
% Add metadata - MC

%%

function [data] = Process_Datawell_post_process(buoy_info, data, file20, file21, file25, file28, file80, file82, file23, filed)

%Grab data from file21 and file28
data20 = importdata(file20);
data21 = importdata(file21);
data25 = importdata(file25);
data28 = importdata(file28);
data80 = importdata(file80);
data82 = importdata(file82);


%% Check to see if directory exists 
    %should be first data point for the month
    check = 0; 
    RefTime = datenum(1970,01,01);
    time20 = (data20(:,1).*(1/60).*(1/60).*(1/24))+RefTime;
    time21 = (data21(:,1).*(1/60).*(1/60).*(1/24))+RefTime;
    time25 = (data25(:,1).*(1/60).*(1/60).*(1/24))+RefTime;
    time28 = (data28(:,1).*(1/60).*(1/60).*(1/24))+RefTime; 
    time80 = (data80(:,1).*(1/60).*(1/60).*(1/24))+RefTime; 
    
    %energy density
    E = data20(:,4:end);
    
    %Extract wave direction (direction from in radians) and spread data (in
    %radians) --- LEAVE IN RADIANS FOR CALCULATION OF A1, B1, A2, B2
    theta = data21(:,4:103);
    s = data21(:,104:203);
    %m2 and n2
    m2 = data28(:,4:103);    
    n2 = data28(:,104:203); 
    
    %hs, tp, dp, dpspr
    spec_params = data25(:,[4,12,14,15]);
    
    [~, I20, I21] = intersect(time20, time21);
    time20 = time20(I20);
    E = E(I20,:);
    time21 = time21(I21);
    theta = theta(I21,:);
    s = s(I21,:);
    clear I20 I21
    
    [~,I20, I28] = intersect(time20, time28);
    time20 = time20(I20);
    E = E(I20,:);
    time21 = time21(I20);
    theta = theta(I20,:);
    s = s(I20,:);
    time28 = time28(I28);
    m2 = m2(I28,:);
    n2 = n2(I28,:);     
    
    [~,I20, I25] = intersect(time20, time25);
    time20 = time20(I20);
    E = E(I20,:);
    time21 = time21(I20);
    theta = theta(I20,:);
    s = s(I20,:);
    time28 = time28(I20);
    m2 = m2(I20,:);
    n2 = n2(I20,:); 
    time25 = time25(I25);
    spec_params = spec_params(I25,:);    
    
    %temperature, current data, and GPS
    [m,~] = size(data82.data);
    for i = 1:m
        time82(i,1) = (str2num(data82.textdata{i,1}).*(1/60).*(1/60).*(1/24))+RefTime;
    end        

    dw_vars = {'serialID','E','theta','s','m2','n2','time','a1','a2','b1','b2','frequency','ndirec','spec2D','hsig','tp','dp','dpspr', 'curr_mag','curr_dir','curr_mag_std','curr_dir_std','temp_time','surf_temp','bott_temp','w','w_std','gps_time','gps_pos'}; 
    for i = 1:length(dw_vars)
        data.(dw_vars{i}) = []; 
    end
    
    
    data = process_datawell_postprocess_wave_temp_current(buoy_info, E, theta, s, m2, n2, spec_params, time20, data80, time80, data82.data, time82, data);     
    
    %% process displacements 
    disp_data = importdata(filed); 
    %format text string for importing sync message based on datawell manual 
    fid = fopen(file23,'r'); 
    fmt = ['%f %f %f %f %s']; 
    sync_raw = textscan(fid, fmt); 
    fclose(fid); 
    
    for i = 1:size(sync_raw{1,1},1)
        sync_data.tstamp(i,1) = sync_raw{1,1}(i); 
        sync_data.datastamp(i,1) = sync_raw{1,2}(i); 
        sync_data.segs(i,1) = sync_raw{1,3}(i);
        sync_data.samples(i,1) = sync_raw{1,4}(i); 
    end
    
    %check things are correct sizes
    [times, I, ~] = unique(sync_data.tstamp); 
    check = sum(sync_data.samples(I)); 
    
    if check == size(disp_data.data,1)
        sync_data.time = sync_data.tstamp(I); 
        sync_data.t_utc = (sync_data.time./(60*60*24))+datenum(1970,1,1);
        sync_data.samples_unique = sync_data.samples(I);             
        
        cnts = cumsum(sync_data.samples_unique);         
        %check if all transmissions were 'g' - this could be done better 
        flags = disp_data.textdata(cnts); 
        
        %pad with extra cols for 30.5 min (should only be 30 but just in
        %case)
        cols = ceil(2.56*30.5*60); 
        data.disp_h = ones(size(sync_data.time,1),cols).*nan; 
        data.disp_n = ones(size(sync_data.time,1),cols).*nan; 
        data.disp_w = ones(size(sync_data.time,1),cols).*nan; 
        data.disp_time = ones(size(sync_data.time,1),cols).*nan; 
        
        for ii = 1:size(sync_data.time,1); 
            data.disp_tstart(ii,1) = sync_data.t_utc(ii); 
            if strcmp(flags(ii),'g')
                if ii == 1
                    dstart = 1;
                else
                    dstart = cnts(ii-1)+1;
                end
                %fill timestamp for each displacement
                for jj = 1:size(data.disp_h,2)
                    if jj == 1
                        data.disp_time(ii,jj) = data.disp_tstart(ii,1);
                    else
                        %DWR4 outputs at 2.56 Hz (I think)
                        data.disp_time(ii,jj) = data.disp_time(ii,jj-1)+((1/2.56)*(1/60)*(1/60)); 
                    end
                end
                data.disp_h(ii,1:sync_data.samples_unique(ii)) = disp_data.data(dstart:cnts(ii), 1);
                data.disp_n(ii,1:sync_data.samples_unique(ii)) = disp_data.data(dstart:cnts(ii), 2); 
                data.disp_w(ii,1:sync_data.samples_unique(ii)) = disp_data.data(dstart:cnts(ii), 3);                 
            end
        end
    else
        data.disp_tstart; data.disp_time = []; data.disp_h = []; data.disp_n = []; data.disp_w = [];
    end

end





