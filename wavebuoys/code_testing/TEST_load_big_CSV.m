
% dpath = 'E:\wawaves\KingGeorgeSound\delayedmode\20230517_to_20230606_dep06_KingGeorgeSound_SPOT0162'

% dpath =  'E:\wawaves\CapeBridgewater\delayedmode\20230510_SPOT1590_CapeBridgewater_Data'

% dpath= 'C:\Users\00104893\LocalDocuments\Projects\Wave buoys\Spotters\data\20230510_SPOT1590_CapeBridgewater_Data\20230510_SPOT1590_CapeBridgewater_Data'

% Current way of loading Displacepment csv

 
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            files = dir(dpath); files = files(3:end); 
            
            i=106;    
            
            dumdata = importdata(fullfile(files(i).folder, files(i).name));
             % Make displacement time vector correct size
             displacements.time = zeros(size(dumdata.data,1),1);
             displacements.x = zeros(size(dumdata.data,1),1);
             displacements.y = zeros(size(dumdata.data,1),1);
             displacements.z = zeros(size(dumdata.data,1),1);
             displacements.x = dumdata.data(:,8); 
             displacements.y = dumdata.data(:,9); 
             displacements.z = dumdata.data(:,10); 
                         
             displacements.time = datenum(dumdata.data(:,1),dumdata.data(:,2),dumdata.data(:,3),dumdata.data(:,4),...
                 dumdata.data(:,5),dumdata.data(:,6) + dumdata.data(:,7)/1000); 
                                
             clearvars dumdata
             
             %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

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
 
 