%% process archived wave data

function [data] = process_datawell_realtime_wave_temp_current(E, theta, s, m2, n2, spec_params, wave_time, TC, temp_time, data); 

%% waves 
[m,~] = size(E);
[n,~] = size(data.E);

for ii = 1:m
    dumE = E(ii,:);
    dumtheta = theta(ii,:);
    dums =  s(ii,:);
    dumm2 =  m2(ii,:);
    dumn2 =  n2(ii,:);
    timewave =  wave_time(ii,:);
    
    % First calculate a1, b1
    a1 = (1 - (dums.^2)/2).*cos(dumtheta);   
    b1 = (1 - (dums.^2)/2).*sin(dumtheta);        
    
    % Now calculate a2, b2                
    theta2 = 2.*dumtheta;    
    theta2 = 2.*dumtheta;
    
    a2 = dumm2.*cos(theta2) - dumn2.*sin(theta2);
    b2 = dumm2.*sin(theta2) + dumn2.*cos(theta2);                       
    
    % Compute frequency for direction wave rider (DWR) 4 - pg 25 in Datawell manual    
    %f(k) = 0.025+0.005*k for 0<k<46   (0.025 to 0.25 Hz)
    %f(k) = -0.20+0.010*k for 46<k<79  (0.26 to 0.58 Hz)
    %f(k) = -0.98+0.020*k for 79<k<100 (0.6 to 1.00 Hz)
    
    for k = 0:99
        if k>=0&&k<=46
            frequency(k+1,1) = 0.025+0.005*k;
        elseif k>46&&k<=79
            frequency(k+1,1) = -0.20+0.010*k;
        elseif k>79            
            frequency(k+1,1) = -0.98+0.020*k;
        end
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Now calculate spectra using Lygre and Krogstad (code from T Jonsson)                        
    % addpath('.\Janssen_MEM');            
    %1 degree resolution output (for plotting on website)        
    [NS(:,:,ii), NE(:,:,ii), ndirec] = lygre_krogstad_MC(a1,a2,b1,b2,dumE,1);
    
    [ndirec,I] = sort(ndirec);
    NS(:,:,ii) = NS(:,I,ii);
    NE(:,:,ii) = NE(:,I,ii);                 
    % plot MEM results
    hsig = spec_params(ii,1);
    tp = spec_params(ii,2);
    dp = rad2deg(spec_params(ii,3));   
    dpspr = rad2deg(spec_params(ii,4)); 
    
    %update waves output
    data.E = [data.E; dumE];
    data.theta = [data.theta; dumtheta];
    data.s = [data.s; dums];
    data.m2 = [data.m2; dumm2];
    data.n2 = [data.n2; dumn2];
    data.time = [data.time; timewave];
    data.a1 = [data.a1; a1];
    data.a2 = [data.a2; a2];
    data.b1 = [data.b1; b1];
    data.b2 = [data.b2; b2];
    data.frequency = frequency'; 
    data.ndirec = ndirec;
%     data.spec1D = [waves.spec1D; spec1D'];
    data.hsig = [data.hsig; hsig];
    data.tp = [data.tp; tp];
    data.dp = [data.dp; dp];
    data.dpspr = [data.dpspr; dpspr]; 
end  


%% temperature 
% function [temp_curr] = process_realtime_temp_curr_data(TC, time, temp_curr)
%only keep select columns (see Datawell manual pg 37), note, column values
%in variable 'data82' are off by 3 compared to manual as columns 1-3 get
%stored in data82.textdata when imported        
[m,~] = size(TC);

for ii = 1:m
    %4 - current speed (m/s)        
    data.curr_mag= [data.curr_mag;TC(ii,1)];
    %5 - direction to (rad)
    data.curr_dir= [data.curr_dir; rad2deg(TC(ii,2))];
    %6 - std of speed (m/s)
    data.curr_mag_std = [data.curr_mag_std;TC(ii,3)];
    %7 - std (direction to (rad)
    data.curr_dir_std = [data.curr_dir_std;rad2deg(TC(ii,4))];
    %11 - water temp (records in K, convert to degC)
    data.surf_temp = [data.surf_temp; TC(ii,8)-273.15];
    %13 - vertical velocity (m/s)
    data.w = [data.w; TC(ii,10)];
    %14 - std of veritcal velocity (m/s)
    data.w_std = [data.w_std; TC(ii,11)];
    data.temp_time = [data.temp_time; temp_time(ii,1)];
    %Datawell moorings do not have bottom temperature
    data.bott_temp = [data.bott_temp; -9999]; 
end
    
end
