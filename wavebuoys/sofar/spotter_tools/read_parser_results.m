%% Code to read in CSV results from Sofar parser script (not smart mooring)

function [bulkparams, locations, spec, displacements, sst] = read_parser_results(dpath)

files = dir(dpath); files = files(3:end); 

%loop over files and read in data - parse into
%'bulkparams','locs','spec','displacements','sst' structures
for i = 1:size(files,1)
    if strcmp(files(i).name(end-2:end),'csv')
        %all files should be of the naming convention 'SPOT-XXXX_Sxx.csv', so
        %split to figure out variable of interest
        C = strsplit(files(i).name,'_'); 
        pname = C{2}(1:end-4); 
        
        if  strcmp(pname,'displacements')      
            displacements = []; 
        else
            dumdata = importdata(fullfile(files(i).folder, files(i).name));
        end
        disp(['Processing ' pname]); 
        %format to structures that other codes expect 
        if strcmp(pname,'Sxx')|strcmp(pname,'Syy')|strcmp(pname,'Szz')|strcmp(pname,'a1')|strcmp(pname,'a2')|strcmp(pname,'b1')|strcmp(pname,'b2')
%             size(dumdata.data,2)>100 %spectral data
            if i == 1
                spec.freq = dumdata.data(1,:); 
                for j = 2:size(dumdata.textdata,1)
                    if length(dumdata.textdata{j,1})>25
                        spec.spec_time(j-1,1) = datenum(dumdata.textdata{j,1},'yyyy-mm-dd HH:MM:SS.FFF+00:00'); 
                    else
                        spec.spec_time(j-1,1) = datenum(dumdata.textdata{j,1},'yyyy-mm-dd HH:MM:SS+00:00'); 
                    end                
                    spec.dof(j-1,1) = str2num(dumdata.textdata{j,2}); 
                end
            end
            spec.(pname) = dumdata.data(2:end,:); 
        elseif strcmp(pname,'bulkparams')
            for j = 2:size(dumdata.textdata,1)
                if length(dumdata.textdata{j,1})>25
                    bulkparams.time(j-1,1) = datenum(dumdata.textdata{j,1},'yyyy-mm-dd HH:MM:SS.FFF+00:00'); 
                else
                    bulkparams.time(j-1,1) = datenum(dumdata.textdata{j,1},'yyyy-mm-dd HH:MM:SS+00:00'); 
                end                
            end
            bulkparams.hs = dumdata.data(:,1); 
            bulkparams.tm = dumdata.data(:,2); 
            bulkparams.tp = dumdata.data(:,3); 
            bulkparams.dm = dumdata.data(:,4); 
            bulkparams.dp = dumdata.data(:,5); 
            bulkparams.meanspr = dumdata.data(:,6); 
            bulkparams.pkspr = dumdata.data(:,7); 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%         elseif strcmp(pname,'displacements')      
%             displacements.x = dumdata.data(:,1); 
%             displacements.y = dumdata.data(:,2); 
%             displacements.z = dumdata.data(:,3); 
%             %add waitbar so know it's progressing
%             h = waitbar(0,'processing displacements time'); 
%             for j = 2:size(dumdata.textdata,1)
%                 waitbar(j/size(dumdata.data,1), h, ['processing step ' num2str(j) ' out of ' num2str(size(dumdata.data,1))]);              
%                 if length(dumdata.textdata{j,1})>25
%                     displacements.disp_time(j-1,1) = datenum(dumdata.textdata{j,1},'yyyy-mm-dd HH:MM:SS.FFF+00:00'); 
%                 else
%                     displacements.disp_time(j-1,1) = datenum(dumdata.textdata{j,1},'yyyy-mm-dd HH:MM:SS+00:00'); 
%                 end                
%             end   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        elseif strcmp(pname,'locations')
            for j = 2:size(dumdata.textdata,1)
                if length(dumdata.textdata{j,1})>25
                    locations.time_location(j-1,1) = datenum(dumdata.textdata{j,1},'yyyy-mm-dd HH:MM:SS.FFF+00:00'); 
                else
                    locations.time_location(j-1,1) = datenum(dumdata.textdata{j,1},'yyyy-mm-dd HH:MM:SS+00:00'); 
                end                
            end
            locations.lat = dumdata.data(:,1); 
            locations.lon = dumdata.data(:,2); 
        elseif strcmp(pname, 'sst')
            if isstruct(dumdata)
                for j = 2:size(dumdata.textdata,1)
                    if length(dumdata.textdata{j,1})>25
                        sst.temp_time(j-1,1) = datenum(dumdata.textdata{j,1},'yyyy-mm-dd HH:MM:SS.FFF+00:00'); 
                    else
                        sst.temp_time(j-1,1) = datenum(dumdata.textdata{j,1},'yyyy-mm-dd HH:MM:SS+00:00'); 
                    end                
                end
                sst.surf_temp = dumdata.data(:,1);     
            else
                for j = 2:size(dumdata,1)
                    T = strsplit(dumdata{j},','); 
                    sst.temp_time(j-1,1) = datenum(T{1},'yyyy-mm-dd HH:MM:SS'); 
                    sst.surf_temp(j-1,1) = str2num(T{2}); 
                end
            end                                              
        end
    end
end

   






