%% process archived wave data

function [waves] = process_archived_wave_data(E, theta, s, m2, n2, spec_params, time, pathMEMplot, path1D, path2D, buoyname)
 
[m,~] = size(E);

for ii = 1:m
    waves.E(ii,:) = E(ii,:);
    waves.theta(ii,:) = theta(ii,:);
    waves.s(ii,:) = s(ii,:);
    waves.m2(ii,:) = m2(ii,:); 
    waves.n2(ii,:) = n2(ii,:);
    waves.timewave(ii,:) = time(ii,:);
    
    % First calculate a1, b1
    waves.a1(ii,:) = (1 - (waves.s(ii,:).^2)/2).*cos(waves.theta(ii,:));   
    waves.b1(ii,:) = (1 - (waves.s(ii,:).^2)/2).*sin(waves.theta(ii,:));        
    
    % Now calculate a2, b2                
    waves.theta2(ii,:) = 2.*waves.theta(ii,:);    
    waves.theta2(ii,:) = 2.*waves.theta(ii,:);
    
    waves.a2(ii,:) = waves.m2(ii,:).*cos(waves.theta2(ii,:)) - waves.n2(ii,:).*sin(waves.theta2(ii,:));
    waves.b2(ii,:) = waves.m2(ii,:).*sin(waves.theta2(ii,:)) + waves.n2(ii,:).*cos(waves.theta2(ii,:));                       
    
    % Computer frequency for direction wave rider (DWR) 4 - pg 25 in Datawell manual    
    %f(k) = 0.025+0.005*k for 0<k<46   (0.025 to 0.25 Hz)
    %f(k) = -0.20+0.010*k for 46<k<79  (0.26 to 0.58 Hz)
    %f(k) = -0.98+0.020*k for 79<k<100 (0.6 to 1.00 Hz)
    
    for k = 0:99
        if k>=0&&k<=46
            waves.freq(k+1,1) = 0.025+0.005*k;
        elseif k>46&&k<=79
            waves.freq(k+1,1) = -0.20+0.010*k;
        elseif k>79
            
            waves.freq(k+1,1) = -0.98+0.020*k;
        end
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Now calculate spectra using Lygre and Krogstad (code from T Jonsson)                        
    % addpath('.\Janssen_MEM');            
    %1 degree resolution output (for plotting on website)        
    [NS, NE, ndirec] = lygre_krogstad_MC(waves.a1(ii,:),waves.a2(ii,:),waves.b1(ii,:),waves.b2(ii,:),waves.E(ii,:),1);
    
    [waves.ndirec,I] = sort(ndirec);
    NS = NS(:,I);
    NE = NE(:,I);     
    
    
    % plot MEM results
    waves.hs(ii,1) = spec_params(ii,1);
    waves.tp(ii,1) = spec_params(ii,2);
    waves.dp(ii,1) = rad2deg(spec_params(ii,3));
   
    make_MEM_plot(waves.ndirec, waves.freq, NE, waves.hs(ii,1), waves.tp(ii,1), waves.dp(ii,1), waves.timewave(ii,1), buoyname, pathMEMplot);
    
    %write 1D and 2D spectra to text
    [waves.spec1D(ii,:)] = export_spec1d_spec2d(path1D, path2D, waves.freq, waves.ndirec, NE, waves.timewave(ii,1), buoyname);
    
end                
end
