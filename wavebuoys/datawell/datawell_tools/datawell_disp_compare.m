%datawell_disp_compare

%load('P:\HANSEN_Albany_WaveEnergy_Feasibility_ongoing\Data\WaveBuoys\Datawell\Data\UWA\CF\WaveBuoyNearshore\74089_DevSite_Oct2019_Download\buoy_data_2019_12_3-2021_2_13.mat')

data.disp_tstart=data.disp_time(:,1);
[I,ia,ib]=intersect(data.time,data.disp_tstart);
hs_internal=data.hs(ia);
spec_internal=data.E(ia,:);

g=9.81;
rho=1025;
nfft=512;
window=nfft/2;
fs=2.56;


for kk=1:length(I)
    [Sp,f]=pwelch(data.disp_h(ib(kk),1:4608),hann(window),[],nfft,'onesided',fs);
    %assum can't resolve less than 5 wavelengths
    fmax=fs/5;
    %also assume need 4 wavelegths in window
    fmin=fs*4/nfft;
    f_inds=find(f>=fmin & f<=fmax);
    Sp(f>fmax)=0;
    Sp(f<fmin)=0;
    %get rid of 0 f at beginning
    f(1)=f(2)/10;


    % Total ************************************************************
    SpTot=trapz(f,Sp);
    
    disp_hs(kk)=4*sqrt(SpTot);
    disp_S(kk,:)=Sp;
end
    

%% extract data to make structure smaller
datawell.disp_time=data.disp_time(:,1:4608)+(30/(24*60)); %add half hour 
datawell.heave=data.disp_h(:,1:4608);
datawell.north=data.disp_n(:,1:4608);
datawell.west=data.disp_w(:,1:4608);
datawell.fs=2.56;

