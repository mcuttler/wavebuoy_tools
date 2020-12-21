%% Save Spoondrift Spotter data to text file

function [] = Save_Spoondrift_Data(Spotter,dirout,filename)

%Check if file already exists and if data is newest
if exist([dirout '\' filename])==0
    
    fid = fopen([dirout '\' filename],'w');
    fprintf(fid,'%19s\t %8s\t %8s\t %6s\t %6s\t %6s\t %6s\t %6s\t %6s\t %6s  \n','Time','Lat','Lon','Hs','Tp','Tm','Dp','DpSpr','Dm','DmSpr');
    dataout = [Spotter.lat Spotter.lon, Spotter.hsig, Spotter.tp, Spotter.tm, Spotter.dp, Spotter.dpspr, Spotter.dm, Spotter.dmspr];
    fprintf(fid,'%19s \t',datestr(Spotter.time, 'yyyy-mm-dd HH:MM:SS'));
    fprintf(fid,'%8.4f\t %8.4f\t %6.2f\t %6.2f\t %6.2f\t %6.2f\t %6.2f\t %6.2f\t %6.2f \n',dataout);
    fclose(fid);
else
    data = importdata([dirout '\' filename]);
    dataout = [Spotter.lat Spotter.lon, Spotter.hsig, Spotter.tp, Spotter.tm, Spotter.dp, Spotter.dpspr, Spotter.dm, Spotter.dmspr];
    
    %check that retrieved data is newest
    if datenum(data.textdata{end,1})~=Spotter.time
        fid = fopen([dirout '\' filename],'a+');
        fprintf(fid,'%19s \t',datestr(Spotter.time, 'yyyy-mm-dd HH:MM:SS'));
        fprintf(fid,'%8.4f\t %8.4f\t %6.2f\t %6.2f\t %6.2f\t %6.2f\t %6.2f\t %6.2f\t %6.2f \n',dataout);
        fclose(fid);
    end
end


end



