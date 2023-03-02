%% Decode MkIII RDT files

%According to Datawell MkIII reference manual, the RDT file name
%corresponds to maxmimum Hs in that day and exact date
%max Hs is 3 characters (A-Z) corresponding to 0-25. First character has
%power 676 cm, second character has power 26cm, third character has power
%1cm. Date is coded as  DDMMY and corresponds to last sample --- this means
%that last sample is top of the hour for a day. For example sample 1 will
%be Jan 1 00:00:0.7813 and last sample should be Jan 2 00:00:00

%Example from datawell: 06125AAC.RDT = 6 Dec 2015, max Hs = 2cm

%Each file should contain 48 x 30 min displacement sets (1 day), or may
%contain several days...

%% pull in Hs values and time stamp (time stamp corresponds to start of sample interval)
dum = dir('X:\LOWE_IMOS_Deakin_Collab_JUN2020\Data\Buoy_displacement_processing\Tantabiddi_buoy_data\Tantabiddi_19_20\processed_SDT'); 
dum = dum(3:end); 
sdt = struct('time',[],'hs',[]); 
for i = 1:size(dum); 
    %skip dodgy 1970 files and only using messages 324
    if ~strcmp(dum(i).name(5:8),'1970')&strcmp(dum(i).name(end-6:end-4),'324')
        tmp = importdata(fullfile(dum(i).folder, dum(i).name)); 
        %message time stamp is seconds since 1970-01-01 UTC 
        sdt.time = [sdt.time; (tmp.data(:,2)./86400)+datenum(1970,1,1)]; 
        sdt.hs = [sdt.hs; tmp.data(:,3)]; 
    end   
end
%sort
[sdt.time, I] = sort(sdt.time); 
sdt.hs = sdt.hs(I); 

%% process displacements 
%Get list of files in directory
addpath('C:\Data\wavebuoy_tools\wavebuoys\datawell\datawell_tools'); 
dum = dir('X:\LOWE_IMOS_Deakin_Collab_JUN2020\Data\Buoy_displacement_processing\Tantabiddi_buoy_data\Tantabiddi_19_20\processed_RDT'); 
dum = dum(3:end); 
% determine date of each file and number of days covered
yrs = [2019; 2020]; 
cnt = 1; 
displacements = struct('time',[],'heave',[], 'north',[],'west',[],'checksum',[]); 
for i = 1:size(dum,1); 
    disp(['Processing ' num2str(i) ' out of ' num2str(size(dum,1)) '...']); 
    %skip TMP files
    if ~strcmp(dum(i).name(1:3),'TMP')
        %determine year
        for j = 1:size(yrs,1)
            y = num2str(yrs(j)); 
            if dum(i).name(5)== y(end); 
                yr = yrs(j); 
            end
        end
        %calculate Hs max within record using 0-25
        hs_max = ((alphabet_to_number(dum(i).name(6),0)^6.76)) +... 
        ((alphabet_to_number(dum(i).name(7),0)^.26)) +... 
        ((alphabet_to_number(dum(i).name(8),0)^.01)); 

        %calculate date
        rdt.file_time(cnt,1) = datenum(yr, str2num(dum(i).name(3:4)), str2num(dum(i).name(1:2)));   
        %read in data
        tmp = importdata(fullfile(dum(i).folder, dum(i).name));              
        
        %figure out start time based on bulk parameters time stamps 
        dum_sdt = datevec(sdt.time); 
        dum_rdt = datevec(rdt.file_time(cnt)); 
        tind = find(dum_sdt(:,1)==dum_rdt(1)&dum_sdt(:,2)==dum_rdt(2)&dum_sdt(:,3)==dum_rdt(3),1,'first'); 
        tend = sdt.time(tind); 
        %figure out end date based on number of samples
        tstart = tend-((size(tmp.data,1)/1.28)*(1/(60*60*24))); 
        tdum = [tstart:(1/(1.28*60*60*24)):tend]';
        %exclude last time point to make same size
        tdum = tdum(2:end);    
        %break in to half hourly intervals for storing displacements 
        num_samples = 1.28*60*30;
        dloop = 1:num_samples:size(tmp.data,1);
        for j = 1:size(dloop,2); 
            displacements.time = [displacements.time; tdum(dloop(j))]; 
            %extract 30 min blocks (already in meters)
            displacements.checksum = [displacements.checksum; tmp.data(dloop(j):dloop(j)+(num_samples-1),1)']; 
            displacements.heave = [displacements.heave; tmp.data(dloop(j):dloop(j)+(num_samples-1),2)']; 
            displacements.north = [displacements.north; tmp.data(dloop(j):dloop(j)+(num_samples-1),3)']; 
            displacements.west = [displacements.west; tmp.data(dloop(j):dloop(j)+(num_samples-1),4)']; 
        end
        
        %check that decoded hs_max is equal to recorded hs max
%         hs_ind = find(sdt.time>=tdum(1) &sdt.time<=tdum(end)); 
%         hs_check = find(sdt.hs(hs_ind) == hs_max); 
%         if ~isempty(hs_check)
% 
%         else
%             displacements.checksum = [displacements.checksum; ones(1,size(displacements.checksum,2)).*nan]; 
%             displacements.heave = [displacements.heave; ones(1,size(displacements.heave,2)).*nan]; 
%             displacements.north = [displacements.north; ones(1,size(displacements.north,2)).*nan]; 
%             displacements.west = [displacements.west; ones(1,size(displacements.west,2)).*nan]; 
%         end
        cnt = cnt+1; 
    end
end

%sort
[displacements.time,I] = sort(displacements.time); 
displacements.heave = displacements.heave(I,:); 
displacements.north = displacements.north(I,:); 
displacements.west = displacements.west(I,:); 




