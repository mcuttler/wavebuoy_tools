%% Process Datawell buoy data
% Add metadata - MC

%%

function [data,archive_data,check] = Process_Datawell_realtime_website(buoy_info, data, file20, file21, file25, file28, file82)

%Grab data from file21 and file28
data20 = importdata(file20);
data21 = importdata(file21);
data25 = importdata(file25);
data28 = importdata(file28);
data82 = importdata(file82);


%% Export paths for figures and text file

pathMAT = [buoy_info.archive_path '\' buoy_info.name '\mat_archive']; 

%% Check to see if directory exists 
if exist(pathMAT)
    if exist([pathMAT '\' num2str(data.tnow(1)) '\' buoy_info.name '_' num2str(data.tnow(1)) num2str(data.tnow(2), '%02d') '.mat'],'file')
        check = 1; 
        load([pathMAT '\' num2str(data.tnow(1)) '\' buoy_info.name '_' num2str(data.tnow(1)) num2str(data.tnow(2),'%02d') '.mat']);
        archive_data = dw_data; 
    elseif exist([pathMAT '\' num2str(data.tnow(1)) '\' buoy_info.name '_' num2str(data.tnow(1)) num2str(data.tnow(2)-1, '%02d') '.mat'],'file')        
        check = 1; 
        load([pathMAT '\' num2str(data.tnow(1)) '\' buoy_info.name '_' num2str(data.tnow(1)) num2str(data.tnow(2)-1,'%02d') '.mat']);
        archive_data = dw_data; 
    elseif exist([pathMAT '\' num2str(data.tnow(1)-1) '\' buoy_info.name '_' num2str(data.tnow(1)-1) num2str(12) '.mat'],'file')&data.tnow(2)==1; 
        check = 1; 
        load([pathMAT '\' num2str(data.tnow(1)-1) '\' buoy_info.name '_' num2str(data.tnow(1)-1) num2str(12) '.mat']); 
        archive_data = dw_data; 
    end               
        
    RefTime = datenum(1970,01,01);
    time20 = (data20(:,1).*(1/60).*(1/60).*(1/24))+RefTime;
    time21 = (data21(:,1).*(1/60).*(1/60).*(1/24))+RefTime;
    time25 = (data25(:,1).*(1/60).*(1/60).*(1/24))+RefTime;
    time28 = (data28(:,1).*(1/60).*(1/60).*(1/24))+RefTime;
    
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
    
    %Get newest data from file, and check that everything is same
    %timestamps
    idx20 = find(time20>archive_data.time(end));
    idx21 = find(time21>archive_data.time(end));
    idx25 = find(time25>archive_data.time(end));
    idx28 = find(time28>archive_data.time(end));        
    
    [m,~] = size(data82.data);
    for i = 1:m
        time82(i,1) = (str2num(data82.textdata{i,1}).*(1/60).*(1/60).*(1/24))+RefTime;
    end
    idx82 = find(time82>archive_data.temp_time(end));
    
    if ~isempty(idx20)&&~isempty(idx21)&&~isempty(idx28)&&~isempty(idx25)&&~isempty(idx82)
        
        time20 = time20(idx20);
        E = E(idx20,:);   
        time21 = time21(idx21);
        theta = theta(idx21,:);
        s = s(idx21,:);
        time28 = time28(idx28);    
        m2 = m2(idx28,:);
        n2 = n2(idx28,:);
        time25 = time25(idx25);
        spec_params = spec_params(idx25,:);
        
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
        
        time = time20;                
        
        time82 = time82(idx82); 
        temp_data = data82.data(idx82,:); 
        data = process_datawell_realtime_wave_temp_current(buoy_info, E, theta, s, m2, n2, spec_params, time20, temp_data, time82, dw_data);     
    else
        %no new data
        data = archive_data;         
    end
    

else
    %should be first data point for the month
    check = 0; 
    mkdir([pathMAT '\' num2str(data.tnow(1))]); 
    archive_data = []; 
    RefTime = datenum(1970,01,01);
    time20 = (data20(:,1).*(1/60).*(1/60).*(1/24))+RefTime;
    time21 = (data21(:,1).*(1/60).*(1/60).*(1/24))+RefTime;
    time25 = (data25(:,1).*(1/60).*(1/60).*(1/24))+RefTime;
    time28 = (data28(:,1).*(1/60).*(1/60).*(1/24))+RefTime; 
    
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
    
    %temperature and current data
    [m,~] = size(data82.data);
    for i = 1:m
        time82(i,1) = (str2num(data82.textdata{i,1}).*(1/60).*(1/60).*(1/24))+RefTime;
    end        

    dw_vars = {'serialID','E','theta','s','m2','n2','time','a1','a2','b1','b2','frequency','ndirec','hsig','tp','dp','dpspr', 'curr_mag','curr_dir','curr_mag_std','curr_dir_std','temp_time','surf_temp','bott_temp','w','w_std'}; 
    for i = 1:length(dw_vars)
        data.(dw_vars{i}) = []; 
    end
    
    
    data = process_datawell_realtime_wave_temp_current(buoy_info, E, theta, s, m2, n2, spec_params, time20, data82.data, time82, data);     
    
end        


end

