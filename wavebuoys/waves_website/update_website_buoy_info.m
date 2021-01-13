%% update master buoy info spreadsheet for wawaves.org website

function [] = update_website_buoy_info(buoy_info, data); 

%read in existing data
[num,txt,raw] = xlsread([buoy_info.archive_path '\buoys.csv']); 

%find column for 'last update'
last_update = find(strcmp(txt(1,:),'last_updated')==1); 
buoy = find(strcmp(txt(:,2),buoy_info.name)==1);

%update with last_updated
txt{buoy,last_update} = datestr(data.time(end),'dd/mm/yyyy HH:MM:SS');

%re-write text file
%create formatting strings

fid = fopen([buoy_info.archive_path '\buoys.csv'],'w'); 
for i = 1:size(txt,1)
    for j = 1:size(txt,2)
        if i == 1
            fmt = {'%s,','%s,','%s,','%s,','%s,','%s,','%s,','%s,','%s,','%s\n'}; 
            fprintf(fid, fmt{j},txt{i,j});
        else
            fmt = {'%f,','%s,','%s,','%f,','%f,','%s,','%s,','%s,','%s,','%s\n'}; 
            if j == 1|j==4|j==5
                fprintf(fid, fmt{j},num(i-1,j));
            else
                fprintf(fid, fmt{j},txt{i,j});
            end
        end
    end
end
fclose(fid);                                                      



end
