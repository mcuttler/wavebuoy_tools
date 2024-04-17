function [out]=spectra_from_displacements(heave,north,east,nfft,nover,fs,merge,type,info)
%
%perform basic spectral processing of wave displacement data. Rather than
%rely on the built in pwelch or similar function this takes a more basic
%approach to allow the identification of spikes/outliers in ensembles so
%they can be excluded from the spectral analysis
%
%INPUTS: 
%          - heave, north, east, are displacements in the up (z), north (y) and east (x) direction. 
%          - nfft is the lenght of the blocks for each fft (e.g. 1024)
%          - nover is the fraction of overlap (e.g., 0.5 is 50%)
%          - fs is the sample frequency 
%          - merge is the number of adjacent frequency bins to merge (merge=1 is no averaging, and best to do an odd number).
%          - type is string and either 'enu' for velocity + pressure, or 'xyz' for displacements 
%          - info is structure containing: 
%                 - info.hab is height above bed and required for depth correction when using velocity + pressure 
%                 - info.fmax is maximum frequency cuttoff for SS wave statistics
%                 - info.fminSS is minimum frequency cutoff for SS wave stations (and max cutoff for IG wave stats)
%                 - info.fminIG is minimum frequency cutoff for IG wave statistics
%
%v1.0, JEH 6 Jan, 2022
%v1.1, JEH 2 Sept 2022 , modified to include peak period and direction
%v2.0 MC 24 Apr 2023, modified to account for pressure + velocity (enu) or displacement(xyz) inputs 
%v2.1 MC 5 April 2024, renamed and added to wave buoy tools 
%v3 MC 16 April 2024, add functionality to do partitioning 
%v3.1 17 April 2024 JEH remove patritioning - to be done in second function using output
%structure from this function 

%%

%FIRST SPLIT DATA INTO CHUNKS
pts = length(heave);        % record length in data points
windows =floor((1/nover)*(pts/nfft -1)+1);   % number of windows/segments  


%COMPUTE ZERO UP CROSSING WAVE HEIGHTS FOR OUTLIER DETECTION
[zup] = ZeroUpX3(heave, 1/fs); %NOTE- use complete record- originally was doing segment by segment but think this is better
Hs0=zup.Hs;
heights=zup.Heights;
periods=zup.Periods;
T0=zup.Tz;

%MAKE MATRIX CONTAINING DATA SEGMENTS- EACH SEGMENT IS NFFT LONG
for q=1:windows 
	hv_segs(:,q) = heave((q-1)*(nover*nfft)+1  :  (q-1)*(nover*nfft)+nfft);  
    nt_segs(:,q) = north((q-1)*(nover*nfft)+1  :  (q-1)*(nover*nfft)+nfft); 
    et_segs(:,q) = east((q-1)*(nover*nfft)+1  :  (q-1)*(nover*nfft)+nfft); 
%     %ZERO CROSSING ANALYSIS- used also to identify segments with bad
%     %displacement data
    [zup] = ZeroUpX3(hv_segs(:,q), 1/fs); 
    Hs_seg(q)=zup.Hs;
    heights_seg{q}=zup.Heights;
    periods_seg{q}=zup.Periods;
    T0_seg(q)=zup.Tz;
end

%FIND SEGMENTS WITH NaNs AND BAD DATA
cnt=1;
rw=[];
for jj=1:windows
    ff=find(isnan([hv_segs(:,jj) ; nt_segs(:,jj) ; et_segs(:,jj)])); %combine heave, east, north into one and just look for any nans
    %look for unrealistic values- compare individual segment values but
    %those from the overall record- 
    if ~isempty(ff) | max(heights_seg{jj})>3*Hs0  | max(periods_seg{jj})> 4*T0 | max(periods_seg{jj})> 30 %******* cut off values for unrealitic values- from Table3 in Adi's JTEC paper, but cahnge to 4*T0 and add > 30s
        if max(heights)>3*Hs0
            jj;
        elseif max(periods)> 4*T0
            jj;
        end            
        rw(cnt)=jj;
        cnt=cnt+1;
    end
end


%IF MORE THAN 2/3 OF SEGMENTS DON'T HAVE BAD DATA CONTINUE
if isempty(rw) | (length(rw)<windows*0.33 & length(find(heave==0))/length(heave)<0.1)
    
    if ~isempty(rw)
        hv_segs(:,rw) = [];  
        nt_segs(:,rw) = []; 
        et_segs(:,rw) = []; 
    end

    %make window
    win=hann(nfft);
    %apply window
    hv_win=repmat(win,1,size(hv_segs,2)).*hv_segs;
    nt_win=repmat(win,1,size(hv_segs,2)).*nt_segs;
    et_win=repmat(win,1,size(hv_segs,2)).*et_segs;

    %need to correct so is variance perserving, first find ratio of variance as
    %correction factor
    facth = sqrt( var(hv_segs) ./ var(hv_win) );
    factn = sqrt( var(nt_segs) ./ var(nt_win) );
    facte = sqrt( var(et_segs) ./ var(et_win) );

    %apply correction factor
    hv_corr = (ones(nfft,1)*facth).* hv_win;
    nt_corr = (ones(nfft,1)*factn).* nt_win;
    et_corr = (ones(nfft,1)*facte).* et_win;

    %compute 2 sided fft
    hfft=fft(hv_corr);
    nnfft=fft(nt_corr);
    efft=fft(et_corr);

    %delete second half of spectrum 
    hfft((nfft/2+1):nfft,:)=[]; 
    nnfft((nfft/2+1):nfft,:)=[]; 
    efft((nfft/2+1):nfft,:)=[]; 

    % throw out the mean (first coef) and add a zero (to make it the right
    % length)- make last 0 very small number to avoid NaNs in calculation
    % of a's and b's
    hfft(1,:)=[]; 
    nnfft(1,:)=[]; 
    efft(1,:)=[];
    
    hfft(nfft/2,:)=1e-10; 
    nnfft(nfft/2,:)=1e-10; 
    efft(nfft/2,:)=1e-10;


    % POWER SPECTRA (auto-spectra)
    hh_spec = ( hfft.* conj(hfft) );
    nn_spec = ( nnfft.* conj(nnfft) );
    ee_spec = ( efft.* conj(efft) );

    %CROSS-SPECTRA
    he_spec = ( hfft.* conj(efft) );
    hn_spec = ( hfft.* conj(nnfft) );
    en_spec = ( efft.* conj(nnfft) );    
    
    %merge frequency bands, set to merge=1 for no merging
    if merge>1
        for i = merge:merge:(nfft/2) 
            %auto specta
            hh_spec_merged(i/merge,:) = mean( hh_spec((i-merge+1):i , : ) );
            nn_spec_merged(i/merge,:) = mean( nn_spec((i-merge+1):i , : ) );
            ee_spec_merged(i/merge,:) = mean( ee_spec((i-merge+1):i , : ) );

            %cross spectra
            he_spec_merged(i/merge,:) = mean( he_spec((i-merge+1):i , : ) );
            hn_spec_merged(i/merge,:) = mean( hn_spec((i-merge+1):i , : ) );
            en_spec_merged(i/merge,:) = mean( en_spec((i-merge+1):i , : ) );
        end

    else
        hh_spec_merged=hh_spec;
        nn_spec_merged=nn_spec;
        ee_spec_merged=ee_spec;

        he_spec_merged=he_spec;
        hn_spec_merged=hn_spec;
        en_spec_merged=en_spec;
    end

    % freq range and bandwidth
    n = (nfft/2) / merge;                         % number of f bands
    Nyquist = .5 * fs;                % highest spectral frequency 
    bandwidth = Nyquist/n ;                    % freq (Hz) bandwitdh
    % find middle of each freq band, ONLY WORKS WHEN MERGING ODD NUMBER OF BANDS!
    freq= 1/(nfft) + bandwidth/2 + bandwidth.*[0:(n-1)] ; 


    %ENSEMBLE AVERAGE
    S = 2*mean( hh_spec_merged.' ) / (nfft * fs ); 
    UU = 2*mean( ee_spec_merged.' ) / (nfft * fs ); 
    VV = 2*mean( nn_spec_merged.' ) / (nfft * fs ); 

    HU = 2*mean( he_spec_merged.' ) / (nfft * fs ); 
    HV = 2*mean( hn_spec_merged.' ) / (nfft * fs ); 
    UV = 2*mean( en_spec_merged.' ) / (nfft * fs ); 

    %CALCULATE CO-SPECTRA
    coHU = real(HU);   
    coHV = real(HV);   
    coUV = real(UV);  
    
    %CALCULATE QUAD-SPECTRA
    qHU = imag(HU); 
    qHV = imag(HV); 
    qUV = imag(UV); 

    %  WAVE DIRECTION & SPREAD ### if using velocity rather than
    %  displacement need to use co-spectrum, see Thomson et al., 2018 JTEC

    %spectral moments - a1, a2, b1, b2 
    if strcmp(type,'xyz') %xyz = displacements
        a1 = qHU ./ sqrt( S .* ( UU + VV ) );
        b1 = qHV ./ sqrt( S .* ( UU + VV ) );
    elseif strcmp(type,'enu') %enu = velocity
        a1 = coHU ./ sqrt( S .* ( UU + VV ) );
        b1 = coHV ./ sqrt( S .* ( UU + VV ) );
    end
    
    a2 = (UU - VV) ./ (UU + VV);
    b2 = (2 .* coUV) ./ ( UU + VV );    

    %primary directional spectrum --- direction at each frequency  
    dir1 = rad2deg ( atan2(b1,a1) );          
    spread1 = ( sqrt( 2 .* ( 1-sqrt(a1.^2 + b1.^2) ) ) );
    
    %secondary  directional spectrum --- direction at each frequency  
    dir2 = rad2deg (atan2(b2,a2)/2 );       
    spread2 = sqrt(abs( 0.5 - 0.5 .* ( a2.*cos(2.*deg2rad(dir2)) + b2.*sin(2.*deg2rad(dir2)) )  ));

    %mean directions - total, SS, IG
    mdir1_tot = rad2deg(atan2(nansum(S.*b1),nansum(S.*a1))); 
    mdir2_tot = rad2deg(atan2(nansum(S.*b2),nansum(S.*a2))/2);    
    
    %rotate in WAVES FROM
    mdir1_tot = mod(270-mdir1_tot,360); 
    mdir2_tot = mod(270-mdir2_tot,360);

    %peak period and direction
    ff=find(S==max(S));
    Tp=1./freq(ff);            
    Dp = rad2deg(atan2(b1(ff),a1(ff)));  
    Dp = mod(270 - Dp,360); 
    spread_Dp = rad2deg(sqrt(2*(1-sqrt(a1(ff).^2+ b1(ff).^2)))); 
     
    %spreading values
    spread=rad2deg(sqrt(2*(1-sqrt(trapz(freq,a1).^2+trapz(freq,b1).^2)))); %mean, I think 
   

   %CALCUALTE WAVE PARAMETERS AND ORGANIZE OUTPUT
    if strcmp(type,'xyz') %xyz = displacements
        %calcualte moments of spectrum - total 
        n=0:3;
        for jj=1:4
            %calculate moments
            %          /
            %    Mi =  | f**i * E(f) df
            %          /
            m(jj)=trapz(freq,freq.^n(jj).*S);
            if n(jj)==0
                out.Hm0=4*sqrt(m(jj)); %sig wave height
            end        
        end
        
        SpTot=trapz(freq,S);
        out.Hrms=sqrt(8*SpTot);
        out.f=freq;
        out.spec1D=S;
        out.a1=a1;
        out.a2=a2;
        out.b1=b1;
        out.b2=b2;
        out.mdir1 = mdir1_tot; 
    	out.mdir2 = mdir2_tot;
        out.mdir1_spec = mod(270-dir1,360);         
        out.Tp=Tp;
        out.Tm1=m(1)/m(2); %m0/m1
        out.Tm2=sqrt(m(1)/m(3)); %m0/m2
        out.Dp = Dp; 
        out.spread_Dp = spread_Dp; 
        out.spread=spread;
        out.spread_spec=spread1;
        out.segments=windows;
        out.segments_used=windows-length(rw);

    elseif strcmp(type,'enu') %enu = velocity
        %apply depth correction
        depth = info.hab+mean(heave); 
        wnum = disperk(freq,depth);         
        % transformation to surface elevation variance spectrum
        Scorr     = S.*(cosh(wnum.*depth)./cosh(wnum.*info.hab)).^2;
        
        %calcualte moments of spectrum
        n=0:3;
        for jj=1:4
            %calculate moments
            %          /
            %    Mi =  | f**i * E(f) df
            %          /
            m(jj)=trapz(freq,freq.^n(jj).*Scorr);
            if n(jj)==0
                out.Hm0=4*sqrt(m(jj)); %sig wave height
            end        
        end

        SpTot=trapz(freq,Scorr); 
        out.f=freq;
        out.spec1D=Scorr;
        out.a1=a1;
        out.a2=a2;
        out.b1=b1;
        out.b2=b2;
        out.mdir1_spec = mod(270-dir1,360);   
        out.mdir1 = mdir1_tot; 
        out.mdir2 = mdir2_tot; 
        out.Tp=Tp;
        out.Tm1=m(1)/m(2); %m0/m1
        out.Tm2=sqrt(m(1)/m(3)); %m0/m2
        out.Dp=Dp;       
        out.spread=spread;
        out.spread_spec=spread1;
        out.segments=windows;
        out.segments_used=windows-length(rw);

    end
     
else %too much missing/bad data do not compute spectrum
    
    out=NaN;
    
end

end




