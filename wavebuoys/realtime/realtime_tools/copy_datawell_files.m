%% copy Datawell files to AWS

%set source directory
src_dir = 'G:\waved\Dev_Site2\2026';

%set destination directory
dest_dir = 'E:\DatawellBuoys\winderbandi';
%create dest dir if doesn't exist
if ~isdir(dest_dir);
    mkdir(dest_dir);
end

%get all files and copy 
files = dir(fullfile(src_dir,'**/*.csv'));

for jj = 1:size(files,1)
    %only copy files from last day
    if datetime('now')-files(jj).date < hours(24)
        dest_folder = fullfile(dest_dir, strrep(files(jj).folder,src_dir,''));
        if ~isdir(dest_folder)
            mkdir(dest_folder)
        end
        
        copyfile(fullfile(files(jj).folder, files(jj).name), fullfile(dest_folder, files(jj).name));
    end


end

    