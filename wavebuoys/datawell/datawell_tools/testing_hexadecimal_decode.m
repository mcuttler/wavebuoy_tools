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
[h,n,w] = datawell_hex_to_displacement(hexstring); 

%now find the two points in the displacements that match the heave
idxh0 = find(abs(displacements.data(:,1)-h(1))==min(abs(displacements.data(:,1) - h(1)))); 
idxh1 = find(abs(displacements.data(:,1)-h(2))==min(abs(displacements.data(:,1) - h(2)))); 


%%
if ~isempty(idxh0) & ~isempty(idxh1)
    for i = 1:size(idxh0,1)
        dum = sort(abs(idxh0(i) - idxh1)); 
        if dum(1)==1
            j = i;         
        end
    end
    
    %check that heave matches - not sure why N and W don't match
    if displacements.data(idxh0(j),1)==h(1) & displacements.data(idxh0(j)+1,1)==h(2)
        check = 1; 
    end
    
    %get displacements
    ddum = (idxh0+1)-4607; 
    dxyz = displacements.data(ddum:idxh0+1,:); 
else
    disp('No matching data in displacements')
end

