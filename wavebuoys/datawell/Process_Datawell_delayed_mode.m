%% Process Datawell buoy data
% Add metadata - MC

%%

function [data] = Process_Datawell_delayed_mode(buoy_info, file20, file21, file25, file28, file80, file82, file23, filed)

% Grab data 
data20 = importdata(file20);
data21 = importdata(file21);
data25 = importdata(file25);
data28 = importdata(file28);
data80 = importdata(file80);
data82 = importdata(file82);


% extract data  
RefTime = datenum(1970,01,01);
time20 = (data20(:,1).*(1/60).*(1/60).*(1/24))+RefTime;
time21 = (data21(:,1).*(1/60).*(1/60).*(1/24))+RefTime;
time25 = (data25(:,1).*(1/60).*(1/60).*(1/24))+RefTime;
time28 = (data28(:,1).*(1/60).*(1/60).*(1/24))+RefTime; 
time80 = (data80(:,1).*(1/60).*(1/60).*(1/24))+RefTime; 

[m,~] = size(data82.data);
for i = 1:m
    time82(i,1) = (str2num(data82.textdata{i,1}).*(1/60).*(1/60).*(1/24))+RefTime;
end        

%% organise wave data and check to be same times 
%energy density
E = data20(:,4:end);

%Extract wave direction (direction from in radians) and spread data (in
%radians) --- LEAVE IN RADIANS FOR CALCULATION OF A1, B1, A2, B2
theta = data21(:,4:103);
s = data21(:,104:203);
%m2 and n2
m2 = data28(:,4:103);    
n2 = data28(:,104:203); 

%hs, tm, tp, dp, dpspr
spec_params = data25(:,[4,7,12,14,15]);

%check that times match up 
[~, I20, I21] = intersect(time20, time21);
time20 = time20(I20);
E = E(I20,:);
time21 = time21(I21);
theta = theta(I21,:);
s = s(I21,:);
clear I20 I21

%check again that times match 
[~,I20, I28] = intersect(time20, time28);
time20 = time20(I20);
E = E(I20,:);
time21 = time21(I20);
theta = theta(I20,:);
s = s(I20,:);
time28 = time28(I28);
m2 = m2(I28,:);
n2 = n2(I28,:);     

%check times one more time
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
%% only keep latitude/longitude at some time as waves
for i = 1:size(time25,1)
    ind = find(abs(time25(i) - time80)==min(abs(time25(i) - time80))); 
    data.lon(i,1) = rad2deg(data80(ind,4)); 
    data.lat(i,1) = rad2deg(data80(ind,3)); 
end
clear ind i 
%% calculate frequency and spectral coefficients     

%bulk parameters 
data.hs = spec_params(:,1);
data.tm = spec_params(:,2); 
data.tp = spec_params(:,3);
data.dp = rad2deg(spec_params(:,4));   
data.dpspr = rad2deg(spec_params(:,5));        
for i = 1:size(data.hs,1)
    data.serial{i,1} = buoy_info.serial; 
end
data.time =  time25;    

%spectral parameters 
 data.E = E;
 data.theta = theta;
 data.s =  s;
 data.m2 =  m2;
 data.n2 =  n2;

 % First calculate a1, b1
 data.a1 = (1 - (data.s.^2)/2).*cos(data.theta);   
 data.b1 = (1 - (data.s.^2)/2).*sin(data.theta);        
 
 % Now calculate a2, b2                
 theta2 = 2.*data.theta;     
 data.a2 = data.m2.*cos(theta2) - data.n2.*sin(theta2);
 data.b2 = data.m2.*sin(theta2) + data.n2.*cos(theta2);                       
 clear theta2 
 % Compute frequency for direction wave rider (DWR) 4 - pg 25 in Datawell manual    
 for k = 0:99
     if k>=0&&k<=46
         data.frequency(1:size(data.a1,1),k+1) = 0.025+0.005*k;
     elseif k>46&&k<=79
         data.frequency(1:size(data.a1,1),k+1) = -0.20+0.010*k;
     elseif k>79            
         data.frequency(1:size(data.a1,1),k+1) = -0.98+0.020*k;
     end
 end


 %% add temperature and current velocity data
 data.curr_mag=data82.data(:,1); 
 % direction to (rad)
 data.curr_dir= rad2deg(data82.data(:,2)); 
 % std of speed (m/s)
 data.curr_mag_std = data82.data(:,3); 
 % std (direction to (rad)
 data.curr_dir_std = rad2deg(data82.data(:,4)); 
 % water temp (records in K, convert to degC)
 data.surf_temp =data82.data(:,8)-273.15; 
 % vertical velocity (m/s)
 data.w =  data82.data(:,10); 
 % std of vertical velocity (m/s)
 data.w_std = data82.data(:,11); 
 data.temp_time = time82(:,1); 
 %Datawell moorings do not have bottom temperature
 data.bott_temp = ones(size(data.temp_time,1),1).* -9999;      
 %% process displacements 
 [disp_data] = datawell_decode_displacements(file23, filed); 
 
 data.disp_time = ones(size(disp_data.disp_h,1), size(disp_data.disp_h,4608)).*nan; 
 data.disp_time(:,1) = disp_data.disp_time_utc; 
 data.x = -disp_data.disp_w(:,1:4608); %converts to E! 
 data.y = disp_data.disp_n(:,1:4608); 
 data.z = disp_data.disp_h(:,1:4608); 

 %create unique time based on sample rate for datawell (2.56 Hz)
 dt = (1/2.56)*(1/60)*(1/60)*(1/24);
 for ii = 1:size(data.disp_time,1)
     for jj =2:size(data.x,2)
         data.disp_time(ii,jj) = data.disp_time(ii,jj-1)+dt; 
     end
 end

end





