function [out]=spectra_partitioning(out,info)
%
%Take output structure from spectra_from_displacements function and
%calcualte partitioned Sea and Swell and IG bulk parameters
%requires info structure as input as 
%  info.fminIG = 1/300; 
%  info.fminSS = 1/25; Swell min
%  info.fmaxSS = 1/8; %Sea/swell cuoff
%  info.fmaxSea = 1/2;     
% if no calcualtion of IG is desired do not include info.fminIG as a field
% in the input structure. You can also omit fminSS (swell min) and fmaxSea
% (sea max frequency). If only info.fmaxSS is provided the code will use a
% single cutoff to define sea/swell
%
%the out structure provided as an input must include:
%out.S  the 1D spectrum
%out.f the out.fuencies
%out.a1 S(
%out.a2 
%out.b1 
%out.b2 
%
%output from this code is simply added to the out structure as additional
%variables.
%
%****NOTE: attention should be paid to alignment between the input
%out.frequency vector and cut off frequencies (e.g. between sea and swell
%bands) in some cases it may be best to interpolate the spectrum to higher
%resolution frequency bins to ensure the cut off frequencies do not fall in the
%middle of bins. See code below to see usage of > vs >= and < vs <=
%
%v1.0 JEH April 2024




%% Start with Sea 
if isfield(info,'fmaxSea')
    indSea = out.f>=info.fmaxSS & out.f<info.fmaxSea; %if max out.fuency set for seas
else
    indSea = out.f>=info.fmaxSS; %otherwise everything greater *or equal* sea/swell cut off
end

%save cutoffs based on actual frequency bins
out.sea_max_min_T=1./[min(out.f(indSea)) max(out.f(indSea))];

mdir1_Sea= rad2deg(atan2(nansum(out.spec1D(indSea).*out.b1(indSea)),nansum(out.spec1D(indSea).*out.a1(indSea))));  
mdir2_Sea = rad2deg(atan2(nansum(out.spec1D(indSea).*out.b2(indSea)),nansum(out.spec1D(indSea).*out.a2(indSea)))/2);      
%rotate in WAVES FROM
mdir1_Sea = mod(270-mdir1_Sea,360); 
mdir2_Sea = mod(270-mdir2_Sea,360); 
spreadSea = rad2deg(sqrt(2*(1-sqrt(trapz(out.f(indSea),out.a1(indSea)).^2+trapz(out.f(indSea),out.b1(indSea)).^2)))); 

%calcualte moments of spectrum - sea         
n=0:3;
for jj=1:4
    %calculate moments
    %          /
    %    Mi =  | f**i * E(f) df
    %          /
    mSea(jj)=trapz(out.f(indSea),out.f(indSea).^n(jj).*out.spec1D(indSea));
    if n(jj)==0
        out.Hm0_Sea=4*sqrt(mSea(jj)); %sig wave height
    end        
end

%save output
out.mdir1_Sea = mdir1_Sea; 
out.mdir2_Sea = mdir2_Sea; 
out.Tm1_Sea=mSea(1)/mSea(2); %m0/m1
out.Tm2_Sea=sqrt(mSea(1)/mSea(3)); %m0/m2
out.spreadSea = spreadSea; 

%% Swell

if isfield(info,'fmaxSS') & isfield(info,'fminSS')
    indSS = out.f>=info.fminSS & out.f<info.fmaxSS; 
elseif isfield(info,'fmaxSS')
    indSS = out.f<info.fmaxSS;
end

%save cutoffs based on actual frequency bins
out.swell_max_min_T=1./[min(out.f(indSS)) max(out.f(indSS))];

mdir1_SS= rad2deg(atan2(nansum(out.spec1D(indSS).*out.b1(indSS)),nansum(out.spec1D(indSS).*out.a1(indSS))));  
mdir2_SS = rad2deg(atan2(nansum(out.spec1D(indSS).*out.b2(indSS)),nansum(out.spec1D(indSS).*out.a2(indSS)))/2);      
%rotate in WAVES FROM
mdir1_SS = mod(270-mdir1_SS,360); 
mdir2_SS = mod(270-mdir2_SS,360); 
spreadSS = rad2deg(sqrt(2*(1-sqrt(trapz(out.f(indSS),out.a1(indSS)).^2+trapz(out.f(indSS),out.b1(indSS)).^2)))); 

%calcualte moments of spectrum - swell         
n=0:3;
for jj=1:4
    %calculate moments
    %          /
    %    Mi =  | f**i * E(f) df
    %          /
    mSS(jj)=trapz(out.f(indSS),out.f(indSS).^n(jj).*out.spec1D(indSS));
    if n(jj)==0
        out.Hm0_Swell=4*sqrt(mSS(jj)); %sig wave height
    end        
end

out.mdir1_Swell=mdir1_SS;
out.mdir2_Swell=mdir2_SS;
out.Tm1_Swell=mSS(1)/mSS(2); %m0/m1
out.Tm2_Swell=sqrt(mSS(1)/mSS(3)); %m0/m2    
out.spreadSwell = spreadSS;





%% IG

%only run this part if field fminIG is in info structure
if isfield(info,'fminIG') 
    indIG =out.f>=info.fminIG & out.f<info.fminSS; 

    %save cutoffs based on actual frequency bins
    out.IG_max_min_T=1./[min(out.f(indIG)) max(out.f(indIG))];

    mdir1_IG= rad2deg(atan2(nansum(out.spec1D(indIG).*out.b1(indIG)),nansum(out.spec1D(indIG).*out.a1(indIG))));  
    mdir2_IG = rad2deg(atan2(nansum(out.spec1D(indIG).*out.b2(indIG)),nansum(out.spec1D(indIG).*out.a2(indIG)))/2);        
    
    %rotate in WAVES FROM
    mdir1_IG = mod(270-mdir1_IG,360); 
    mdir2_IG = mod(270-mdir2_IG,360);
    spreadIG = rad2deg(sqrt(2*(1-sqrt(trapz(out.f(indIG),out.a1(indIG)).^2+trapz(out.f(indIG),out.b1(indIG)).^2)))); 


    %calcualte moments of spectrum - IG          
    n=0:3;
    for jj=1:4
        %calculate moments
        %          /
        %    Mi =  | f**i * E(f) df
        %          /
        mIG(jj)=trapz(out.f(indIG),out.f(indIG).^n(jj).*out.spec1D(indIG));
        if n(jj)==0
            out.Hm0_IG=4*sqrt(mIG(jj)); %sig wave height
        end        
    end

    out.mdir1_IG=mdir1_IG;
    out.mdir2_IG=mdir2_IG;
    out.Tm1_IG=mIG(1)/mIG(2); %m0/m1
    out.Tm2_IG=sqrt(mIG(1)/mIG(3)); %m0/m2
    out.spreadIG = spreadIG; 

end




end




