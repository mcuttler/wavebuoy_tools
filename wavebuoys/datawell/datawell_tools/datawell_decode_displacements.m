%% Decode Datawell hexadecimal 

%requires the Fx023 and the -displacement.csv from CF processed data
%f23 and dispfile need to be strings will complete path to files 
% 
%Example: 
% dpath = 'P:\HANSEN_Albany_WaveEnergy_Feasibility_ongoing\Data\WaveBuoys\Datawell\Data\UWA\CF\WaveBuoyNearshore\74089_DevSite_Oct2019_Download\CSV_Export'; 
% file23 = [dpath '\2018_07_13-23.csv']; 
% dispfile = [dpath '\2018_07_13-displacement.csv']; 

%% 
function [data] = datawell_decode_displacements(file23, dispfile)

%read in displacement file 
disp_data = importdata(dispfile);

%read in sync info file
sync_raw = readtable(file23); 
sync_data.tstamp = table2array(sync_raw(:,1));  
sync_data.datastamp = table2array(sync_raw(:,2));  
sync_data.segs = table2array(sync_raw(:,3));  
sync_data.samples = table2array(sync_raw(:,4));  
sync_data.hexstring = table2array(sync_raw(:,5)); 

%check things are correct sizes
[times, I, ~] = unique(sync_data.tstamp,'first'); 
check = sum(sync_data.samples(I)); 


if check == size(disp_data.data,1)
    data.disp_time = sync_data.tstamp(I); 
    data.disp_time_utc = (data.disp_time./(60*60*24))+datenum(1970,1,1);
    data.disp_samples_unique = sync_data.samples(I);                
          
    %check if all transmissions were 'g' - this could be done better as not
    %doing anything with this right now - this is a flag for the entire
    %transmission
    cnts = cumsum(data.disp_samples_unique);  
    flags = disp_data.textdata(cnts);

    %find displacemnt values with a good ('g') flag and assign a flag value of 1,
    %if not 'g' assign flag value of 0
    ff=strcmp(disp_data.textdata,'g');
    dis_flag=zeros(1,length(disp_data.data(:,1)));
    dis_flag(ff)=1;
    
    %decode hexstring 
    for i = 1:size(data.disp_time,1)
        [hn1,h] = datawell_hex_to_displacement(sync_data.hexstring{I(i)});
        %calc differences between hex data and disp data to find matching rows 
        for j = 1:3
            dhn1(:,j) = abs(disp_data.data(:,j)-hn1(1,j)); 
            dh(:,j) = abs(disp_data.data(:,j)-h(1,j)); 
        end
        
        %sum all differences for each displacemment
        dhn1_sum = sum(dhn1,2); 
        dh_sum = sum(dh,2); 
        
        %find min displacement for hn1 and h
        ind_hn1 = find(dhn1_sum==min(dhn1_sum)); 
        ind_h = find(dh_sum==min(dh_sum)); 
        
        if ind_h - ind_hn1 == 1
            %extract displacements                     
            dstart = ind_h - (data.disp_samples_unique(i)-1);
            data.disp_h(i,1:length(dstart:ind_h)) = disp_data.data(dstart:ind_h,1)'; 
            data.disp_n(i,1:length(dstart:ind_h)) = disp_data.data(dstart:ind_h,2)'; 
            data.disp_w(i,1:length(dstart:ind_h)) = disp_data.data(dstart:ind_h,3)'; 
            data.disp_flag(i,1:length(dstart:ind_h)) = dis_flag(dstart:ind_h); 

        else
            disp(['No matching data in displacements for t=' num2str(i)]); 
            dstart = ind_h - (data.disp_samples_unique(i)-1);
            data.disp_h(i,1:length(dstart:ind_h)) = ones(1,length(dstart:ind_h)).*nan; 
            data.disp_n(i,1:length(dstart:ind_h)) = ones(1,length(dstart:ind_h)).*nan; 
            data.disp_w(i,1:length(dstart:ind_h)) = ones(1,length(dstart:ind_h)).*nan;
            data.disp_flag(i,1:length(dstart:ind_h)) = zeros(1,length(dstart:ind_h));
        end               
    end                  
else
    data.disp_time = []; data.disp_time_utc = []; data.disp_samples_unique = []; data.disp_h = []; data.disp_n = []; data.disp_w = []; data.disp_flag = [];
end




