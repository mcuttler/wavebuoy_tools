%% Test datawell hexadecimal decode 

%% read in Fx023 CSV and displacements 
clear ans disp_file dum h hexstring i idx0 idxh0 idxh1 j n w dxyz dd check dstart dend displacements raw
csv_path = 'P:\HANSEN_Albany_WaveEnergy_Feasibility_ongoing\Data\WaveBuoys\Datawell\Data\UWA\CF\WaveBuoyNearshore\74089_DevSite_Oct2019_Download\CSV_Export'; 
% csvfile = '2019_06_29-23.csv';
dispfile = '2019_09_05-displacement.csv'; 
% raw = importdata(fullfile(csv_path, csvfile)); 
displacements = importdata(fullfile(csv_path,dispfile)); 

%% 
hexstring = 'eb82e6e1cdd22b7de3'; 
[hn1,h] = datawell_hex_to_displacement(hexstring); 

%calc differences between hex data and disp data to find matching rows 
for i = 1:3
    dhn1(:,i) = abs(displacements.data(:,i)-hn1(1,i)); 
    dh(:,i) = abs(displacements.data(:,i)-h(1,i)); 
end

%sum all differences for each displacemment
dhn1_sum = sum(dhn1,2); 
dh_sum = sum(dh,2); 

%find min displacement for hn1 and h
ind_hn1 = find(dhn1_sum==min(dhn1_sum)); 
ind_h = find(dh_sum==min(dh_sum)); 

%quick check to make sure they are 1 row apart
if ind_h - ind_hn1 == 1
    %extract displacements         
    ddum = (idxh0+1)-4607; 
    dxyz = displacements.data(ddum:idxh0+1,:); 

else
    disp('No matching data in displacements')

end


