%% Export 1D and 2D spectra from Datawell to textfiles

function [NE1D] = export_spec1d_spec2d(path1D, path2D, freq, ndirec, NE, time, buoyname);

% store everything by year and month - save in folder corresponding to when data transmission (e.g. end of data acquisition) 
time2 = datevec(time+datenum(0,0,0,0,30,0));
yr = num2str(time2(1));
mo = num2str(time2(2),'%02d');

[M,N] = size(NE);
txtout = ones(M+1,N+1).*nan;
txtout(2:end,1) = freq;
txtout(1,2:end) = ndirec;
txtout(2:end,2:end) = NE;

if exist([path2D '\' yr])  
    if exist([path2D '\' yr '\' mo])
        fid = fopen([path2D '\' yr '\' mo '\' buoyname '_Spec2D_' datestr(time,'yyyymmdd_HHMM') 'UTC.csv'],'a');        
    else
        mkdir([path2D '\' yr '\' mo])
        fid = fopen([path2D '\' yr '\' mo '\' buoyname '_Spec2D_' datestr(time,'yyyymmdd_HHMM') 'UTC.csv'],'a');
    end
else
    mkdir([path2D '\' yr '\' mo])
    fid = fopen([path2D '\' yr '\' mo '\' buoyname '_Spec2D_' datestr(time,'yyyymmdd_HHMM') 'UTC.csv'],'a');
end

fprintf(fid,'title: UWA Wave Buoys - 2D spectral output \n');
fprintf(fid,'buoy_type: Datawell Directional Waverider buoy (DWR4) \n');
fprintf(fid,['Data_time:  ' datestr(time,'yyyymmdd_HHMM') 'UTC      \n']);
fprintf(fid,'location:   -35.07099 117.77497 \n');
fprintf(fid,'depth:   30 m \n');
fprintf(fid,'\n');
fprintf(fid,'info: 2D spectra (m^2 Hz^{-1} deg^{-1}), calculated following Maximum Entropy Method (Lygre and Krogstad, 1986) \n');
fprintf(fid,'row_data: First row is DIRECTION FROM (degrees) \n');
fprintf(fid,'col_data: First column is frequency (Hz) \n');

fprintf(fid,' \n');

[rr,cc] = size(txtout);
formatspec = '%25.10f \t ';

for i = 1:rr
    dum = repmat(formatspec,1,cc);
    if i == 1
        dum(1:length(formatspec)) = '%3.0000000s';
        fprintf(fid, [dum '\n'],txtout(i,:));            
    else
        fprintf(fid,[dum '\n'],txtout(i,:));
    end
end

fclose(fid);
clear fid;    

%-------------------------------------------------------------------------------------------------------
%1d Spectra
NE1D = trapz(ndirec,NE,2);
txtout2 = [freq NE1D];

if exist([path1D '\' yr])
    if exist([path1D '\' yr '\' mo])
        fid = fopen([path1D '\' yr '\' mo '\' buoyname '_Spec1D_' datestr(time,'yyyymmdd_HHMM') 'UTC.csv'],'a');
        
    else
        mkdir([path1D '\' yr '\' mo])
        fid = fopen([path1D '\' yr '\' mo '\' buoyname '_Spec1D_' datestr(time,'yyyymmdd_HHMM') 'UTC.csv'],'a');
    end
else
    mkdir([path1D '\' yr '\' mo])
    fid = fopen([path1D '\' yr '\' mo '\' buoyname '_Spec1D_' datestr(time,'yyyymmdd_HHMM') 'UTC.csv'],'a');
end

fprintf(fid,'title: UWA Wave Buoys - 1D spectral output \n');
fprintf(fid,'buoy_type: Datawell Directional Waverider buoy (DWR4) \n');
fprintf(fid,['data_time: ' datestr(time,'yyyymmdd_HHMM') 'UTC      \n']);
fprintf(fid,'Location:   -35.07099 117.77497 \n');
fprintf(fid,'Depth:   30 m');
fprintf(fid,'\n');
fprintf(fid,'info: 1D spectra (m^2 Hz^{-1}) \n');
fprintf(fid,'col1_data: First column is frequency Hz) \n');
fprintf(fid,'col2_data: Second column is energy density (m^2 Hz^{-1}) \n');
fprintf(fid,'\n');

[rr,cc] = size(txtout2);

for i = 1:rr  
    for j = 1:cc
        if j == cc
            fprintf(fid,'%25.10f \n',txtout2(i,j));            
        else
            fprintf(fid,'%25.10f \t',txtout2(i,j));
        end
    end
end

fclose(fid);
clear fid;
end
