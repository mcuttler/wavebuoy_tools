
function [dw_data] = organise_datawell_data(check, buoy_info, data); 

%Grab data from file21 and file28
data20 = importdata(data.file20);
data21 = importdata(data.file21);
data25 = importdata(data.file25);
data28 = importdata(data.file28);
data82 = importdata(data.file82);

%%
if check>0
    %load in existing data
    load([buoy_info.archive_path '\' num2str(data.tnow(1)) '\' buoy_info.name '_' num2str(data.tnow(1)) num2str(data.tnow(2),'%02d') '.mat']);
    
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
    
    %hs, tp, dp
    spec_params = data25(:,[4,12,14]);
    
    %Get newest data from file, and check that everything is same
    %timestamps
    idx20 = find(time20>waves.timewave(end));
    idx21 = find(time21>waves.timewave(end));
    idx25 = find(time25>waves.timewave(end));
    idx28 = find(time28>waves.timewave(end));    
    
    if ~isempty(idx20)&&~isempty(idx21)&&~isempty(idx28)&&~isempty(idx25)
        
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
        dw_data.E = E(I20,:);
        time21 = time21(I20);
        dw_data.theta = theta(I20,:);
        dw_data.s = s(I20,:);
        time28 = time28(I20);
        dw_data.m2 = m2(I20,:);
        dw_data.n2 = n2(I20,:); 
        time25 = time25(I25);
        dw_data.spec_params = spec_params(I25,:);
        
        dw_data.time = time20;          
        
    end    
else
    %should be first data point for the month
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
    
    %hs, tp, dp
    spec_params = data25(:,[4,12,14]);
    
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
    dw_data.E = E(I20,:);
    time21 = time21(I20);
    dw_data.theta = theta(I20,:);
    dw_data.s = s(I20,:);
    time28 = time28(I20);
    dw_data.m2 = m2(I20,:);
    dw_data.n2 = n2(I20,:); 
    time25 = time25(I25);
    dw_data.spec_params = spec_params(I25,:);       
    dw_data.time = time20;     
    
end        


end
