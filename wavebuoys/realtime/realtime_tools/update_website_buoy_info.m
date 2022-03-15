%% update master buoy info spreadsheet for wawaves.org website
%This code will pull in the master CSV that contains metadata for waves
%website and update various information

%required input: 
%buoy info structure
%data containing new data

%M Cuttler (UWA, 2021)

%%
function [] = update_website_buoy_info(buoy_info, data)

%read in existing data - read everything as strings
fid = fopen([buoy_info.archive_path '\' buoy_info.website_filename],'r'); 
fmt = '%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s'; 
in_data = textscan(fid, fmt, 'Delimiter',','); 
fclose(fid); 

%extract text data 
for i = 1:size(in_data,2)
    web_data(:,i) = in_data{1,i}; 
end

%create 'write_idx' which defines which rows/columsn are writable with
%updated data 
dcol = size(web_data,2); 
drow = size(web_data,1); 
write_cols = [1 5 6 7 8 10 11 12 13 14]; 
write_idx  = zeros(drow,dcol); 
write_idx(2:end,write_cols) = 1; 
     

%find column for 'last update', label, drifting, lat, lon
for i = 1:size(web_data,2)
    if strcmp(web_data{1,i},'last_updated')
        last_update = i; 
    elseif strcmp(web_data{1,i},'label')
        label = i; 
    elseif strcmp(web_data{1,i},'drifting')
        drifting = i; 
    elseif strcmp(web_data{1,i},'Latitude')
        lat = i; 
    elseif strcmp(web_data{1,i},'Longitude')
        lon = i; 
    end
end

%find row for buoy
for i = 1:size(web_data,1)
    if strcmp(web_data{i,label},buoy_info.name)
        buoy = i;
    end
end       

%update with last_updated
web_data{buoy,last_update} =  num2str(posixtime(datetime(datevec(data.time(end))))); 

%update with first_updated if not included
if isempty(web_data{buoy, last_update-1})
    first_time = search_buoy_archive(buoy_info); 
    web_data{1,last_update-1}{buoy} = num2str(first_time); 
end

%update with breadcrumb for drifting buoy
if str2num(web_data{buoy,drifting})>0
    web_data{buoy,lat} = num2str(data.lat(end));
    web_data{buoy,lon} = num2str(data.lon(end)); 
end

%re-write text file
%create formatting strings

% title format
for i = 1:size(web_data,2)
    if i == size(web_data,2)
        fmt1{1,i} = '%s\n'; 
    else
        fmt1{1,i} = '%s,';
    end
end

%data format
for i = 1:size(web_data,2)    
    if i == size(web_data,2)
        if write_idx(2,i)>0
            fmt2{1,i} = '%d\n'; 
        else
             fmt2{1,i} = '%s\n'; 
        end
    else
         if write_idx(2,i)>0
             if strcmp(web_data{1,i},'Latitude')|strcmp(web_data{1,i},'Longitude')
                 fmt2{1,i} = '%0.4f,'; 
             else
                 fmt2{1,i} = '%d,';
             end
        else
             fmt2{1,i} = '%s,'; 
        end
    end
end

fid = fopen([buoy_info.archive_path '\' buoy_info.website_filename],'w'); 

for i = 1:size(web_data,1)
    if i == 1
        for j = 1:size(web_data,2)
            fprintf(fid, fmt1{j}, web_data{i,j}); 
        end        
    else
        for j = 1:size(web_data,2);
            if strcmp(fmt2{j}(1:2), '%s')
                fprintf(fid, fmt2{j}, web_data{i,j}); 
            elseif strcmp(fmt2{j}(1:2),'%d')|strcmp(fmt2{j}(1:2),'%0')
                fprintf(fid, fmt2{j}, str2num(web_data{i,j})); 
            end               
        end
    end
    
end         

fclose(fid);                                                      

end

%%
%sub function for finding earliest time point in archive for wave buoy
function [first_time] = search_buoy_archive(buoy_info); 
%first update should be first day that text data is available

yrs = dir([buoy_info.archive_path '\' buoy_info.name '\text_archive']); yrs = yrs(3:end); 

mos = dir([buoy_info.archive_path '\' buoy_info.name '\text_archive\' num2str(yrs(1).name)]); mos = mos(3:end); 

txt_files = dir([buoy_info.archive_path '\' buoy_info.name '\text_archive\' num2str(yrs(1).name) '\' num2str(mos(1).name)]); txt_files = txt_files(3:end); 

first_time = posixtime(datetime(datevec(datenum(txt_files(1).name(end-11:end-4),'yyyymmdd'))));
end
    






