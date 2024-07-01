%% Code to read in CSV results from Sofar parser script (not smart mooring)
% MH makes V2. 2023-06-22. To feed into AODN ARDC Data processing script
% "process_wavebuoys_delayed_mode_ardc.m"

%for testing
%dpath = 'E:\wawaves\KingGeorgeSound\delayedmode\20230517_to_20230606_dep06_KingGeorgeSound_SPOT0162'

function [bulkparams, locations, spec, displacements, sst] = read_parser_results_V2(dpath)

files = dir(dpath); files = files(3:end); 

%loop over files and read in data, the parser outputs. (products of parser are :
%a1,a2,b1,b2,bulkparameters,Cxy,displacement,location,Qxz,Qyz,Sxx,system,Syy,Szz)
%- parse into 'bulkparams','locs','spec','displacements','sst' structures

icnt=1;
% icnt count for making sure the freq vector and time and dof is
% only produced the first time. 

for i = 1:size(files,1)
    if strcmp(files(i).name(end-2:end),'csv')
        % raw data card files have capital "CSV", parser outputs have
        % little "csv"
        % files to injest: a1, a2, b1 ,b2, bulkparameters, Cxy, displacements, location, Qxz, Qyz, Sxx, system, Syy, Szz 
        
        pname = files(i).name(1:end-4);
        
        if  strcmp(pname,'displacement')      
            displacements = struct('time',[], 'x',[],'y',[],'z',[]); 
        else
            dumdata = importdata(fullfile(files(i).folder, files(i).name));
        end
        
        disp(['Processing ' pname]);
        %format to structures that other codes expect 
        
        if strcmp(pname,'Sxx')|strcmp(pname,'Syy')|strcmp(pname,'Szz')|strcmp(pname,'a1')|strcmp(pname,'a2')|strcmp(pname,'b1')|strcmp(pname,'b2')
%             size(dumdata.data,2)>100 %spectral data
            if icnt == 1
                spec.freq = dumdata.data(1,:); 
                icnt=icnt+1;
                for j = 2:size(dumdata.textdata,1)
                    spec.time(j-1,1) = datenum(str2num(dumdata.textdata{j,1}),str2num(dumdata.textdata{j,2}),str2num(dumdata.textdata{j,3}),...
                        str2num(dumdata.textdata{j,4}),str2num(dumdata.textdata{j,5}),(str2num(dumdata.textdata{j,6})+str2num(dumdata.textdata{j,7})/1000)); 
                                 
                    spec.dof(j-1,1) = str2num(dumdata.textdata{j,8}); 
                end
            end
            spec.(pname) = dumdata.data(2:end,:); 
        elseif strcmp(pname,'bulkparameters')
            bulkparams = struct('time',[], 'hs',[],'tm',[],'tp',[],'dm',[],'dp',[],'meanspr',[],'pkspr',[],'lat',[],'lon',[],'temp',[]);
            bulkparams.temp = zeros(size(dumdata.data,1),1)-9999;
            
            for j = 1:size(dumdata.data,1)
               bulkparams.time(j,1) = datenum(dumdata.data(j,1),dumdata.data(j,2),dumdata.data(j,3),...
                        dumdata.data(j,4),dumdata.data(j,5),dumdata.data(j,6)+dumdata.data(j,7)/1000);          
            end
            bulkparams.hs = dumdata.data(:,8); 
            bulkparams.tm = dumdata.data(:,9); 
            bulkparams.tp = dumdata.data(:,10); 
            bulkparams.dm = dumdata.data(:,11); 
            bulkparams.dp = dumdata.data(:,12); 
            bulkparams.meanspr = dumdata.data(:,13); 
            bulkparams.pkspr = dumdata.data(:,14); 

            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
         elseif strcmp(pname,'displacement')   
            
%FroM Online example of loading large CSV's

cd(dpath)
 chunk_nRows = 2e4 ;
 % - Open file.
 fId  = fopen( 'displacement.csv' ) ;
 % - Read first line, convert to double, determine #columns.
 line  = fgetl( fId ) ;
 line2 = fgetl( fId ) ;
 row   = sscanf( line2, '%f,' )' ;
 nCols = numel( row ) ;
 % - Prealloc data, copy first row, init loop counter.
 data      = zeros( chunk_nRows, nCols ) ;
 data(1,:) = row ;
 rowCnt    = 1 ;
 % - Loop over rest of the file.
 while ~feof( fId )
    rowCnt = rowCnt + 1 ;
    % - Realloc + a chunk if rowCnt larger than data array.
    if rowCnt > size( data, 1 )
        fprintf(strcat( 'Realloc ..\n',num2str(rowCnt)));
        data(size(data, 1)+chunk_nRows, nCols) = 0 ;
    end
    % - Read line, convert and store.
    line = fgetl( fId ) ;
    data(rowCnt,:) = sscanf( line, '%f,' )' ;
 end
 % - Truncate data to last row (truncate last chunk).
 data = data(1:rowCnt,:) ;
 % - Close file.
 fclose( fId ) ;
 
 displacements.time = zeros(size(dumdata.data,1),1);
 displacements.x = zeros(size(dumdata.data,1),1);
 displacements.y = zeros(size(dumdata.data,1),1);
 displacements.z = zeros(size(dumdata.data,1),1);
 
 displacements.x = data(:,8); 
 displacements.y = data(:,9); 
 displacements.z = data(:,10); 
                         
 displacements.time = datenum(data(:,1),data(:,2),data(:,3),data(:,4),...
    data(:,5),data(:,6) + data(:,7)/1000); 

 clearvars chunk_nRows data fId line line2 nCols row rowCnt
 
 
             
             %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                
        elseif strcmp(pname,'location')
            locations.lat = dumdata.data(:,8); 
            locations.lon = dumdata.data(:,9); 
            locations.time = datenum(dumdata.data(:,1),dumdata.data(:,2),dumdata.data(:,3),dumdata.data(:,4),...
                 dumdata.data(:,5),dumdata.data(:,6) + dumdata.data(:,7)/1000); 
             
            %add downsampled locations to bulkparams 
            bulkparams.lat = interp1(locations.time,locations.lat,bulkparams.time); 
            bulkparams.lon = interp1(locations.time,locations.lon,bulkparams.time); 
            
        elseif strcmp(pname, 'sst')
            
            sst.time = datenum(dumdata.data(:,1),dumdata.data(:,2),dumdata.data(:,3),dumdata.data(:,4),...
                 dumdata.data(:,5),dumdata.data(:,6) + dumdata.data(:,7)/1000); 
                                
            sst.sst = dumdata.data(:,8);  
            
            %Add downsampled temps to bulkparams
            bulkparams.temp = interp1(sst.time,sst.sst,bulkparams.time); 
                                              
        end
    end
end

   






