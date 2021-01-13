%% update master buoy info spreadsheet for wawaves.org website

function [] = update_website_buoy_info(buoy_info, data); 

%read in existing data
fid = fopen([buoy_info.archive_path '\buoys.csv'],'r'); 
fmt = '%s%s%s%s%s%s%s%s%s%s'; 
web_data = textscan(fid, fmt, 'Delimiter',','); 
fclose(fid);     

%find column for 'last update'
for i = 1:size(web_data,2)
    if strcmp(web_data{1,i}{1},'last_updated')
        last_update = i; 
    end
end

for i = 1:size(web_data{1,2},1)    
    if strcmp(web_data{1,2}{i},buoy_info.name)
        buoy = i;
    end
end       

%update with last_updated
web_data{1,last_update}{buoy} =  datestr(data.time(end),'dd/mm/yyyy HH:MM:SS');

%update with first_updated if not included
if isempty(web_data{1, last_update-1}{buoy})
    first_time = search_buoy_archive(buoy_info); 
    web_data{1,last_update-1}{buoy} = first_time; 
end


%re-write text file
%create formatting strings

fid = fopen([buoy_info.archive_path '\buoys.csv'],'w'); 

for i = 1:size(web_data{1,1},1)
    for j = 1:size(web_data,2)
        if i == 1
            fmt = {'%s,','%s,','%s,','%s,','%s,','%s,','%s,','%s,','%s,','%s\n'}; 
            fprintf(fid, fmt{j},web_data{1,j}{i});
        else
            fmt = {'%f,','%s,','%s,','%f,','%f,','%s,','%s,','%s,','%s,','%s\n'}; 
            if j == 1|j==4|j==5
                fprintf(fid, fmt{j},str2num(web_data{1,j}{i}));
            else
                fprintf(fid, fmt{j}, web_data{1,j}{i}); 
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

first_time = datestr(datenum(txt_files(1).name(end-11:end-4),'yyyymmdd'),'dd/mm/yyyy'); 
end
    






