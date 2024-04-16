function out=spec_params_sea_swell(dirs,freq,spec2D,f_cut)
%function to caluclate spectral quantities given a 2D spectrum
%Jeff Hansen, v1.0 3 June 2020, 
% Based on Rogers and Wang, 2006, Journal of Atmospheric and Oceanic Tech
% and the WaveWatch 3 Manual (Tolman, 2009)
%Inputs are dirs=direction bins (in degrees), freqs=frequency bins in Hz
%spec2D= 2D spectra, rows=directional, columns=freq
%f_cut is the cutoff frequency between sea/swell, swell<=f_cut, sea>f_cut
%
%
%NOTE: expects 2D spectra in m^2/Hz/deg and directions in degrees
%output is structure containing sig wave height (Hs), mean direction (Dm),
%peak direction (Dp), peak period (Tp), mean periods (Tm1 and Tm2), and the
%directional spreading

if size(dirs,2)>1 %transpose if direction vector is on row
    dirs=dirs';
end

fsw=find(freq<=f_cut);
f_swell=freq(fsw);
fsa=find(freq>f_cut);
f_sea=freq(fsa);

%calcualte moments
n=0:3;

%% complete spectrum
%first integrate over direction
out.E=trapz(dirs,spec2D);
if size(out.E,2)~=size(freq,2) %transpose if required so frequency and E are same
    freq=freq';
end

for jj=1:4
    %calculate moments
%          /
%    Mi =  | f**i * E(f) df
%          /
    m(jj)=trapz(freq,freq.^n(jj).*out.E);
    if n(jj)==0
        out.Hs=4*sqrt(m(jj)); %sig wave height
    end
    
end

%find Tp, just by finding frequency bin of max E
ff=find(out.E==max(out.E));
out.Tp=1./freq(ff);
out.Tm1=m(1)/m(2); %m0/m1
out.Tm2=sqrt(m(1)/m(3)); %m0/m2

rad=(pi/180)*dirs; %convert directions to radians

A=trapz(freq,trapz(dirs,repmat(cos(rad),1,length(freq)).*spec2D)); % equation 2.115 Tolman 2009 WW3 manual
B=trapz(freq,trapz(dirs,repmat(sin(rad),1,length(freq)).*spec2D));

tmp1=atan2d(B,A); %mean direction degrees nautical convention
if tmp1<0 %if negative
    out.Dm=360+tmp1;
else
    out.Dm=tmp1;
end

out.spread=(180/pi)*sqrt(2*(1-sqrt((A^2+B^2)/m(1)^2))); %directional spreading in degrees, eq 2.117 Tolman 2009

%calculate df, really only need this to calculate Dp below
for ii=1:length(freq)
    if ii==1
        df(ii)=(freq(ii+1)-freq(ii))/2; %half bin width for first and last bin
    elseif ii==length(freq)
        df(ii)=(freq(ii)-freq(ii-1))/2; %half bin width for first and last bin
    else
        df(ii)=(freq(ii+1)-freq(ii-1))/2; %half bin width for first and last bin
    end
end

%calculate Dp- basically calcute the mean direction as above but only in
%the frequency bin that contains the peak energy
AA=df.*trapz(dirs,repmat(cos(rad),1,length(freq)).*spec2D); % equation 2.115 Tolman 2009 WW3 manual
BB=df.*trapz(dirs,repmat(sin(rad),1,length(freq)).*spec2D);

tmp=atan2d(BB(ff),AA(ff)); %fix negative
if tmp<0
    out.Dp=360+tmp;
else
    out.Dp=tmp;
end
clear df

%% swell
%first integrate over direction
out.E_sw=trapz(dirs,spec2D(:,(freq<=f_cut)));

if size(out.E_sw,2)~=size(f_swell,2) %transpose if required so frequency and E are same
    f_swell=f_swell';
end

for jj=1:4
    %calculate moments
%          /
%    Mi =  | f**i * E(f) df
%          /
    m_sw(jj)=trapz(f_swell,f_swell.^n(jj).*out.E_sw);
    if n(jj)==0
        out.Hs_sw=4*sqrt(m_sw(jj)); %sig wave height
    end
    
end

%find Tp, just by finding frequency bin of max E
ff=find(out.E_sw==max(out.E_sw));

out.Tp_sw=1./f_swell(ff);
out.Tm1_sw=m_sw(1)/m_sw(2); %m0/m1
out.Tm2_sw=sqrt(m_sw(1)/m_sw(3)); %m0/m2

rad=(pi/180)*dirs; %convert directions to radians

A=trapz(f_swell,trapz(dirs,repmat(cos(rad),1,length(f_swell)).*spec2D(:,(freq<=f_cut)))); % equation 2.115 Tolman 2009 WW3 manual
B=trapz(f_swell,trapz(dirs,repmat(sin(rad),1,length(f_swell)).*spec2D(:,(freq<=f_cut))));

tmp1=atan2d(B,A); %mean direction degrees nautical convention
if tmp1<0 %if negative
    out.Dm_sw=360+tmp1;
else
    out.Dm_sw=tmp1;
end

out.spread_sw=(180/pi)*sqrt(2*(1-sqrt((A^2+B^2)/m_sw(1)^2))); %directional spreading in degrees, eq 2.117 Tolman 2009

%calculate df, really only need this to calculate Dp below
for ii=1:length(f_swell)
    if ii==1
        df(ii)=(f_swell(ii+1)-f_swell(ii))/2; %half bin width for first and last bin
    elseif ii==length(f_swell)
        df(ii)=(f_swell(ii)-f_swell(ii-1))/2; %half bin width for first and last bin
    else
        df(ii)=(f_swell(ii+1)-f_swell(ii-1))/2; %half bin width for first and last bin
    end
end

%calculate Dp- basically calcute the mean direction as above but only in
%the frequency bin that contains the peak energy
AA=df.*trapz(dirs,repmat(cos(rad),1,length(f_swell)).*spec2D(:,(freq<=f_cut))); % equation 2.115 Tolman 2009 WW3 manual
BB=df.*trapz(dirs,repmat(sin(rad),1,length(f_swell)).*spec2D(:,(freq<=f_cut)));

tmp=atan2d(BB(ff),AA(ff)); %fix negative
if tmp<0
    out.Dp_sw=360+tmp;
else
    out.Dp_sw=tmp;
end

clear df

%% sea
%first integrate over direction
out.E_sea=trapz(dirs,spec2D(:,(freq>f_cut)));

if size(out.E_sea,2)~=size(f_sea,2) %transpose if required so frequency and E are same
    f_sea=f_sea';
end

for jj=1:4
    %calculate moments
%          /
%    Mi =  | f**i * E(f) df
%          /
    m_sea(jj)=trapz(f_sea,f_sea.^n(jj).*out.E_sea);
    if n(jj)==0
        out.Hs_sea=4*sqrt(m_sea(jj)); %sig wave height
    end
    
end

%find Tp, just by finding frequency bin of max E
ff=find(out.E_sea==max(out.E_sea));

out.Tp_sea=1./f_sea(ff);
out.Tm1_sea=m_sea(1)/m_sea(2); %m0/m1
out.Tm2_sea=sqrt(m_sea(1)/m_sea(3)); %m0/m2

rad=(pi/180)*dirs; %convert directions to radians

A=trapz(f_sea,trapz(dirs,repmat(cos(rad),1,length(f_sea)).*spec2D(:,(freq>f_cut)))); % equation 2.115 Tolman 2009 WW3 manual
B=trapz(f_sea,trapz(dirs,repmat(sin(rad),1,length(f_sea)).*spec2D(:,(freq>f_cut))));

tmp1=atan2d(B,A); %mean direction degrees nautical convention
if tmp1<0 %if negative
    out.Dm_sea=360+tmp1;
else
    out.Dm_sea=tmp1;
end

out.spread_sea=(180/pi)*sqrt(2*(1-sqrt((A^2+B^2)/m_sea(1)^2))); %directional spreading in degrees, eq 2.117 Tolman 2009

%calculate df, really only need this to calculate Dp below
for ii=1:length(f_sea)
    if ii==1
        df(ii)=(f_sea(ii+1)-f_sea(ii))/2; %half bin width for first and last bin
    elseif ii==length(f_sea)
        df(ii)=(f_sea(ii)-f_sea(ii-1))/2; %half bin width for first and last bin
    else
        df(ii)=(f_sea(ii+1)-f_sea(ii-1))/2; %half bin width for first and last bin
    end
end

%calculate Dp- basically calcute the mean direction as above but only in
%the frequency bin that contains the peak energy
AA=df.*trapz(dirs,repmat(cos(rad),1,length(f_sea)).*spec2D(:,(freq>f_cut))); % equation 2.115 Tolman 2009 WW3 manual
BB=df.*trapz(dirs,repmat(sin(rad),1,length(f_sea)).*spec2D(:,(freq>f_cut)));

tmp=atan2d(BB(ff),AA(ff)); %fix negative
if tmp<0
    out.Dp_sea=360+tmp;
else
    out.Dp_sea=tmp;
end

clear df

