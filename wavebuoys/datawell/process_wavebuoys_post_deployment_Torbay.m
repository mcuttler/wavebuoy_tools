%%  Process wave buoys (real time) for display on wawaves.org

%MC to update prior to merging into master branch

%AQL public token: a1b3c0dbaa16bb21d5f0befcbcca51
%UWA token: e0eb70b6d9e0b5e00450929139ea34


%% set initial paths for wave buoy data to process and parser script
clear; clc

addpath(genpath('\\drive.irds.uwa.edu.au\SEE-PNP-001\ProcessingCodes\Wave_buoys\'));

%location of wavebuoy_tools repo
% buoycodes = 'C:\Data\wavebuoy_tools\wavebuoys'; 
% addpath(genpath(buoycodes))

%buoy type and deployment info number and deployment info 
buoy_info.type = 'datawell'; 
buoy_info.serial = 'Datawell-74089';  
buoy_info.name = 'Torbay'; 
buoy_info.datawell_name = 'Dev_Site'; 
buoy_info.version = 'DWR4'; %or DWR4 for Datawell, for example
buoy_info.sofar_token = 'e0eb70b6d9e0b5e00450929139ea34'; 
buoy_info.utc_offset = 8; 
buoy_info.DeployLoc = 'Torbay';
buoy_info.DeployDepth = 30; 
buoy_info.DeployLat = -35.069717; 
buoy_info.DeployLon = 117.772767; 
buoy_info.UpdateTime =  0.5; %hours
buoy_info.DataType = 'spectral'; %can be parameters if only bulk parameters, or spectral for including spectral coefficients
%folder where data to be processed is
buoy_info.data_path = '\\drive.irds.uwa.edu.au\SEE-PNP-001\HANSEN_Albany_WaveEnergy_Feasibility_ongoing\Data\WaveBuoys\Datawell\Data\UWA\CF\WaveBuoyNearshore\74089_DevSite_Oct2019_Download\CSV_export\';
buoy_info.archive_path = '\\drive.irds.uwa.edu.au\SEE-PNP-001\HANSEN_Albany_WaveEnergy_Feasibility_ongoing\Data\WaveBuoys\Datawell\Data\UWA\CF\WaveBuoyNearshore\74089_DevSite_Oct2019_Download\';

%% process realtime mode data
%create blank array
    dw_vars = {'serialID','E','theta','s','m2','n2','time','a1','a2','b1','b2',...
        'frequency','ndirec','spec2D','hsig','tp','dp','dpspr', 'curr_mag','curr_dir',...
        'curr_mag_std','curr_dir_std','temp_time','surf_temp','bott_temp','w','w_std',...
        'gps_time','gps_pos','disp_tstart','disp_time','disp_h','disp_n','disp_w'}; 
    for i = 1:length(dw_vars)
        data.(dw_vars{i}) = []; 
    end


%---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 %Datawell DWR4 
 cnt=1;

files=dir((fullfile(buoy_info.data_path,'*-20.csv'))); %get all the field to process 20 file is 1D spectra
for kk=4:length(files) %file 1 is bad 1970 file
        fname=files(kk).name(1:10);
    
    input.file20 = [buoy_info.data_path fname  '-20.csv'];
    input.file21 =[buoy_info.data_path fname  '-21.csv'];
    input.file25 =[buoy_info.data_path fname  '-25.csv'];
    input.file28 = [buoy_info.data_path fname  '-28.csv'];
    input.file80 =[buoy_info.data_path fname  '-80.csv'];
    input.file82 =[buoy_info.data_path fname  '-82.csv'];
    input.file23 = [buoy_info.data_path fname '-23.csv'];
    input.filed = [buoy_info.data_path fname '-displacement.csv'];
    
    %load and organize data for each file containing 4 days of data
    [temp] = Process_Datawell_post_process(buoy_info, data, input.file20, input.file21, input.file25, input.file28, input.file80, input.file82, input.file23, input.filed);   
    clear input
    
    %now append
    if cnt==1
        data=temp;
        data.hs=data.hsig;
        data = rmfield(data,'hsig');
        data.temp=data.surf_temp;
        data = rmfield(data,'surf_temp');

        cnt=cnt+1;
        clear temp
    else
        data.serialID = [data.serialID; temp.serialID]; 
        data.E = [data.E ; temp.E];
        data.theta = [data.theta; temp.theta];
        data.s = [data.s;  temp.s];
        data.m2 = [data.m2; temp.m2];
        data.n2 = [data.n2;  temp.n2];
        data.time = [data.time;  temp.time];
        data.a1 = [data.a1;  temp.a1];
        data.a2 = [data.a2;  temp.a2];
        data.b1 = [data.b1;  temp.b1];
        data.b2 = [data.b2;  temp.b2];

        data.spec2D = cat(3,data.spec2D,temp.spec2D);
        data.hs = [data.hs;  temp.hsig];
        data.tp = [data.tp;  temp.tp];
        data.dp = [data.dp;  temp.dp];
        data.dpspr = [data.dpspr;  temp.dpspr]; 
        
        data.curr_mag = [data.curr_mag;  temp.curr_mag]; 
        data.curr_dir = [data.curr_dir;  temp.curr_dir]; 
        data.curr_mag_std = [data.curr_mag_std;  temp.curr_mag_std];
        data.curr_dir_std = [data.curr_dir_std;  temp.curr_dir_std];
        data.temp_time = [data.temp_time;  temp.temp_time];
         data.temp = [data.temp ;  temp.surf_temp];
         data.bott_temp = [data.bott_temp ;  temp.bott_temp];
         data.w = [data.w;  temp.w];
         data.w_std= [data.w_std;  temp.w_std];
         data.gps_time = [data.gps_time;  temp.gps_time];
         data.gps_pos = [data.gps_pos ;  temp.gps_pos];   
         
         %data.disp_tstart = [data.disp_tstart; temp.disp_tstart]; 
         data.disp_time = [data.disp_time; temp.disp_time]; 
         data.disp_h = [data.disp_h; temp.disp_h]; 
         data.disp_n = [data.disp_n; temp.disp_n]; 
         data.disp_w = [data.disp_w; temp.disp_w];         
         
         clear temp
         cnt=cnt+1;
    end
    
end
    
    
    
     [data] = qaqc_bulkparams(data);
    
     t1=datevec(data.time(1));
     t2=datevec(data.time(end));
     fname=['buoy_data_' num2str(t1(1)) '_' num2str(t1(2)) '_' num2str(t1(3)) '-' num2str(t2(1)) '_' num2str(t2(2)) '_' num2str(t2(3)) '.mat'];

     
   save(['p:\HANSEN_Albany_WaveEnergy_Feasibility_ongoing\Data\WaveBuoys\Datawell\Data\UWA\CF\WaveBuoyNearshore\74089_DevSite_DL20210219\' fname],'data','-v7.3');
%%










        

        
        
       




