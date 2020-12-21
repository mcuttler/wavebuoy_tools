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

clear all 
%% Define needed parameters first
SpotterID = 'SPOT-0093';
SpotterName = 'SPOT-0093_Hilarys';
dirout = ['E:\SpoondriftBuoys\' SpotterName];


%Retrieve latest data from Spoondrift API
[SpotData] = Get_Spoondrift_Data_realtime(SpotterID,2);

%% Export figures and text file
%pre-set paths

path1D = [dirout '\Spec1D'];
path2D = [dirout '\Spec2D'];
pathMEMplot = [dirout '\MEMplot'];
pathMAT = [dirout '\MAT'];
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

%-------------------------------------------------------------------------------------------------------
%1d Spectra

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
% dataout = [SpotData.lat SpotData.lon, SpotData.hsig, SpotData.tp, SpotData.tm, SpotData.dp, SpotData.dpspr, SpotData.dm, SpotData.dmspr];
% 
% fprintf(fid, ['%' num2str(length(SpotterName)) 's \t'], SpotterName);
% fprintf(fid, ['%' num2str(length(SpotterID)) 's \t'], SpotterID);
% fprintf(fid,'%19s \t',datestr(time, 'yyyy-mm-dd HH:MM:SS'));
% 
% fprintf(fid,'%8.4f\t %8.4f\t %6.2f\t %6.2f\t %6.2f\t %6.2f\t %6.2f\t %6.2f\t %6.2f \n',dataout);
% 
% fclose(fid);










