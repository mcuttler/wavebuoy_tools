%run get spoondrift archive
buoy_info.serial = 'SPOT-0172';
buoy_info.sofar_token = 'e0eb70b6d9e0b5e00450929139ea34';

%build time vector
t1 = datenum(2020,01,20); 
tend = datenum(2020,06,01); 
dt = t1:7:tend; 

 
for i = 1:length(dt)-1
    [data] = Get_Spoondrift_archive(buoy_info, dt(i), dt(i+1)); 
    if i ==1
        SpotData = data; 
    else
        fields = fieldnames(data);
        for j = 1:length(fields); 
            SpotData.(fields{j}) = [SpotData.(fields{j}); data.(fields{j})]; 
        end
    end
end


        