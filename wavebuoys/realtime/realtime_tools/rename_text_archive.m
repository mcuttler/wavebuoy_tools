%% change filename

files = dir('E:\auswaves\wawaves\ExmouthGulfNorth\text_archive\**\*.csv'); 

site = 'ExmouthGulf02';
sitenew = 'ExmouthGulfNorth'; 

for i = 1:size(files,1)
    if contains(files(i).name,site)
        disp(['fixing ' files(i).name])
        f1 = fullfile(files(i).folder, files(i).name); 
        f2 = fullfile(files(i).folder, strrep(files(i).name,site,sitenew)); 

        copyfile(f1,f2)
        delete(f1); 
    end
end
