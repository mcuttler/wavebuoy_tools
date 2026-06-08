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
disp_data = readtable(dispfile,'VariableNamingRule','preserve'); 
disp_data.Properties.VariableNames = {'status','heave','north','west'};
%separate status from XYZ for comparison to sync messages below 
disp_status = disp_data.status; 
disp_data = disp_data(:,2:end); 

%read in sync info file
sync_data = readtable(file23,'VariableNamingRule','preserve'); 
sync_data.Properties.VariableNames = {'tstamp','datastamp','segs','samples','hexstring'}; 
sync_data.tstamp = datetime(1970,1,1)+seconds(sync_data.tstamp);

%only keep unique time points
[~, I, ~] = unique(sync_data.tstamp,'rows'); 
sync_data = sync_data(I,:); 

%start building output structure 
data.disp_time = sync_data.tstamp; 
data.disp_time_utc = sync_data.tstamp; 
data.disp_samples_unique = sync_data.samples;                

%decode hexstring
%check class
if strcmp(class(sync_data.hexstring),'cell')
    for i = 1:size(data.disp_time,1)
        if data.disp_samples_unique(i)<4000
            disp(['not enough samples collected for block ' num2str(i) ' out of ' num2str(size(data.disp_time,1))]); 
            data.disp_h(i,1:4608) = ones(1,4608).*nan; 
            data.disp_n(i,1:4608) = ones(1,4608).*nan; 
            data.disp_w(i,1:4608) = ones(1,4608).*nan; 
            for k = 1:4608
                data.flag{i,k} = disp_status{k}; 
            end      
        else
            [hn1,h] = datawell_hex_to_displacement(sync_data.hexstring{i});
            pattern = [hn1 h]; 
            disp_pairs = [table2array(disp_data(1:end-1,:)) table2array(disp_data(2:end,:))];  
            %set tolerance to account of floating numbers
            tol = 1e-6; 
            disp_pairs = round(disp_pairs / tol) * tol;
            pattern = round(pattern / tol) * tol;
            ind_h = find(ismember(disp_pairs, pattern, 'rows'))+1; 
            
            if size(ind_h,1) == 1 %check only 1 matching value
                %extract displacements     
                disp(['processing block ' num2str(i) ' out of ' num2str(size(data.disp_time,1))]); 
                dstart = ind_h - (data.disp_samples_unique(i)-1);
                data.disp_h(i,1:length(dstart:ind_h)) = disp_data.heave(dstart:ind_h)'; 
                data.disp_n(i,1:length(dstart:ind_h)) = disp_data.north(dstart:ind_h)'; 
                data.disp_w(i,1:length(dstart:ind_h)) = disp_data.west(dstart:ind_h)';
                
                %include flag from datawell for good or not measurement
                dflag = disp_status(dstart:ind_h);
                for k = 1:length(dstart:ind_h)
                    data.flag{i,k} = dflag{k}; 
                end      
                
            elseif size(ind_h,1)>1 %too many matches
                disp(['too many matches for block ' num2str(i) ' out of ' num2str(size(data.disp_time,1))]); 
                data.disp_h(i,1:4608) = ones(1,4608).*nan; 
                data.disp_n(i,1:4608) = ones(1,4608).*nan; 
                data.disp_w(i,1:4608) = ones(1,4608).*nan; 
                for k = 1:4608
                    data.flag{i,k} = disp_status{k}; 
                end      
            else
                disp(['No matching data in displacements for block ' num2str(i) ' out of ' num2str(size(data.disp_time,1))]); 
                dstart = ind_h - (data.disp_samples_unique(i)-1);
                data.disp_h(i,1:length(dstart:ind_h)) = ones(1,length(dstart:ind_h)).*nan; 
                data.disp_n(i,1:length(dstart:ind_h)) = ones(1,length(dstart:ind_h)).*nan; 
                data.disp_w(i,1:length(dstart:ind_h)) = ones(1,length(dstart:ind_h)).*nan; 
                dflag = disp_status(dstart:ind_h);
                for k = 1:length(dstart:ind_h)
                    data.flag{i,k} = dflag{k}; 
                end        
            end               
        end                   
    end
else
    disp(['No hexstrings to decode']);
    data.disp_h(1,1:4608) = ones(1,4608).*nan; 
    data.disp_n(1,1:4608) = ones(1,4608).*nan; 
    data.disp_w(1,1:4608) = ones(1,4608).*nan; 
    for k = 1:4608
        data.flag{i,k} = disp_status{k}; 
    end      
end

end





