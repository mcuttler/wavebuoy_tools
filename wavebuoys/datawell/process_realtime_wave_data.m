%% process archived wave data

function [waves] = process_realtime_wave_data(E, theta, s, m2, n2, spec_params, time, pathMEMplot, path1D, path2D, buoyname, waves)

[m,~] = size(E);
[n,~] = size(waves.E);

for ii = 1:m
    dumE = E(ii,:);
    dumtheta = theta(ii,:);
    dums =  s(ii,:);
    dumm2 =  m2(ii,:);
    dumn2 =  n2(ii,:);
    timewave =  time(ii,:);
    
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
            freq(k+1,1) = 0.025+0.005*k;
        elseif k>46&&k<=79
            freq(k+1,1) = -0.20+0.010*k;
        elseif k>79            
            freq(k+1,1) = -0.98+0.020*k;
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
    hs = spec_params(ii,1);
    tp = spec_params(ii,2);
    dp = rad2deg(spec_params(ii,3));
    
    make_MEM_plot(ndirec, freq, NE(:,:,ii), hs, tp, dp, timewave, buoyname, pathMEMplot);
    
    %write 1D and 2D spectra to text
    [spec1D] = export_spec1d_spec2d(path1D, path2D, freq, ndirec, NE(:,:,ii), timewave, buoyname);
    
    %update waves output
    waves.E = [waves.E; dumE];
    waves.theta = [waves.theta; dumtheta];
    waves.s = [waves.s; dums];
    waves.m2 = [waves.m2; dumm2];
    waves.n2 = [waves.n2; dumn2];
    waves.timewave = [waves.timewave; timewave];
    waves.a1 = [waves.a1; a1];
    waves.a2 = [waves.a2; a2];
    waves.b1 = [waves.b1; b1];
    waves.b2 = [waves.b2; b2];
    waves.freq = freq;
    waves.ndirec = ndirec;
    waves.spec1D = [waves.spec1D; spec1D'];
    waves.hs = [waves.hs; hs];
    waves.tp = [waves.tp; tp];
    waves.dp = [waves.dp; dp];
end  
    %Dont save 2D spectra as makes monthly file too big!
%     [~,~,o] = size(NE);
%     waves.spec2D(:,:,n+1:o+n) = NE; 
%     waves.spec2D_normalized(:,:,n+1:o+n) = NS;
    
end
