%% Process Datawell buoy data

%This code calculates a1,b1,a2,b2 coefficients needed to estimate the 2D
%wave spectrum. Datawell buoy sends m2, n2, spreading, and wave direction.
%Wave direction (theta) and spreading are provided in message 0x321 (file21
%below). m2 and n2 are provided in message 0x328 (file28 below). 

%The following relationships are from Data well manual
%(pg 32, datawell_manual_dwr4_2017-08-10.pdf):

%1) theta = atan(b1/a1) ---- wave direction from (radians)
%2) m1 = sqrt(a1^2+b2^2)
%3) m2 = a2*cos(2*theta)+b2*sin(2*theta)
%4) n2 = -a2*sin(2*theta)+b2*cos(2*theta)
%5) s = sqrt(2-2*m1) --- s = spread (radians)

%Rearranging equations 1, 2, and 5 yields (equations taken from 'calc_a1_b1_a2_b2.f' from CDIP): 
%a1 = (1 - (s^2)/2)*cos(theta)
%b1 = (1 - (s^2)/2)*sin(theta)

%Rearranging equations 3 and 4 yields (calculated by M Cuttler, May 2018)
%theta2 = 2*theta;
% a2 = ((m2*cos(theta2))-n2)/(cos(theta2)^2+sin(theta2))
% b2 = n2 + ((a2*sin(theta2))/cos(theta2))

%a1, a2, b1, b2, and Energy can be used to calculated 2D spectra using
%Maximum Entropy Method (MEM) following Lygre and Krogstad, JPO v16 1986

%NOTE: timestamp from Datawell indicates time at which data aqcuisition
%started for the data that was transmitted 


%M Cuttler
%UWA
%
%version 1 - May 2018

%version 2 - MCuttler, March 2019
    %update to re-arrange data storage on AWS
%version 3 - MCuttler, June 2019
    %update to include temperature and surface current data
    %modify output paths
    %update to check that timestamp is same across all files
    %update to write .MAT file only for monthly data
    %update to account for all new data (if CSV is appended more regularly
    %than code runs)
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%INFO REGARDING INPUT PARAMETERS
%file20 is path for location of datawell message 0xF20 - Heave spectrum
%message (pg. 25-26)
%file21 is path for location of datawell message 0xF21 - Primary direction
%spectrum (pg. 26)
%file28 is path for location of datawell message 0xF28 - secondary
%directional spectrum (pg. 27-28)
%file82 is path for location of datawell message 0xF82 - acoustic current
%meter and temperature (pg. 36-37)


%All page numbers referenced are in 
%P:\HANSEN_Albany_WaveEnergy_Feasibility_ongoing\Analysis\WaveBuoys\datawell_specification_csv_file_formats_s-02-v1-5-0.pdf

%%


function [waves, temp_curr] = Process_Datawell_realtime_DevSite(file20, file21, file25, file28, file82,yr, mm, BND)

%Grab data from file21 and file28
data20 = importdata(file20);
data21 = importdata(file21);
data25 = importdata(file25);
data28 = importdata(file28);
data82 = importdata(file82);

buoyname = 'TorbayInshore';

%% Export paths for figures and text file
%MC Laptop Paths for testing 
% path1D = 'L:\DatawellBuoys\TorbayInshore\Spec1D';
% path2D = 'L:\DatawellBuoys\TorbayInshore\Spec2D';
% pathMEMplot = 'L:\DatawellBuoys\TorbayInshore\MEMplot';
% pathMAT = 'L:\DatawellBuoys\TorbayInshore\MAT';
% pathMAT2 = 'L:\HANSEN_Albany_WaveEnergy_Feasibility_ongoing\Analysis\WaveBuoys\Data\UWA\Processed\TorbayInshore\MAT';

%UWA VM paths for real time running
path1D = 'E:\DatawellBuoys\TorbayInshore\Spec1D';
path2D = 'E:\DatawellBuoys\TorbayInshore\Spec2D';
pathMEMplot = 'E:\DatawellBuoys\TorbayInshore\MEMplot';
pathMAT = 'E:\DatawellBuoys\TorbayInshore\MAT';
pathMAT2 = '\\drive.irds.uwa.edu.au\SEE-PNP-001\HANSEN_Albany_WaveEnergy_Feasibility_ongoing\Analysis\WaveBuoys\Data\UWA\Processed\TorbayInshore\MAT';

if exist([pathMEMplot '\' yr '\' mm],'dir')==0
    mkdir([pathMEMplot '\' yr '\' mm]);
    mkdir([path1D '\' yr '\' mm]);
    mkdir([path2D '\' yr '\' mm]);
    
    %only save .mat files per month, so only need yr folder 
    mkdir([pathMAT '\' yr]);
    mkdir([pathMAT2 '\' yr]);
end

%% Check to see if monthly .mat already exist, if so, load it
if exist([pathMAT '\' yr '\TorbayInshore_' yr mm '.mat'],'file')
    load([pathMAT '\' yr '\TorbayInshore_' yr mm '.mat']);
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
        %calculate 2D spectra, create plots, and append new data        
        [waves] = process_realtime_wave_data(E, theta, s, m2, n2, spec_params,...
            time, pathMEMplot, path1D, path2D, buoyname,waves);        
        
    end
    
    %process temperature/current data if it has new data                
    [m,~] = size(data82.data);
    for i = 1:m
        time82(i,1) = (str2num(data82.textdata{i,1}).*(1/60).*(1/60).*(1/24))+RefTime;
    end
    idx82 = find(time82>temp_curr.timecurr(end));
    if ~isempty(idx82)
        [temp_curr] = process_realtime_temp_curr_data(data82.data(idx82,:),time82(idx82), temp_curr);
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
    E = E(I20,:);
    time21 = time21(I20);
    theta = theta(I20,:);
    s = s(I20,:);
    time28 = time28(I20);
    m2 = m2(I20,:);
    n2 = n2(I20,:); 
    time25 = time25(I25);
    spec_params = spec_params(I25,:);
    
   
    waves = struct('E',[],'theta',[],'s',[],'m2',[],'n2',[],'timewave',[],...
        'a1',[],'a2',[],'b1',[],'b2',[],'freq',[],'ndirec',[],'spec1D',[],...
        'hs',[],'tp',[],'dp',[]);    

    [waves] = process_realtime_wave_data(E, theta, s, m2, n2, spec_params,...
        time20, pathMEMplot, path1D, path2D, buoyname,waves);  
    
    %temperature and current data
    [m,~] = size(data82.data);
    for i = 1:m
        time82(i,1) = (str2num(data82.textdata{i,1}).*(1/60).*(1/60).*(1/24))+RefTime;
    end    
    temp_curr = struct('curr_mag',[],'curr_dir',[],'curr_mag_std',[],...
        'curr_dir_std',[],'T',[],'w',[],'w_std',[],'timecurr',[]);
    [temp_curr] = process_realtime_temp_curr_data(data82.data,time82, temp_curr);
    
end        

%% save .mat file as monthly file
if exist([pathMAT '\' yr])
    save([pathMAT '\' yr '\TorbayInshore_' yr mm '.mat'],'-v7.3','waves','temp_curr');  
    save([pathMAT2 '\' yr '\TorbayInshore_' yr mm '.mat'],'-v7.3','waves','temp_curr');  
else
    mkdir([pathMAT '\' yr]);
    mkdir([pathMAT2 '\' yr]);
    save([pathMAT '\' yr '\TorbayInshore_' yr mm '.mat'],'-v7.3','waves','temp_curr');  
    save([pathMAT2 '\' yr '\TorbayInshore_' yr mm '.mat'],'-v7.3','waves','temp_curr');  
end

%% Write Swan boundary file from NE
% if BND==1
%     %Store as delimited text for later use
%     pathout = '\\drive.irds.uwa.edu.au\SEE-PNP-001\HANSEN_Albany_WaveEnergy_Feasibility_ongoing\Analysis\WaveBuoys\Processing\BuoySpectralData\Offshore';
%     dlmwrite([pathout '\' num2str(datestr(time,'yyyymmdd_HHMMSS')) '.dat'],NEswan,'newline','pc','delimiter','\t');
%     
%     
%     
%     pathout = '\\drive.irds.uwa.edu.au\SEE-PNP-001\HANSEN_Albany_WaveEnergy_Feasibility_ongoing\Analysis\SWAN\TestExecutables\BuoyTest\';
%     fname_out = 'OffBuoy_A.bnd';
%     
%     Buoy_to_SwanBnd(pathout,fname_out,NEswan,ndirecSwan,freq,time);
% end

end

