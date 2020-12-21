%% Wrapper Script to fetch spoondrift data, archive it, write SWAN input files

%SpotterID is string for name of individual SpotterBuoy, e.g. 'SPOT-0093', this is then
%used as the filename for saving data as text file. 

%Dirout is location to save text file for data and figures

%DirSWAN is location of files for running SWAN - indicates where to write
%INPUT file to. 

%Note, this does not save the data as a .mat file anywhere

%Example: Process_Spoondrift('SPOT-0093');

%M Cuttler (Nov 2018)

%% 
% function [] = Process_Spoondrift(SpotterID,dirout,dirSWAN)
clear all 
%% Define needed parameters first
SpotterID = 'SPOT-0559';
SpotterName = 'SPOT-0559_ExmouthGulf';
dirout = ['E:\SpoondriftBuoys\' SpotterName];

%Retrieve latest data from Spoondrift API
[SpotData] = Get_Spoondrift_Data_realtime_v2(SpotterID,2);

%% Calculate MEM
%Note, use lygre_krogstad from T Janssen. DO NOT USE lygre_krogstad_MC as
%this has a directional correction due to calculating for Datawell buoys

% [NS, NE, ndirec] = lygre_krogstad(SpotData.a1,SpotData.a2,SpotData.b1,SpotData.b2,SpotData.varianceDensity);
% 
% [ndirec,I] = sort(ndirec);
% NS = NS(:,I);
% NE = NE(:,I);

% Test 1D plot of NE == 1D plot of E
% figure;
% E = SpotData.varianceDensity;
% plot(E,trapz(ndirec,NE,2),'b.','Markersize',18);
% hold on
% grid on
% plot([min(E) max(E)],[min(E) max(E)],'k--');
% title('Check 2D Spec Calculation');
% 
%5 degree resolution for generating Swan input file
% [~,NEswan,ndirecSwan]=lygre_krogstad_MC(a1,a2,b1,b2,E,5);
% [ndirecSwan,Iswan] = sort(ndirecSwan);
% NEswan = NEswan(:,Iswan);

%% plot results
% ndirec2 = [ndirec 360];
% NE_plot = [NE NE(:,1)];
% NE_plot2 = NE_plot;
% 
% %Interp to finescale grid
% % fnew = [min(freq):0.001:max(freq)]';
% fnew=[5:0.2:25]'; 
% dnew = [min(ndirec):0.05:max(ndirec2)];
% [NE_new] = griddata(ndirec2,1./SpotData.frequency,NE_plot,dnew,fnew);
% NE_new2 = NE_new./max(max(NE_new));
% 
% 
% fid = figure;
% set(gcf,'Position',[100 75 680 575])
% [h,c] = polarPcolor_final(fnew',dnew,NE_new2,NE_new,'Ncircles',5,'Nspokes',13);
% %[h,c] = polarPcolorMC2(fnew',dnew,NE_new2,NE_new,'Ncircles',5,'Nspokes',13);
% cmap = jet(150);
% colormap(cmap);
% 
% %Display Hsig, Tp, Dp
% text(0.85,0.05,['Hs = ' num2str(round(SpotData.hsig,2)) 'm'],'units','normalized','fontweight','bold','fontsize',12);
% 
% dum = trapz(ndirec, NE,2);
% text(0.85,0.0,['Tp = ' num2str(round(SpotData.tp,1)) 's'],'units','normalized','fontweight','bold','fontsize',12);
% 
% dum = trapz(SpotData.frequency, NE,1);
% text(0.85,-0.05,['Dp = ' num2str(round(SpotData.dp,0)) 'deg'],'units','normalized','fontweight','bold','fontsize',12);
% 
% t = title([datestr(SpotData.time+datenum(0,0,0,8,0,0)) 'WST']);
% t.Position = [0 1.4 0];
% % set(fid,'color',[0.65 0.65 0.65]);
% set(fid,'color','w');
% % caxis([(thresh*max(max(NE_plot))) max(max(NE_plot))*0.8])
% cmap = colormap;
% cmap(1,1:3) = [0.9 0.9 0.9];
% colormap(cmap);
% 
% cmap2 = [cmap(1,1:3);ones(10,3);cmap(2:end,:)];
% cmap2(2:11,1) = linspace(cmap(1,1),cmap(2,1),10);
% cmap2(2:11,2) = linspace(cmap(1,2),cmap(2,2),10);
% cmap2(2:11,3) = linspace(cmap(1,3),cmap(2,3),10);
% colormap(fid,cmap2);

%% Export figures and text file
%pre-set paths

% path1D = [dirout '\Spec1D'];
% path2D = [dirout '\Spec2D'];
% path2D2 = 'P:\HANSEN_Albany_WaveEnergy_Feasibility_ongoing\Analysis\WaveBuoys\Data\UWA\Processed\Spec2D';
% pathMEMplot = [dirout '\MEMplot'];
pathMAT = [dirout '\MAT'];
% pathMAT2 = 'P:\HANSEN_Albany_WaveEnergy_Feasibility_ongoing\Analysis\WaveBuoys\Data\UWA\Processed\MAT';
pathweb = [dirout '\wawaves'];

%store everything by year and month
time = SpotData.time(2);
time2 = datevec(SpotData.time(2));
yr = num2str(time2(1));
mo = num2str(time2(2),'%02d');

%---------------------------------------------------------------------------
%save MEMplot figure
% if exist([pathMEMplot '\' yr])
%     if exist([pathMEMplot '\' yr '\' mo])
%         export_fig([pathMEMplot '\' yr '\' mo '\' SpotterName '_MEMplot_' datestr(time,'yyyymmdd_HHMM') 'UTC'],'-jpg','-r200','-painters')
%         
%     else
%         mkdir([pathMEMplot '\' yr '\' mo])
%         export_fig([pathMEMplot '\' yr '\' mo '\' SpotterName '_MEMplot_' datestr(time,'yyyymmdd_HHMM') 'UTC'],'-jpg','-r200','-painters')
%     end
% else
%     mkdir([pathMEMplot '\' yr '\' mo])
%     export_fig([pathMEMplot '\' yr '\' mo '\' SpotterName '_MEMplot_' datestr(time,'yyyymmdd_HHMM') 'UTC'],'-jpg','-r200','-painters')
% end
% 
% close(fid);


%----------------------------------------------------------------------------------------
%2D spectra textfile
% [M,N] = size(NE);
% txtout = ones(M+1,N+1).*nan;
% txtout(2:end,1) = SpotData.frequency;
% txtout(1,2:end) = ndirec;
% txtout(2:end,2:end) = NE;
% 
% if exist([path2D '\' yr])
%     if exist([path2D '\' yr '\' mo])
%        fid = fopen([path2D '\' yr '\' mo '\' SpotterName '_Spec2D_' datestr(time,'yyyymmdd_HHMM') 'UTC.csv'],'a');
%         
%     else
%         mkdir([path2D '\' yr '\' mo])
%         fid = fopen([path2D '\' yr '\' mo '\' SpotterName '_Spec2D_' datestr(time,'yyyymmdd_HHMM') 'UTC.csv'],'a');
%     end
% else
%     mkdir([path2D '\' yr '\' mo])
%     fid = fopen([path2D '\' yr '\' mo '\' SpotterName '_Spec2D_' datestr(time,'yyyymmdd_HHMM') 'UTC.csv'],'a');
% end
% 
% 
% fprintf(fid,'title: UWA Wave Buoys - 2D spectral output \n');
% fprintf(fid,'buoy_type: SOFAR Ocean Spotter \n');
% fprintf(fid,['Data_time:  ' datestr(time,'yyyymmdd_HHMM') 'UTC      \n']);
% fprintf(fid,['location:   ' num2str(SpotData.lat) ' ' num2str(SpotData.lon) '\n']);
% fprintf(fid,'depth:   350 m \n');
% fprintf(fid,'\n');
% fprintf(fid,'info: 2D spectra (m^2 Hz^{-1} deg^{-1}), calculated following Maximum Entropy Method (Lygre and Krogstad, 1986) \n');
% fprintf(fid,'row_data: First row is DIRECTION FROM (degrees) \n');
% fprintf(fid,'col_data: First column is frequency (Hz) \n');
% 
% fprintf(fid,' \n');
% 
% [rr,cc] = size(txtout);
% formatspec = '%25.10f \t ';
% 
% for i = 1:rr
%     dum = repmat(formatspec,1,cc);
%     if i == 1
%         dum(1:length(formatspec)) = '%3.0000000s';
%         fprintf(fid, [dum '\n'],txtout(i,:));            
%     else
%         fprintf(fid,[dum '\n'],txtout(i,:));
%     end
% end
% 
% fclose(fid);
% 
% %-------------------------------------------------------------------------------------------------------
% %1d Spectra
% 
% txtout2 = [SpotData.frequency SpotData.varianceDensity];
% 
% if exist([path1D '\' yr])
%     if exist([path1D '\' yr '\' mo])
%        fid = fopen([path1D '\' yr '\' mo '\' SpotterName '_Spec1D_' datestr(time,'yyyymmdd_HHMM') 'UTC.csv'],'a');
%         
%     else
%         mkdir([path1D '\' yr '\' mo])
%         fid = fopen([path1D '\' yr '\' mo '\' SpotterName '_Spec1D_' datestr(time,'yyyymmdd_HHMM') 'UTC.csv'],'a');
%     end
% else
%     mkdir([path1D '\' yr '\' mo])
%     fid = fopen([path1D '\' yr '\' mo '\' SpotterName '_Spec1D_' datestr(time,'yyyymmdd_HHMM') 'UTC.csv'],'a');
% end
% 
% fprintf(fid,'title: UWA Wave Buoys - 1D spectral output \n');
% fprintf(fid,'buoy_type: SOFAR Ocean Spotter \n');
% fprintf(fid,['data_time: ' datestr(time,'yyyymmdd_HHMM') 'UTC      \n']);
% fprintf(fid,['Location:   ' num2str(SpotData.lat) num2str(SpotData.lon) '\n']);
% fprintf(fid,'Depth:   350 m');
% fprintf(fid,'\n');
% fprintf(fid,'info: 1D spectra (m^2 Hz^{-1}) \n');
% fprintf(fid,'col1_data: First column is frequency Hz) \n');
% fprintf(fid,'col2_data: Second column is energy density (m^2 Hz^{-1}) \n');
% fprintf(fid,'\n');
% 
% [rr,cc] = size(txtout2);
% 
% for i = 1:rr  
%     for j = 1:cc
%         if j == cc
%             fprintf(fid,'%25.10f \n',txtout2(i,j));            
%         else
%             fprintf(fid,'%25.10f \t',txtout2(i,j));
%         end
%     end
% end
% 
% fclose(fid);

%-----------------------------------------------------------------------------------
%save mat file somewhere
if exist([pathMAT '\' yr])
    if exist([pathMAT '\' yr '\' mo])
        save([pathMAT '\' yr '\' mo '\' SpotterName '_' num2str(datestr(time,'yyyymmdd_HHMMSS')) '.mat'],'-v7.3','SpotData');
    else
        mkdir([pathMAT '\' yr '\' mo])
        save([pathMAT '\' yr '\' mo '\' SpotterName '_' num2str(datestr(time,'yyyymmdd_HHMMSS')) '.mat'],'-v7.3','SpotData');
    end
else
    mkdir([pathMAT '\' yr '\' mo])
    save([pathMAT '\' yr '\' mo '\' SpotterName '_' num2str(datestr(time,'yyyymmdd_HHMMSS')) '.mat'],'-v7.3','SpotData');
end

%% Save parametric data for easy access by website
% 
% if exist([pathweb '\' yr])
%     if exist([pathweb '\' yr '\' mo])
%        fid = fopen([pathweb '\' yr '\' mo '\' SpotterName '_' datestr(time,'yyyymmdd_HHMM') 'UTC.csv'],'w');
%         
%     else
%         mkdir([pathweb '\' yr '\' mo])
%         fid = fopen([pathweb '\' yr '\' mo '\' SpotterName '_' datestr(time,'yyyymmdd_HHMM') 'UTC.csv'],'w');
%     end
% else
%     mkdir([pathweb '\' yr '\' mo])
%     fid = fopen([pathweb '\' yr '\' mo '\' SpotterName '_' datestr(time,'yyyymmdd_HHMM') 'UTC.csv'],'w');
% end
% 
% % fprintf(fid,['%' length(SpotterName) 's\t %' length(SpotterID) 's\t %19s\t %8s\t %8s\t %6s\t %6s\t %6s\t %6s\t %6s\t %6s\t %6s  \n'],...
% %     'SpotterName','SpotterID','Time','Lat','Lon','Hs','Tp','Tm','Dp','DpSpr','Dm','DmSpr');
% 
% dataout = [SpotData.time,...
%     SpotData.lat, SpotData.lon,...
%     SpotData.hsig, SpotData.tp,... 
%     SpotData.tm, SpotData.dp,... 
%     SpotData.dpspr, SpotData.dm,... 
%     SpotData.dmspr, SpotData.temp,...
%     SpotData.wind_speed, SpotData.wind_dir];
% 
% fprintf(fid, ['%' num2str(length(SpotterName)) 's \t'], SpotterName);
% fprintf(fid, ['%' num2str(length(SpotterID)) 's \t'], SpotterID);
% fprintf(fid,'%19s \t',datestr(time, 'yyyy-mm-dd HH:MM:SS'));
% 
% fprintf(fid,'%8.4f\t %8.4f\t %6.2f\t %6.2f\t %6.2f\t %6.2f\t %6.2f\t %6.2f\t %6.2f \n',dataout);
% 
% fclose(fid);










