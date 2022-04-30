%% Process FLT files from Sofar memory card
%Note, you can also use the Sofar Parser to generate a single 'displacement
%file' but that then has some filtering applied. This instead will just
%pull in the raw displacements for user-defined processing 

%Example usage: 
% sofarpath = '\\drive.irds.uwa.edu.au\SEE-PNP-001\HANSEN_Albany_WaveEnergy_Feasibility_ongoing\Data\WaveBuoys\Sofar\SPOT0168_KingGeorgeSound_20201211_to_20210326'; 
% utcoffset = 8;
% [displacements = process_sofar_FLT(sofarpath, utcoffset); 

%%
function [displacements] = process_sofar_FLT(sofarpath, utcoffset)

%get list of files
dum = dir(sofarpath); 
dum = dum(3:end); 

%create empty output structure
displacements = struct('timeutc',[],'timelocal',[],'x',[],'y',[],'z',[]); 

for i = 1:size(dum,1); 
%     disp(['Processing ' num2str(round(i/size(dum,1)*100,2)) '%']); 
%    sometimes random files in Raw that are not data files
   if length(dum(i).name)>6
       if strcmp(dum(i).name(end-6:end),'FLT.CSV')   
           %         pull in data
           %         ddum.textdata = header
           %         ddum.data = data
           %             ddum.data = [millis,GPS_Epoch_Time (s),x(mm), y(mm), z(mm)]
           
           ddum = importdata(fullfile(sofarpath, dum(i).name)); 
           %check that structure is right size
           if size(ddum.data,2)==5
               %convert epoch time to matlab datenum
               posixtime = ddum.data(:,2)+(ddum.data(:,1)./1000); 
               dt = utcoffset./24; %needs to be in hours, + is east from UTC, - is west from UTC
               displacements.timeutc = [displacements.timeutc; datenum(datetime(posixtime,'convertFrom','posixtime'))]; 
               displacements.timelocal = [displacements.timelocal; datenum(datetime(posixtime,'convertFrom','posixtime'))+dt];
               
               %convert mm to m
               displacements.x = [displacements.x; ddum.data(:,3)./1000]; 
               displacements.y = [displacements.y; ddum.data(:,4)./1000]; 
               displacements.z = [displacements.z; ddum.data(:,5)./1000]; 
           end
       end
   end
end
end

        
        
       
       
            
    
